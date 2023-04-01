// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {FilAddress} from "shim/FilAddress.sol";
import {OwnedClaimable} from "shim/OwnedClaimable.sol";
import {IPreStake} from "src/Interfaces/IPreStake.sol";
import {IWFIL} from "src/Interfaces/IWFIL.sol";
import {IPoolToken} from "src/Interfaces/IPoolToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title PublicGoodsDonator
 * @author GLIF
 * @notice The PublicGoodsDonator contract is used as a proxy over the Infinity Pool to donate a % of iFIL tokens to public goods
 */
contract PublicGoodsDonator is OwnedClaimable {

  using FilAddress for address;

  event Donate(address indexed account, uint256 donationAmount);
  event DistributePG(address indexed wallet, uint256 amount);

  event Pause();
  event Resume();

  /// @dev modifier to ensure `donationPercentage` is 100% max
  modifier noOverDonations(uint256 donationPercentage) {
    if (donationPercentage > WAD) {
      revert InvalidParams();
    }
    _;
  }

  /// @dev WAD is used to compute the split % to pg wallet
  uint256 immutable WAD = 1e18;

  address public pgWallet;
  IPreStake public preStake;

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
   * @param donationPercent The percentage of the amount to split to the PG wallet. 1e18 = 100%
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
    // track before and after balance to compute how many tokens we got back
    uint256 preDepositBal = iFIL.balanceOf(address(this));
    // deposit WFIL into the PreStake contract
    preStake.deposit(recipient, amount);

    uint256 postDepositBal = iFIL.balanceOf(address(this));

    _donateIFIL(recipient, postDepositBal, preDepositBal, donationPercent);
  }

  /**
   * @notice Deposit `msg.value` native FIL tokens into the PreStake contract
   * @param recipient The account to prestake FIL and mint the iFIL tokens to
   * @param donationPercent The percentage of the amount to split to the PG wallet. 1e18 = 100%
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
    preStake.deposit{value: msg.value}(recipient);

    uint256 postDepositBal = iFIL.balanceOf(address(this));

    _donateIFIL(recipient, postDepositBal, preDepositBal, donationPercent);
  }

  /// @dev computes amount of iFIL to forward to the recipient and transfers it
  function _donateIFIL(
    address recipient,
    uint256 postDepositBal,
    uint256 preDepositBal,
    uint256 donationPercent
  ) internal {
    // compute the amount to send on to the recipient
    uint256 passThroughAmount = (postDepositBal - preDepositBal) * donationPercent / WAD;

    iFIL.transfer(recipient, passThroughAmount);

    emit Donate(recipient, passThroughAmount);
  }

  /**
   * @notice Sends iFIL to the PG wallet
   * @param amount The amount of iFIL to send
   */
  function distributePG(uint256 amount) external onlyOwner {
    iFIL.transfer(pgWallet, amount);
    emit DistributePG(pgWallet, amount);
  }
}
