// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import {TokenIDs} from "src/TokenIDs.sol";

contract PreStakeTest is Test {

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
