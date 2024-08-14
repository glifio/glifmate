// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "forge-std/Test.sol";

import {WFIL} from "shim/WFIL.sol";
import {PreStake} from "src/PreStake.sol";
import {PoolToken} from "src/PoolToken.sol";
import {PublicGoodsDonator} from "src/PublicGoodsDonator.sol";
import {IWFIL} from "src/Interfaces/IWFIL.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPreStake} from "src/Interfaces/IPreStake.sol";
import {IPoolToken} from "src/Interfaces/IPoolToken.sol";

contract BaseTest is Test {
  uint256 constant WAD = 1e18;
  uint256 constant DUST = 1_000;
  uint256 constant MAX_FIL_AMOUNT = 2_000_000_000e18;

  address owner = makeAddr("owner");
  address staker = makeAddr("staker");

  PreStake preStake;
  PoolToken poolToken;
  PublicGoodsDonator publicGoodsDonator;
  WFIL wFIL;

  function setUp() public {
    wFIL = new WFIL(owner);
    poolToken = new PoolToken(owner);
    preStake = new PreStake(owner, IWFIL(address(wFIL)), IPoolToken(address(poolToken)));
    publicGoodsDonator = new PublicGoodsDonator(
      owner,
      IPreStake(preStake),
      IWFIL(address(wFIL)),
      IERC20(address(poolToken))
    );
    vm.startPrank(owner);
    poolToken.setMinter(address(preStake));
    vm.stopPrank();
  }
}
