// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IMintableERC20.sol";
import "./ERC20.sol";

contract MintableERC20 is IMintableERC20, ERC20 {
    function _mint(address to, uint value) internal {
        totalSupply = totalSupply + value;
        balanceOf[to] = balanceOf[to] + value;
    }

    function _burn(address to, uint value) internal {
        balanceOf[to] = balanceOf[to] - value;
        totalSupply = totalSupply - value;
    }
}