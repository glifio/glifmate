// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import {IAuth} from "src/Interfaces/IAuth.sol";

import "./BaseTest.sol";

contract PublicGoodsDonatorTest is BaseTest {

  function testDepositSimple() public {
    uint256 depositAmount = 10e18;
    uint256 WAD = 1e18;
    uint256 donationPercentage = .50e18; // 50%
    vm.deal(staker, depositAmount);
    vm.prank(staker);
    publicGoodsDonator.deposit{value: depositAmount}(staker, donationPercentage);

    assertEq(
      poolToken.balanceOf(staker),
      5e18,
      "staker should have IFIL equal to deposit amount minus donation"
    );
    assertEq(
      poolToken.balanceOf(address(publicGoodsDonator)),
      5e18,
      "staker should have IFIL equal to deposit amount minus donation"
    );
    assertDepositSuccess(depositAmount, donationPercentage);
  }

  function testDepositFIL(uint256 depositAmount, uint256 donationPercentage) public {
    donationPercentage = bound(donationPercentage, 0, 1e18);
    depositAmount = bound(depositAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, depositAmount);
    vm.prank(staker);
    publicGoodsDonator.deposit{value: depositAmount}(staker, donationPercentage);

    assertDepositSuccess(depositAmount, donationPercentage);
  }

  function testDepositWFIL(uint256 depositAmount, uint256 donationPercentage) public {
    donationPercentage = bound(donationPercentage, 0, 1e18);
    depositAmount = bound(depositAmount, DUST, MAX_FIL_AMOUNT);
    _loadWFIL(depositAmount);
    vm.startPrank(staker);
    publicGoodsDonator.deposit(staker, depositAmount, donationPercentage);

    assertDepositSuccess(depositAmount, donationPercentage);
  }

  function testWithdrawFunds(
    uint256 depositAmount,
    uint256 donationPercentage
  ) public {
    donationPercentage = bound(donationPercentage, 0, 1e18);
    depositAmount = bound(depositAmount, DUST, 1e41);
    _loadWFIL(depositAmount);
    vm.deal(staker, depositAmount);

    vm.startPrank(staker);
    publicGoodsDonator.deposit{value: depositAmount / 2}(staker, donationPercentage);
    publicGoodsDonator.deposit(staker, depositAmount / 2, donationPercentage);
    vm.stopPrank();

    uint256 preWithdrawPGDonatorBal = poolToken.balanceOf(address(publicGoodsDonator));
    address publicGoodsDonatorOwner = IAuth(address(publicGoodsDonator)).owner();
    vm.prank(publicGoodsDonatorOwner);
    publicGoodsDonator.withdrawFunds();

    assertEq(
      poolToken.balanceOf(publicGoodsDonatorOwner),
      preWithdrawPGDonatorBal,
      "Public goods donator owner should have IFIL equal to donated funds"
    );

    assertApproxEqAbs(
      poolToken.balanceOf(publicGoodsDonatorOwner),
      depositAmount * donationPercentage / WAD,
      DUST,
      "Public goods donator owner should have IFIL equal to deposited amount times donation percentage"
    );
  }

  function testChangeOwnership(string calldata newOwnerSeed) public {
    address newOwner = makeAddr(newOwnerSeed);
    IAuth pgDonatorAuth = IAuth(address(publicGoodsDonator));

    vm.prank(owner);
    pgDonatorAuth.transferOwnership(newOwner);
    vm.prank(newOwner);
    pgDonatorAuth.acceptOwnership();
    assertEq(
      pgDonatorAuth.owner(),
      newOwner,
      "Public goods donator owner should be new owner"
    );
  }

  function assertDepositSuccess(uint256 depositAmount, uint256 donationPercentage) internal {
    assertEq(
      poolToken.balanceOf(staker),
      depositAmount - ((depositAmount * donationPercentage) / WAD),
      "staker should have IFIL equal to deposit amount minus donation"
    );
    assertEq(
      poolToken.balanceOf(address(publicGoodsDonator)),
      depositAmount * donationPercentage / WAD,
      "Public goods donator should have IFIL equal to donation"
    );

    // invariants
    assertEq(
      poolToken.totalSupply(),
      poolToken.balanceOf(staker) + poolToken.balanceOf(address(publicGoodsDonator)),
      "total supply should be equal to staker's IFIL"
    );
    assertEq(
      poolToken.balanceOf(address(publicGoodsDonator)),
      depositAmount - poolToken.balanceOf(staker),
      "Public goods donator should have IFIL equal to donation"
    );
    assertEq(wFIL.balanceOf(address(staker)), 0, "staker should not have any wFIL");
  }

  function _loadWFIL(uint256 depositAmount) internal {
    vm.deal(staker, depositAmount);
    vm.startPrank(staker);
    wFIL.deposit{value: depositAmount}();
    wFIL.approve(address(publicGoodsDonator), depositAmount);
    vm.stopPrank();
  }
}
