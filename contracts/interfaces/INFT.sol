// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface INFT {
    function getKindByToken(uint256 token) external returns (uint256);
}
