// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./IMintableERC20.sol";

interface IPair is IMintableERC20 {
    function mint(address to) external returns (uint);
    function burn(address to) external returns (uint, uint);
    function swap(address to) external returns (uint);
}