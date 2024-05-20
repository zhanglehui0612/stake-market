// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct StakeInfo {
    // reward per share
    uint256 index;
    
    // current user total stake amount
    uint128 amount;

    // user earned reward
    uint128 rewards;
}