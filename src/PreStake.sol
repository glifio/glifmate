// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {FilAddress} from "shim/FilAddress.sol";
import {OwnedClaimable} from "shim/OwnedClaimable.sol";
import {IWFIL} from "src/Interfaces/IWFIL.sol";
import {IPoolToken} from "src/Interfaces/IPoolToken.sol";

/**
 * @title PreStake
 * @author GLIF
 * @notice The PreStake contract is used to commit FIL tokens before the Infinity Pool is deployed
 */
contract PreStake is OwnedClaimable {

  using FilAddress for address;

  event Deposit(address indexed account, uint256 amount);
  event ApprovePool(address indexed pool, uint256 amount);

  IWFIL private wFIL;
  IPoolToken private poolToken;

  constructor(
    address _owner,
    IWFIL _wFIL,
    IPoolToken _poolToken
  )
    OwnedClaimable(_owner)
  {
    wFIL = _wFIL;
    poolToken = _poolToken;
  }

  receive() external payable {
    _deposit(msg.sender, msg.value);
  }

  fallback() external payable {
    _deposit(msg.sender, msg.value);
  }

  function totalValueLocked() external view returns (uint256) {
    return wFIL.balanceOf(address(this)) + address(this).balance;
  }

  /**
   * @notice Deposit WFIL into the PreStake contract
   * @param account The account to pull WFIL from and mint the iFIL tokens to
   * @param amount The amount of WFIL stake
   */
  function deposit(address account, uint256 amount) external {
    // pull in funds from msg.sender
    wFIL.transferFrom(msg.sender, address(this), amount);

    _deposit(account, amount);
  }

  /**
   * @notice Deposit `msg.value` native FIL tokens into the PreStake contract
   * @param account The account to prestake FIL and mint the iFIL tokens to
   */
  function deposit(address account) external payable {
    _deposit(account, msg.value);
  }

  function _deposit(address _account, uint256 _amount) internal {
    _account = _account.normalize();

    // transfer liquid staking tokens to the account 1:1 with the amount of FIL deposited
    poolToken.mint(_account, _amount);

    emit Deposit(_account, _amount);
  }

  /**
   * @notice Converts the contract's full FIL balance to WFIL
   */
  function convertFILtoWFIL() external onlyOwner {
    wFIL.deposit{value: address(this).balance}();
  }

  /**
   * @notice Approves the Infinity Pool to pull in the prestake deposits
   * @param pool The address of the Infinity Pool
   * @param amount The amount of WFIL to approve
   */
  function approvePoolToTransfer(address pool, uint256 amount) external onlyOwner {
    // here we approve the Pool to transferFrom the funds into the Pool
    // the staking tokens have already been distributed through this contract for the
    // pre-commitment deposits of funds, so no new tokens will be minted
    wFIL.approve(pool, amount);

    emit ApprovePool(pool, amount);
  }
}
