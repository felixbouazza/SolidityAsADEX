// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IPair.sol";
import "./interfaces/IERC20.sol";
import "./ERC20.sol";
import "./Math.sol";

contract Pair is IPair, ERC20, Math {

    uint constant MINIMUM_LIQUIDITY = 10**3;

    address public factory;
    address public token0;
    address public token1;

    uint public reserve0;
    uint public reserve1;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    constructor(address _factory, address _token0, address _token1) {
        factory = _factory;
        token0 = _token0;
        token1 = _token1;
    }

    function mint(address to) external returns (uint) {
        require(to != address(0), "Zero address");
        
        uint amountToken0 = IERC20(token0).balanceOf(address(this));
        uint amountToken1 = IERC20(token1).balanceOf(address(this));

        require(amountToken0 > 0 && amountToken1 > 0, "Insufficient balance");
        require(amountToken0 - reserve0 > 0, "Insufficient balance");
        require(amountToken1 - reserve1 > 0, "Insufficient balance");

        uint liquidity;

        if(totalSupply == 0) {
            liquidity = sqrt(amountToken0 * amountToken1) - MINIMUM_LIQUIDITY;   
            _mint(address(this), MINIMUM_LIQUIDITY);
        } else {
            uint amount0 = amountToken0 * totalSupply / reserve0;
            uint amount1 = amountToken1 * totalSupply / reserve1;
            liquidity = amount0 < amount1 ? amount0 : amount1;
        }
        _mint(to, liquidity);

        reserve0 = reserve0 + amountToken0;
        reserve1 = reserve1 + amountToken1;

        emit Mint(to, amountToken0, amountToken1);

        return liquidity;
    }

    function burn(address to) external returns (uint, uint) {
        require(to != address(0), "Zero address");

        uint liquidity = balanceOf[address(this)];

        require(liquidity > 0, "Insufficient balance");

        uint amount0 = (liquidity * reserve0) / totalSupply; 
        uint amount1 = (liquidity * reserve1) / totalSupply;

        _burn(address(this), liquidity);

        IERC20(token0).transfer(to, amount0);
        IERC20(token1).transfer(to, amount1);

        reserve0 = reserve0 - amount0;
        reserve1 = reserve1 - amount1;

        emit Burn(to, amount0, amount1);

        return (amount0, amount1);
    }

    function swap(address to) external returns (uint) {

        require(to != address(0), "Zero address");
        
        uint currentBalanceToken0 = IERC20(token0).balanceOf(address(this));
        uint currentBalanceToken1 = IERC20(token1).balanceOf(address(this));

        uint amountInToken0 = currentBalanceToken0 - reserve0;
        uint amountInToken1 = currentBalanceToken1 - reserve1;

        require(amountInToken0 == 0 || amountInToken1 == 0, "Cannot swap");

        uint amountOut;

        if (amountInToken0 > 0) {
            uint amountInWithFee = amountInToken0 * 997;
            uint numerator = amountInWithFee * reserve1;
            uint denominator = (reserve0 * 1000) + amountInWithFee;
            amountOut = numerator / denominator;
            IERC20(token1).transfer(to, amountOut);
            reserve0 = currentBalanceToken0;
            reserve1 = currentBalanceToken1 - amountOut;
            emit Swap(msg.sender, amountInToken0, 0, 0, amountOut, to);
        } else {
            uint amountInWithFee = amountInToken1 * 997;
            uint numerator = amountInWithFee * reserve0;
            uint denominator = (reserve1 * 1000) + amountInWithFee;
            amountOut = numerator / denominator;
            IERC20(token0).transfer(to, amountOut);
            reserve0 = currentBalanceToken0 - amountOut;
            reserve1 = currentBalanceToken1;
            emit Swap(msg.sender, 0, amountInToken1, amountOut, 0, to);
        }

        return amountOut;
    }
}