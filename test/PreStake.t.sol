// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import {WFIL} from "shim/WFIL.sol";
import {PreStake} from "src/PreStake.sol";
import {PoolToken} from "src/PoolToken.sol";

contract PreStakeTest is Test {
  uint256 constant DUST = 1_000;
  uint256 constant MAX_FIL_AMOUNT = 2_000_000_000e18;

  address owner = makeAddr("owner");
  address staker = makeAddr("staker");

  PreStake preStake;
  PoolToken poolToken;
  WFIL wFIL;

  function setUp() public {
    wFIL = new WFIL(owner);
    poolToken = new PoolToken(owner);
    preStake = new PreStake(owner, address(wFIL), address(poolToken));
    vm.startPrank(owner);
    poolToken.setMinter(address(preStake));
    preStake.open();
    vm.stopPrank();
  }

  function testStakeFIL(uint256 stakeAmount) public {
    stakeAmount = bound(stakeAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, stakeAmount);
    vm.prank(staker);
    preStake.deposit{value: stakeAmount}(staker);
    assertDepositFILSuccess(stakeAmount);
  }

  function testSendFIL(uint256 stakeAmount) public {
    stakeAmount = bound(stakeAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, stakeAmount);
    vm.startPrank(staker);
    payable(address(preStake)).call{value: stakeAmount}("");

    assertDepositFILSuccess(stakeAmount);
  }

  function assertDepositFILSuccess(uint256 stakeAmount) internal {
    assertEq(wFIL.balanceOf(address(preStake)), 0);
    assertEq(address(preStake).balance, stakeAmount);
    assertEq(address(staker).balance, 0);
    assertEq(poolToken.balanceOf(staker), stakeAmount);
  }
}
