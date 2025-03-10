// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.28;

import "./IERC20.sol";

interface IMintableERC20 is IERC20 {
    function _mint(address to, uint value) external;
    function _burn(address to, uint value) external;
}
