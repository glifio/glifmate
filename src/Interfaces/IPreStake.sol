// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IPreStake {

  function deposit(address recipient, uint256 amount) external;

  function deposit(address recipient) external payable;

  function convertFILtoWFIL() external;

  function approvePoolToTransfer(address pool, uint256 amount) external;
}
