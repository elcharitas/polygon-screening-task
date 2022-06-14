// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PeerToken.sol";

/**
 * @title IPeerGovernor
 * @author elcharitas.dev - Jonathan Irhodia
 * @dev The PeerGovernor contract is used to manage the peers of the rinkeby network.
 * ------------------------------------------------------------------------------------
 * This contract was created by Jonathan Irhodia and is licensed under the MIT License.
 * It is created to be submitted for Polygon Screening Task.
 * The governor allows peers to exchange tokens at their own set prices.
 * ------------------------------------------------------------------------------------
 */
abstract contract IPeerGovernor is ReentrancyGuard {
    using SafeMath for uint256;

    event NewPeer(address peer);
    event RemovePeer(address peer);
    event NewOffer(address peer, uint256 offer);
    event RemoveOffer(address peer, uint256 offer);
    event NewTake(address peer, uint256 take);

    // offers indexed by id
    struct Offer {
        uint256 price;
        address peer;
        address baseToken;
        address quoteToken;
    }
    Offer[] public offers;

    // takes indexed by id
    struct Take {
        uint256 offerId;
        uint256 amount;
        address peer;
    }
    Take[] public takes;

    // standard token for all peers
    PeerToken public token;

    // peers management
    uint256 public peerCount;
    mapping(address => bool) public peers;

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
        // we don't need the next two checks but let's do it anyways
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
        emit NewOffer(offer.peer, offers.length - 1);
    }

    /**
     * @dev internal function to handle take an offers
     */
    function _takeOffer(uint256 _id, uint256 _value) internal nonReentrant {
        require(
            _id < offers.length,
            "Offer does not exist"
        );
        require(
            offers[_id].price <= _value,
            "You do not have enough tokens to take this offer"
        );
        require(
            offers[_id].peer != msg.sender,
            "You cannot take your own offer"
        );

        Take memory take = Take({
            offerId: _id,
            amount: _value,
            peer: msg.sender
        });

        takes.push(take);
        emit NewTake(take.peer, takes.length - 1);
    }

    /**
     * @dev internal function to handle accept takes
     */
    function _acceptTake(uint256 _id) internal nonReentrant {
        require(
            _id < takes.length,
            "Take does not exist"
        );
        require(
            takes[_id].peer != msg.sender,
            "You cannot accept your own take"
        );

        Take memory take = takes[_id];
        Offer memory offer = offers[take.offerId];

        require(
            offer.peer == msg.sender,
            "You cannot accept a take for another peer"
        );
        require(
            take.amount <= offer.price * take.amount,
            "You do not have enough tokens to accept this take"
        );

        ERC20 baseToken = ERC20(offer.baseToken);
        ERC20 quoteToken = ERC20(offer.quoteToken);

        baseToken.transfer(take.peer, offer.price * take.amount);
        quoteToken.transfer(offer.peer, take.amount);

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