// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IFactory {
    function getPair(address token0, address token1) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}