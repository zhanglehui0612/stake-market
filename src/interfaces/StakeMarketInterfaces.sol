// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface StakeMarketInterfaces {

    error AmountMustGreaterThanZero();
    
    error InvalidUnstakeAmount(uint128 unstakeAmount, uint128 actualAmount);

    error InvalidUnstakeETHAmount(uint128 unstakeETHAmount, uint128 actualETHAmount);

    error ETHAmountNotEnough(uint128 ethAmount, uint128 minEthAmount);

    error ClaimFailed(address account, uint128 rewards);
    
    event StakeEvent(address indexed staker, uint128 indexed amount);

    event StakeETHEvent(address indexed staker, uint128 indexed amount);

    event UnstakeEvent(address indexed unstaker, uint128 indexed amount);

    event UnstakeETHEvent(address indexed unstaker, uint128 indexed amount);

    event ClaimRewardEvent(address indexed staker, uint128 indexed amount);

    event WithdrawEvent(address indexed staker, address indexed token, uint128 indexed amount);
}