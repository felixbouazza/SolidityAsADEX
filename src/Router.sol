// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IRouter.sol";
import "./Factory.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPair.sol";

contract Router is IRouter {

    address public immutable factory;

    constructor(address factoryAddress) {
        factory = factoryAddress;
    }

    function addLiquidity(address token0, address token1, uint amount0, uint amount1, address to) external returns (uint) {
        require(token0 != address(0) && token1 != address(0), "Zero address");
        require(amount0 != 0 && amount1 != 0, "Zero amount");
        require(token0 != address(this) && token1 != address(this), "Invalid address");
        require(token0 != factory && token1 != factory, "Invalid address");

        (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);

        Factory factoryContract = Factory(factory);
        address pair = factoryContract.getPair(token0, token1);
        if(pair == address(0)) {
            pair = factoryContract.createPair(token0, token1);
        }

        bool successTransferToken0 = IERC20(token0).transferFrom(msg.sender, pair, amount0);
        require(successTransferToken0, "Transfer from error when trying to transfer token0");

        bool successTransferToken1 = IERC20(token1).transferFrom(msg.sender, pair, amount1); 
        require(successTransferToken1, "Transfer from error when trying to transfer token1");

        uint liquidity = IPair(pair).mint(to);
        return liquidity;
    }

    function removeLiquidity(address token0, address token1, uint liquidity, address to) external returns (uint, uint) {
        require(token0 != address(0) && token1 != address(0), "Zero address");
        require(liquidity != 0, "Zero liquidity");
        require(token0 != address(this) && token1 != address(this), "Invalid address");
        require(token0 != factory && token1 != factory, "Invalid address");

        (token0, token1) = token0 < token1 ? (token0, token1) : (token1, token0);

        Factory factoryContract = Factory(factory);
        address pair = factoryContract.getPair(token0, token1);
        require(pair != address(0), "Pair not found");

        bool successTransferLiquidity = IERC20(pair).transferFrom(msg.sender, pair, liquidity);
        require(successTransferLiquidity, "Transfer from error when trying to transfer liquidity");

        (uint amountToken0, uint amountToken1) = IPair(pair).mint(to);
        return (amountToken0, amountToken1);
    }

}