// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PeerToken.sol";

/**
 * @title PeerGovernor
 * @author elcharitas.dev - Jonathan Irhodia
 * @dev The PeerGovernor contract is used to manage the peers of the rinkeby network.
 * ------------------------------------------------------------------------------------
 * This contract was created by Jonathan Irhodia and is licensed under the MIT License.
 * It is created to be submitted for Polygon Screening Task.
 * The governor allows peers to exchange tokens at their own set prices.
 * ------------------------------------------------------------------------------------
 */
contract PeerGovernor is ReentrancyGuard {
    using SafeMath for uint256;

    event NewPeer(address peer);
    event RemovePeer(address peer);
    event NewOffer(address peer, uint256 offer);

    // offers indexed by id
    struct Offer {
        uint256 price;
        address peer;
        address baseToken;
        address quoteToken;
    }
    Offer[] public offers;

    // standard token for all peers
    PeerToken public token;

    // peers management
    uint256 public peerCount;
    mapping(address => bool) public peers;

    constructor(){
        _setToken(address(new PeerToken()));
        _addPeer(msg.sender, 1000 gwei);
    }

    /**
     * @dev only existing peers can add new peers to the network
     */
    modifier isPeer() {
        require(
            peers[msg.sender],
            "You are not a peer yet"
        );
        _;
    }

    /**
     * @dev Allows peers to add a peer to the network.
     * @param _peer The address of the peer to add
     */
    function addPeer(address _peer) external payable isPeer {
        require(
            msg.value > _calcFee().div(3),
            "You must pay a fee to add to the network"
        );
        _addPeer(_peer, 0);
    }

    /**
     * @dev allows joining the network as a peer after paying a fee.
     */
    function join() external payable {
        require(
            msg.value > _calcFee(),
            "You must pay a fee to join the network"
        );
        _addPeer(msg.sender, msg.value);
    }

    /**
     * @dev allows peers to create a new offer
     */
    function createOffer(
        address _baseToken,
        address _quoteToken,
        uint256 _price
    ) external payable isPeer {
        require(
            _price > 0,
            "Price must be greater than 0"
        );
        _createOffer([_baseToken, _quoteToken], [_price, msg.value]);
    }

    /**
     * @dev Removes a peer from the list of peers.
     */
    function leave() external isPeer nonReentrant {
        peers[msg.sender] = false;
        token.burnTokensOf(msg.sender);
        emit RemovePeer(msg.sender);
    }

    /**
     * @dev Returns the fee used to join the network.
     */
    function getFee() external view returns (uint256) {
        return _calcFee();
    }

    /**
     * @dev internal function to handle new peers
     */
    function _addPeer(address _peer, uint _value) internal nonReentrant {
        require(
            _peer != address(0),
            "You cannot add a peer with this address"
        );
        require(
            !peers[_peer],
            "Peer already joined the network"
        );
        peers[_peer] = true;

        if(_value > 0) {
            token.transfer(_peer, _value.div(100 gwei));
        }

        peerCount += 1;

        emit NewPeer(_peer);
    }

    /**
     * @dev internal function to handle new offers
     */
    function _createOffer(
        address[2] memory _tokens,
        uint256[2] memory _prices
    ) internal {
        // we don't need the next two check but let's do it anyways
        require(
            _tokens.length == 2,
            "You must specify 2 tokens"
        );
        require(
            _prices.length == 2,
            "You must specify 2 prices"
        );
        require(
            _prices[0] > 0,
            "Price must be greater than 0"
        );
        require(
            _prices[1] > 0,
            "Available token must be greater than 0"
        );
        require(
            _prices[0] < _prices[1], // TODO: calculate this IRL
            "Price must be less than available token"
        );

        Offer memory offer = Offer({
            price: _prices[0],
            peer: msg.sender,
            baseToken: _tokens[0],
            quoteToken: _tokens[1]
        });

        offers.push(offer);
        emit NewOffer(offer.peer, offer.price);
    }

    /** 
     * @dev internal function to set the peer token
     */
    function _setToken(address _token) internal {
        require(
            _token != address(0),
            "You must specify a token"
        );
        token = PeerToken(_token);
    }

    /**
     * @dev internal function to calculate the fee to join the network
     */
    function _calcFee() internal view returns (uint256) {
        return peerCount.mul(10 gwei); // entry fee increases as new peers join the network
    }
}