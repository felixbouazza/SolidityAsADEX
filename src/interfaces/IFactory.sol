// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair);

    function getPair(address token0, address token1) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}