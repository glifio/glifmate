// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {FilAddress} from "shim/FilAddress.sol";
import {ERC721} from "shim/ERC721.sol";
import {Operatable} from "src/Operatable.sol";
import {TokenIDs} from "src/TokenIDs.sol";
import {IWFIL} from "src/Interfaces/IWFIL.sol";
import {IPoolToken} from "src/Interfaces/IPoolToken.sol";

contract PreStake is ERC721, Operatable {

  using FilAddress for address;
  using TokenIDs for uint256;

  error MintLimit();

  IWFIL private wFIL;
  IPoolToken private poolToken;

  string public _baseURI = "https://meta.glif.io";
  string[3] public hashes;
  uint256[2] public limits;

  // the first NFT has token ID 1
  uint256 public mintCount = 1;

  mapping(address => uint256) public preStakeDeposits;

  bool public isOpen = false;

  modifier underMintCount() {
    if (!mintCount.belowMintQuota()) {
      revert MintLimit();
    }
    _;
  }

  constructor(
    address _owner,
    address _operator,
    address _wFIL,
    address _poolToken,
    string[3] memory _hashes
  )
    ERC721("Infinity Pool PreStake Badges", unicode"♾️")
    Operatable(_owner, _operator)
  {
    wFIL = IWFIL(_wFIL);
    poolToken = IPoolToken(_poolToken);
    hashes = _hashes;

    limits[0] = 1_000e18;
    limits[1] = 15_000e18;
  }

  function tokenURI(uint256 tokenID) public view override returns (string memory) {
    return string(abi.encodePacked(_baseURI, hashes[tokenID.unpackHashIndex()]));
  }

  function setBaseURI(string memory baseURI) external onlyOwnerOperator {
    _baseURI = baseURI;
  }

  function deposit(address account, uint256 amount) external underMintCount {
    if (amount == 0) revert InvalidParams();
    // pull in funds from msg.sender
    wFIL.transferFrom(msg.sender, address(this), amount);

    _deposit(account, amount);
  }

  function deposit(address account) external payable underMintCount {
    if (msg.value == 0) revert InvalidParams();

    _deposit(account, msg.value);
  }

  function _deposit(address _account, uint256 _amount) internal {
    _account = _account.normalize();

    uint8 hashIndex = 0;
    // find out which tier deposit this is
    while (_amount > limits[hashIndex]) {
      hashIndex++;
      if (amountToCheck <= limits[hashIndex]) {
        break;
      }
    }

    preStakeDeposits[_account] += _amount;

    uint256 tokenID = TokenIDs.packTokenID(mintCount, hashIndex);
    mintCount++;
    // mint the NFT to the depositor
    _mint(_account, tokenID);
    // transfer liquid staking tokens to the account 1:1 with the amount of FIL deposited
    poolToken.mint(_account, _amount);
  }

  function flushToPool(address pool) external onlyOwnerOperator {
    wFIL.deposit{value: address(this).balance}();
    uint256 wFILBal = wFIL.balanceOf(address(this));
    // here we simply transfer the funds into the Pool so that we don't invoke
    // the minting of any new liquid staking tokens in the pool
    // the staking tokens have already been distributed through this contract for the
    // pre-commitment deposits of funds
    wFIL.transfer(pool, wFILBal);
  }

  function open() external onlyOwnerOperator {
    isOpen = true;
  }

  function close() external onlyOwnerOperator {
    isOpen = false;
  }
}
