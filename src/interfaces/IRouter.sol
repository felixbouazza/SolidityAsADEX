// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IRouter {
    function transferFrom(address token, address from, address to, uint value) external;
    function addLiquidity(address token0, address token1, uint amount0, uint amount1) external;
}
