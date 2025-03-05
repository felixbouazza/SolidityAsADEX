// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IERC20.sol";

// contract ERC20 is IERC20 {
contract ERC20 {

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply + value;
        balanceOf[to] = balanceOf[to] + value;
    }

    function _burn(address to, uint value) internal {
        balanceOf[to] = balanceOf[to] - value;
        totalSupply = totalSupply - value;
    }

    // function name() external view returns (string memory);
    // function symbol() external view returns (string memory);
    // function decimals() external view returns (uint8);
    // function totalSupply() external view returns (uint);
    // function balanceOf(address owner) external view returns (uint);
    // function allowance(address owner, address spender) external view returns (uint);

    // function approve(address spender, uint value) external returns (bool);
    // function transfer(address to, uint value) external returns (bool);
    // function transferFrom(address from, address to, uint value) external returns (bool);

}