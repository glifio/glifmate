// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import {WFIL} from "shim/WFIL.sol";
import {PreStake} from "src/PreStake.sol";
import {PoolToken} from "src/PoolToken.sol";
import {IWFIL} from "src/Interfaces/IWFIL.sol";
import {IPoolToken} from "src/Interfaces/IPoolToken.sol";

contract BaseTest is Test {
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
    preStake = new PreStake(owner, IWFIL(address(wFIL)), IPoolToken(address(poolToken)));
    vm.startPrank(owner);
    poolToken.setMinter(address(preStake));
    vm.stopPrank();
  }
}
