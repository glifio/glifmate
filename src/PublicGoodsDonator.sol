// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {FilAddress} from "shim/FilAddress.sol";
import {OwnedClaimable} from "shim/OwnedClaimable.sol";
import {IPreStake} from "src/Interfaces/IPreStake.sol";
import {IWFIL} from "src/Interfaces/IWFIL.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title PublicGoodsDonator
 * @author GLIF
 * @notice The PublicGoodsDonator contract is used as a proxy over the Infinity Pool to donate a % of iFIL tokens to public goods
 */
contract PublicGoodsDonator is OwnedClaimable {

  using FilAddress for address;

  event Donate(address indexed account, uint256 donationAmount);
  event WithdrawFunds(address indexed wallet, uint256 amount);

  /// @dev WAD is used to compute the split % to pg wallet
  uint256 immutable DENOM = 1e18;

  /// @dev modifier to ensure `donationPercentage` is 100% max
  modifier noOverDonations(uint256 donationPercentage) {
    if (donationPercentage > DENOM) {
      revert InvalidParams();
    }
    _;
  }

  IPreStake public immutable preStake;

  IWFIL private wFIL;
  IERC20 private iFIL;

  constructor(
    address _owner,
    IPreStake _preStake,
    IWFIL _wFIL,
    IERC20 _poolToken
  )
    OwnedClaimable(_owner)
  {
    preStake = _preStake;
    wFIL = _wFIL;
    iFIL = _poolToken;
  }

  /**
   * @notice Deposit WFIL into the PreStake contract
   * @param recipient The account to pull WFIL from and forward the iFIL tokens to
   * @param amount The amount of WFIL stake
   * @param donationPercent The percentage of the amount to split to the PG wallet. 100 = 100%
   */
  function deposit(
    address recipient,
    uint256 amount,
    uint256 donationPercent
  ) external noOverDonations(donationPercent) {
    // normalize the address in case of a FIL ID
    recipient = recipient.normalize();
    // pull in funds from msg.sender
    wFIL.transferFrom(msg.sender, address(this), amount);
    // approve the PreStake contract to spend our WFIL
    wFIL.approve(address(preStake), amount);
    // track before and after balance to compute how many tokens we got back
    uint256 preDepositBal = iFIL.balanceOf(address(this));
    // deposit WFIL into the PreStake contract
    preStake.deposit(address(this), amount);

    uint256 postDepositBal = iFIL.balanceOf(address(this));

    _donateIFIL(recipient, postDepositBal - preDepositBal, donationPercent);
  }

  /**
   * @notice Deposit `msg.value` native FIL tokens into the PreStake contract
   * @param recipient The account to prestake FIL and mint the iFIL tokens to
   * @param donationPercent The percentage of the amount to split to the PG wallet. 100 = 100%
   */
  function deposit(
    address recipient,
    uint256 donationPercent
  ) external payable noOverDonations(donationPercent) {
    // normalize the address in case of a FIL ID
    recipient = recipient.normalize();
    // track before and after balance to compute how many tokens we got back
    uint256 preDepositBal = iFIL.balanceOf(address(this));
    // deposit FIL into the PreStake contract
    preStake.deposit{value: msg.value}(address(this));

    uint256 postDepositBal = iFIL.balanceOf(address(this));

    _donateIFIL(recipient, postDepositBal - preDepositBal, donationPercent);
  }

  /// @dev computes amount of iFIL to forward to the recipient and transfers it
  function _donateIFIL(
    address recipient,
    uint256 newIFIL,
    uint256 donationPercent
  ) internal {
    // compute the amount to send on to the recipient
    uint256 passThroughAmount = newIFIL - (newIFIL * donationPercent / DENOM);

    iFIL.transfer(recipient, passThroughAmount);

    emit Donate(recipient, passThroughAmount);
  }

  /**
   * @notice Sends iFIL to the owner
   */
  function withdrawFunds() external onlyOwner {
    address owner = owner();
    uint256 amount = iFIL.balanceOf(address(this));
    iFIL.transfer(owner, amount);
    emit WithdrawFunds(owner, amount);
  }
}
