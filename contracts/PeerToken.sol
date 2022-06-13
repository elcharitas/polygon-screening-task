// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract PeerToken is ERC20, ERC20Burnable {
    address public governor;

    modifier isGovernor() {
        require(
            msg.sender == governor,
            "You are not the governor"
        );
        _;
    }

    constructor() ERC20("PeerToken", "PT") {
        governor = msg.sender;
        _mint(governor, 1000000 ether);
    }

    /**
     * @dev Allows the governor to burn tokens.
     */
    function burnTokensOf(address _peer) external isGovernor {
        _burn(_peer, balanceOf(_peer));
    }
}