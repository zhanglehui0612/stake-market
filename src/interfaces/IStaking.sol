// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title Staking Interface
 */
interface IStaking {

    function stake()  payable external;


    function unstake(uint128 amount) external; 


    function claim() external;


    function balanceOf(address account) external view returns (uint128);

 
    function earned(address account) external view returns (uint128);
}