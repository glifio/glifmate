// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "./BaseTest.sol";

contract PreStakeTest is BaseTest {

  function testDepositFIL(uint256 depositAmount) public {
    depositAmount = bound(depositAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, depositAmount);
    vm.prank(staker);
    preStake.deposit{value: depositAmount}(staker);
    assertDepositFILSuccess(depositAmount);
  }

  function testSendFIL(uint256 depositAmount) public {
    depositAmount = bound(depositAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, depositAmount);
    vm.startPrank(staker);
    payable(address(preStake)).call{value: depositAmount}("");

    assertDepositFILSuccess(depositAmount);
  }

  function testDepositWFIL(uint256 depositAmount) public {
    depositAmount = bound(depositAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, depositAmount);
    vm.startPrank(staker);
    wFIL.deposit{value: depositAmount}();
    wFIL.approve(address(preStake), depositAmount);
    preStake.deposit(staker, depositAmount);

    assertDepositWFILSuccess(depositAmount);
  }

  function testConvertFILtoWFIL(uint256 depositAmount) public {
    depositAmount = bound(depositAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, depositAmount);
    vm.prank(staker);
    preStake.deposit{value: depositAmount}(staker);

    vm.prank(owner);
    preStake.convertFILtoWFIL();
    assertEq(wFIL.balanceOf(address(preStake)), depositAmount);
    assertEq(address(preStake).balance, 0);
  }

  function testApprovePoolToTransfer(uint256 depositAmount) public {
    depositAmount = bound(depositAmount, DUST, MAX_FIL_AMOUNT);
    address pool = makeAddr("pool");
    vm.deal(staker, depositAmount);
    vm.prank(staker);
    preStake.deposit{value: depositAmount}(staker);

    vm.startPrank(owner);
    preStake.convertFILtoWFIL();
    preStake.approvePoolToTransfer(pool, depositAmount);

    assertEq(wFIL.allowance(address(preStake), pool), depositAmount);

    vm.stopPrank();

    vm.prank(pool);
    wFIL.transferFrom(address(preStake), pool, depositAmount);
    assertEq(wFIL.balanceOf(pool), depositAmount);
    assertEq(wFIL.balanceOf(address(preStake)), 0);
  }

  function testTotalValueLocked(uint256 filDeposit, uint256 wfilDeposit) public {
    filDeposit = bound(filDeposit, DUST, MAX_FIL_AMOUNT / 2);
    wfilDeposit = bound(wfilDeposit, DUST, MAX_FIL_AMOUNT / 2);

    address pool = makeAddr("pool");
    vm.deal(staker, filDeposit + wfilDeposit);
    vm.startPrank(staker);
    // stake FIL
    preStake.deposit{value: filDeposit}(staker);

    wFIL.deposit{value: wfilDeposit}();
    wFIL.approve(address(preStake), wfilDeposit);
    preStake.deposit(staker, wfilDeposit);

    assertEq(preStake.totalValueLocked(), filDeposit + wfilDeposit);
  }

  function assertDepositFILSuccess(uint256 depositAmount) internal {
    assertEq(wFIL.balanceOf(address(preStake)), 0);
    assertEq(address(preStake).balance, depositAmount);
    assertEq(address(staker).balance, 0);
    assertEq(poolToken.balanceOf(staker), depositAmount);
  }

  function assertDepositWFILSuccess(uint256 depositAmount) internal {
    assertEq(wFIL.balanceOf(address(preStake)), depositAmount);
    assertEq(wFIL.balanceOf(address(staker)), 0);
    assertEq(address(preStake).balance, 0);
    assertEq(address(staker).balance, 0);
    assertEq(poolToken.balanceOf(staker), depositAmount);
  }
}
