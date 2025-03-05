// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interfaces/IPair.sol";

contract Pair is IPair {
    address public token0;
    address public token1;

    uint public reserve0;
    uint public reserve1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }
}