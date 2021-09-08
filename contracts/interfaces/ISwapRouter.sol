// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface ISwapRouter {
    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
