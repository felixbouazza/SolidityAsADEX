// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IRouter {
    function addLiquidity(address token0, address token1, uint amount0, uint amount1, address to) external returns (uint);
    function removeLiquidity(address token0, address token1, uint liquidity, address to) external returns (uint amount0, uint amount1);
    function swapTokenforToken(address token0, address token1, uint amount0In, uint amount1In, address to) external returns (uint);
}
