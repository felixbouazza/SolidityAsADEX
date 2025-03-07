// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IPair {
    
    function mint(address to) external returns (uint);
    function burn(address to) external returns (uint, uint);
    function swap(address to) external returns (uint);
}