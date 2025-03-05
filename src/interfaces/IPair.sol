// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IPair {
    event Mint(address indexed sender, uint amount0, uint amount1);
    
    function mint(address to) external returns (uint);
    function burn(address to) external returns (uint, uint);
}