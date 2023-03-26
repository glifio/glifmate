// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "forge-std/Test.sol";

library TokenIDs {

  error InvalidParams();

  // the left most 4 bits are used to store the hash index
  // currently we only use the first 2 bits (3 total NFT hashes)
  // but we separate out 4 bits in case we want to add more hashes later (8 max)
  uint256 constant private HASH_MASK = 0x8;
  // TOKEN_ID_MASK represents 2^252, with the leading 4 bits 0s to represent the hash index
  uint256 constant private TOKEN_ID_MASK = (type(uint256).max >> 4);

  /// @dev packs a metadata hash index and a token number into a single uint256
  /// @param tokenNumber the token number
  /// @param hashIndex the index of the hash in the hashes array + 1
  function packTokenID(
    uint256 hashIndex,
    uint256 tokenNumber
  ) internal pure returns (
    uint256 tokenID
  ) {
    // encode hash index in the token ID using 1-based numbering
    hashIndex = hashIndex + 1;
    if (
      // if our hash index is bigger than 8, or our token number is bigger than 2^(256 - 4)
      hashIndex > HASH_MASK ||
      !belowMintQuota(tokenNumber)
    ) revert InvalidParams();

    // shift the hash index to the left by 252 bits - the first 4 bits of the number are used to represent the hash index
    // OR the tokenNumber, leaving the resulting number with the first 4 bits representing the hash index and the remaining 252 bits representing the token number
    return (hashIndex << (256 - 4)) | tokenNumber;
  }

  function unpackTokenID(
    uint256 tokenID
  ) internal pure returns (
    uint256 hashIndex,
    uint256 tokenNumber
  ) {
    return (unpackHashIndex(tokenID), unpackTokenNumber(tokenID));
  }

  function unpackHashIndex(uint256 tokenID) internal pure returns (uint256 hashIndex) {
    // first 4 bits are used to store the hash index
    hashIndex = (tokenID >> 256 - 4) - 1;
  }

  function unpackTokenNumber(uint256 tokenID) internal pure returns (uint256 tokenNumber) {
    // the remaining 252 bits are used to store the token number
    tokenNumber = tokenID & TOKEN_ID_MASK;
  }

  function belowMintQuota(uint256 tokenNumber) internal pure returns (bool) {
    // we use - 1 from TOKEN_ID_MASK to avoid collisions in the 252nd bit
    return tokenNumber < TOKEN_ID_MASK - 1;
  }
}
