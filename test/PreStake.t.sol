// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import {WFIL} from "shim/WFIL.sol";
import {PreStake} from "src/PreStake.sol";
import {TokenIDs} from "src/TokenIDs.sol";
import {PoolToken} from "src/PoolToken.sol";

contract PreStakeTest is Test {
  uint256 constant DUST = 1_000;
  uint256 constant MAX_FIL_AMOUNT = 2_000_000_000e18;

  address owner = makeAddr("owner");
  address operator = makeAddr("operator");
  address staker = makeAddr("staker");

  string[3] hashes = [
    "bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55123", "bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55456", "bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55789"
  ];

  PreStake preStake;
  PoolToken poolToken;
  WFIL wFIL;

  // struct Log {
  //   bytes32[] topics;
  //   bytes data;
  // }

  function setUp() public {
    wFIL = new WFIL(owner);
    poolToken = new PoolToken(owner, operator);
    preStake = new PreStake(owner, operator, address(wFIL), address(poolToken), hashes);
    vm.startPrank(owner);
    preStake.open();
    poolToken.setMinter(address(preStake));
    vm.stopPrank();
  }

  function testStakeFIL(uint256 stakeAmount) public {
    stakeAmount = bound(stakeAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, stakeAmount);
    vm.prank(staker);
    uint256 tokenID = preStake.stake{value: stakeAmount}(staker);
    assertStakeFILSuccess(stakeAmount, tokenID);
  }

  function testSendFIL(uint256 stakeAmount) public {
    stakeAmount = bound(stakeAmount, DUST, MAX_FIL_AMOUNT);
    vm.deal(staker, stakeAmount);
    vm.startPrank(staker);
    vm.recordLogs();
    payable(address(preStake)).call{value: stakeAmount}("");
    // get the tokenID through event logs
    Vm.Log[] memory logs = vm.getRecordedLogs();
    Vm.Log memory stakeLog = logs[logs.length - 1];
    uint256 tokenID = uint256(stakeLog.topics[2]);

    assertStakeFILSuccess(stakeAmount, tokenID);
  }

  function assertStakeFILSuccess(uint256 stakeAmount, uint256 tokenID) internal {
    assertEq(wFIL.balanceOf(address(preStake)), 0);
    assertEq(address(preStake).balance, stakeAmount);
    assertEq(address(staker).balance, 0);
    assertEq(preStake.preStakeDeposits(staker), stakeAmount);
    assertEq(poolToken.balanceOf(staker), stakeAmount);
    assertEq(preStake.ownerOf(tokenID), staker);

    if (stakeAmount < preStake.limits(0)) {
      assertEq(preStake.tokenURI(tokenID), string(abi.encodePacked(preStake.baseURI(), hashes[0])));
    } else if (stakeAmount < preStake.limits(1)) {
      assertEq(preStake.tokenURI(tokenID), string(abi.encodePacked(preStake.baseURI(), hashes[1])));
    } else {
      assertEq(preStake.tokenURI(tokenID), string(abi.encodePacked(preStake.baseURI(), hashes[2])));
    }
  }
}

contract TokenIDsTest is Test {

  using TokenIDs for uint256;

  function testTokenIDs(uint256 hashIndex, uint256 tokenID) public {
    // can't have 0 hash index, hash index starts at 1
    hashIndex = bound(hashIndex, 0, 7);
    // can't have 0 tokenID, tokenID starts at 1
    tokenID = bound(tokenID, 1, 2**252 - 1);

    uint256 tokenID = 1;
    uint256 packed = TokenIDs.packTokenID(hashIndex, tokenID);
    (uint256 unpackedHashIndex, uint256 unpackedTokenID) = packed.unpackTokenID();
    assertEq(unpackedTokenID, tokenID);
    assertEq(unpackedHashIndex, hashIndex);
  }
}
