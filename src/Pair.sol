// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IPair.sol";
import "./interfaces/IERC20.sol";
import "./ERC20.sol";

contract Pair is IPair, ERC20 {

    uint constant MINIMUM_LIQUIDITY = 10**3;

    address public factory;
    address public token0;
    address public token1;

    uint public reserve0;
    uint public reserve1;

    constructor(address _factory, address _token0, address _token1) {
        factory = _factory;
        token0 = _token0;
        token1 = _token1;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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
        return (1, 1);
    }
}