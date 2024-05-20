// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "../src/type/Pool.sol";
import "../src/type/StakeInfo.sol";
import "../src/token/KK.sol";
import "../src//interfaces/StakeMarketInterfaces.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {StakeMarket} from "../src/StakeMarket.sol";
import {Test, console} from "forge-std/Test.sol";

contract StakeMarketTest is Test {

    StakeMarket market;
    KK kk;
    address owner;
    address alice;
    address bob;
    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        deal(alice, 100 ether);
        bob = makeAddr("bob");
        deal(bob, 100 ether);
        kk = new KK();
        market = new StakeMarket(address(kk));
    }

    function testStake() public {
        vm.startPrank(alice);
        vm.roll(1);
        market.stake{value: 1 ether}();
        assertEq(market.rewardsOf(), 0);

        vm.roll(2);
        market.stake{value: 2 ether}();
        assertEq(market.balanceOf(alice), 3 ether);
        assertEq(market.rewardsOf(), 10000000000000000000);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.roll(5);
        market.stake{value: 2 ether}();
        vm.roll(6);
        market.stake{value: 5 ether}();
        assertEq(market.rewardsOf(), 44000000000000000000);
        vm.stopPrank();
    }


    function testUnstake() public {
        vm.startPrank(alice);
        vm.roll(1);
        market.stake{value: 5 ether}();
        assertEq(market.rewardsOf(), 0);

        vm.roll(2);
        market.unstake(2 ether);
        assertEq(market.balanceOf(alice), 3 ether);
        assertEq(market.rewardsOf(), 10000000000000000000);
        vm.stopPrank();
    }

    function testClaim() public {
        vm.startPrank(alice);
        vm.roll(1);
        market.stake{value: 5 ether}();
        assertEq(market.rewardsOf(), 0);

        vm.roll(2);
        market.unstake(2 ether);
        assertEq(market.balanceOf(alice), 3 ether);
        assertEq(market.rewardsOf(), 10000000000000000000);

        market.claim();
        assertEq(KK(kk).balanceOf(alice), 16);
        vm.stopPrank();
    }


    function testBalanceOf() public {
        vm.startPrank(alice);
        vm.roll(1);
        market.stake{value: 5 ether}();
        assertEq(market.balanceOf(alice), 5 ether);
    }

     function testEarned() public {
        vm.startPrank(alice);
        vm.roll(1);
        market.stake{value: 5 ether}();
        assertEq(market.rewardsOf(), 0);

        vm.roll(2);
        market.unstake(2 ether);
        assertEq(market.balanceOf(alice), 3 ether);
        assertEq(market.rewardsOf(), 10000000000000000000);

        market.claim();
        assertEq(KK(kk).balanceOf(alice), 16);
        assertEq(market.earned(alice), 16);
        vm.stopPrank();
    }
}
