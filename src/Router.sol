// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IRouter.sol";
import "./Factory.sol";
import "./Pair.sol";

contract Router is IRouter {

    address public immutable factory;

    constructor(address factoryAddress) {
        factory = factoryAddress;
    }

    function transferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(
                bytes4(keccak256(bytes('transferFrom(address,address,uint256)'))),
                to,
                value
            )
        );
        require(success && (data.length == 0), "Transfer from error");
    }

    function addLiquidity(address token0, address token1, uint amount0, uint amount1) external returns (uint) {
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
        transferFrom(token0, msg.sender, pair, amount0);
        transferFrom(token1, msg.sender, pair, amount1);
        uint liquidity = 1;
        return liquidity
        // uint liquidity = pair.mint(token0, token1, amount0, amount1);
        // return liquidity;
    }

}