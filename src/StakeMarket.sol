// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./type/Pool.sol";
import "./type/StakeInfo.sol";
import "./token/KK.sol";
import "./interfaces/StakeMarketInterfaces.sol";
import "./interfaces/IStaking.sol";
import {ActionEnum} from "./enums/Enums.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";


contract StakeMarket is StakeMarketInterfaces, ReentrancyGuard, IStaking {
    address kk;

    mapping(address => StakeInfo) stakes;

    Pool pool;

    constructor(address _kk) {
        kk = _kk;
        pool = Pool(0, 0, 0);
    }

    /*
     * sender stake token
     * @param token
     * @param amount
     */
    function stake() external payable override {
        // update pool and staker info
        _updateRewards(ActionEnum.STAKE, uint128(msg.value));

        stakes[msg.sender].amount += uint128(msg.value);

        emit StakeEvent(msg.sender, uint128(msg.value));
    }

    /*
     * sender unstake token
     * @param token
     * @param amount
     */

    function unstake(uint128 amount) external override {
        if (amount <= 0) revert AmountMustGreaterThanZero();
        if (amount > stakes[msg.sender].amount)
            revert InvalidUnstakeAmount(amount, stakes[msg.sender].amount);

        // update pool and staker info
        _updateRewards(ActionEnum.UNSTAKE, amount);
        stakes[msg.sender].amount -= amount;

        msg.sender.call{value: amount}("");

        emit UnstakeEvent(msg.sender, amount);
    }

    /*
     * sender claim rewards
     * @param token
     */
    function claim() external override {
        _updateRewards(ActionEnum.CLAIM, 0);
        uint128 rewards = stakes[msg.sender].rewards;
        require(rewards > 0, "No rewards, not allow to claim");
        stakes[msg.sender].rewards = 0;
        KK(kk).mint(msg.sender, rewards / 1e18 == 0 ? 1 : rewards / 1e18);
        emit ClaimRewardEvent(msg.sender, rewards);
    }




     function earned(address account) external view override returns (uint128) {
        require(msg.sender == account, "Not allow query other's earned rewards");
        return uint128(KK(kk).balanceOf(account));
    }

    /*
     * return sender token rewards now
     * @param token
     */
    function rewardsOf() public returns (uint128) {
        return stakes[msg.sender].rewards;
    }

    /*
     * return sender token number of staking
     * @param token
     */
    function balanceOf(address account) external view override returns (uint128){
         require(msg.sender == account, "Not allow query other's stake balance");
        return stakes[msg.sender].amount;
    }

    /*
     * update pool and stake info, include pool block no update, accumulate pool totol state and sender rewards .etc
     * @param action
     * @param token
     * @param amount
     */
    function _updateRewards(
        ActionEnum action,
        uint128 amount
    ) internal nonReentrant {
        // update pool block no and stake amount if this token first was staked
        if (pool.totalAmount == 0 && pool.blockNo == 0) {
            // update block no
            pool.blockNo = block.number;

            // update amount
            if (action == ActionEnum.STAKE) {
                pool.totalAmount += amount;
            } else if (action == ActionEnum.UNSTAKE) {
                pool.totalAmount -= amount;
            }

            return;
        }

        // update pool index, totalStake and block no
        pool.index +=
            (1e18 * (block.number - pool.blockNo) * 10) /
            pool.totalAmount;
        if (action == ActionEnum.STAKE) {
            pool.totalAmount += amount;
        } else if (action == ActionEnum.UNSTAKE) {
            pool.totalAmount -= amount;
        }
        pool.blockNo = block.number;

        // if sender first stake the token, just need update index
        stakes[msg.sender].index = pool.index;
        // calculate and update staker rewards
        stakes[msg.sender].rewards += uint128(
            stakes[msg.sender].amount * stakes[msg.sender].index
        );
    }
}