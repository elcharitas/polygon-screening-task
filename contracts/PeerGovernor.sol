// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IPeerGovernor.sol";
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
contract PeerGovernor is IPeerGovernor {
    using SafeMath for uint256;
    
    constructor(){
        _setToken(address(new PeerToken()));
        _addPeer(msg.sender, 1000 gwei);
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
     * @dev allows peers to take a peer up on an offer
     */
    function takeOffer(uint256 _id) external payable isPeer {
        _takeOffer(_id, msg.value);
    }

    /**
     * @dev allows peers to accept a take from another peer
     */
    function acceptTake(uint256 _id) external isPeer {
        _acceptTake(_id);
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
}