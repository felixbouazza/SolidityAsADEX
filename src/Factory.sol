// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IFactory.sol";
import "./Pair.sol";

contract Factory is IFactory {
    mapping (address => mapping(address => address)) public pairs;

    function getPair(address token0, address token1) external view returns (address) {
        return pairs[token0][token1];
    }
    function createPair(address token0, address token1) external returns (address) {
        Pair pair = new Pair(token0, token1);
        address pairAddress = address(pair);
        pairs[token0][token1] = pairAddress;
        pairs[token1][token0] = pairAddress;
        return pairAddress;
    }
}