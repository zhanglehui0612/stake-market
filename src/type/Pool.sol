// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Pool {
    // reward per share
    uint256 index;

    // all user accumulated stake total amount
    uint128 totalAmount;

    // current block
    uint256 blockNo;
}