// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IRouter.sol";
import "./Factory.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPair.sol";

contract Router is IRouter {

    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
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

    function addETHLiquidity(address token0, uint amount0) external payable returns (uint) {
        require(token0 != address(0), "Zero Address");
        require(amount0 != 0, "Zero amount");
        require(token0 != address(this), "Invalid address");
        require(msg.value != 0, "Zero amount");
        require(token0 != factory && token0 != WETH, "Invalid address");

        IMintableERC20(WETH)._mint(address(this), msg.value);

        (token0, token1) = token0 < WETH ? (token0, WETH) : (WETH, token0);

        Factory factoryContract = Factory(factory);
        address pair = factoryContract.getPair(token0, token1);
        if(pair == address(0)) {
            pair = factoryContract.createPair(token0, token1);
        }

        if(token0 == WETH) {
            bool successTransfer = IERC20(token0).transfer(pair, msg.value);
            require(successTransfer, "Transfer error when trying to transfer WETH");
            
            bool successTransferToken1 = IERC20(token1).transferFrom(msg.sender, pair, amount1); 
            require(successTransferToken1, "Transfer from error when trying to transfer token1");
        } else {
            bool successTransfer = IERC20(token0).transferFrom(msg.sender, pair, amount0);
            require(successTransfer, "Transfer from error when trying to transfer token0");
            
            bool successTransferToken1 = IERC20(token1).transfer(pair, msg.value); 
            require(successTransferToken1, "Transfer error when trying to transfer WETH");
        }

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

        (uint amountToken0, uint amountToken1) = IPair(pair).burn(to);
        return (amountToken0, amountToken1);
    }

    function removeETHLiquidity(address token0, uint liquidity, address to) external returns (uint, uint) {
        require(token0 != address(0), "Zero address");
        require(liquidity != 0, "Zero liquidity");
        require(token0 != address(this), "Invalid address");
        require(token0 != factory, "Invalid address");

        (token0, token1) = token0 < WETH ? (token0, WETH) : (WETH, token0);

        Factory factoryContract = Factory(factory);
        address pair = factoryContract.getPair(token0, token1);
        require(pair != address(0), "Pair not found");

        bool successTransferLiquidity = IERC20(pair).transferFrom(msg.sender, pair, liquidity);
        require(successTransferLiquidity, "Transfer from error when trying to transfer liquidity");

        (uint amountToken0, uint amountToken1) = IPair(pair).burn(address(this));

        if(token0 == WETH) {
            (bool success, ) = payable(to).call{value: amountToken0}("");
            require(success, "Transfer error when trying to transfer ETH");

            IMintableERC20(WETH)._burn(address(this), amountToken0);
            IERC20(token1).transfer(to, amountToken1);
        } else {
            IERC20(token0).transfer(to, amountToken0);
    
            (bool success, ) = payable(to).call{value: amountToken1}("");
            require(success, "Transfer error when trying to transfer ETH");
            IMintableERC20(WETH)._burn(address(this), amountToken1);
        }
        return (amountToken0, amountToken1)
    }

    function swapTokenforToken(address token0, address token1, uint amount0In, uint amount1In, address to) external returns (uint) {
        require(token0 != address(0) && token1 != address(0), "Zero address");
        require(token0 != address(this) && token1 != address(this), "Invalid address");
        require(token0 != factory && token1 != factory, "Invalid address");
        require(amount0In == 0 || amount1In == 0, "Invalid amount");

        (token0, amount0In, token1, amount1In) = token0 < token1 ? (token0, amount0In, token1, amount1In) : (token1, amount1In, token0, amount0In);

        Factory factoryContract = Factory(factory);
        address pair = factoryContract.getPair(token0, token1);
        require(pair != address(0), "Pair not found");

        bool successTransfer;

        if(amount0In > 0) {
            successTransfer = IERC20(token0).transferFrom(msg.sender, pair, amount0In);
        } else {
            successTransfer = IERC20(token1).transferFrom(msg.sender, pair, amount1In);
        }

        require(successTransfer, "Transfer from error when trying to transfer token");

        return IPair(pair).swap(to);
    }

}