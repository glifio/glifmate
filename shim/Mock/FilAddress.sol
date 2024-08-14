// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/**
 * @author fevmate (https://github.com/wadealexc/fevmate)
 * @notice MOCK utility functions for converting between id and
 * eth addresses. Helps implement address normalization.
 *
 */
library FilAddress {
    // Custom errors
    error CallFailed();
    error InvalidAddress();
    error InsufficientFunds();

    // Builtin Actor addresses (singletons)
    address constant SYSTEM_ACTOR = 0xfF00000000000000000000000000000000000000;
    address constant INIT_ACTOR = 0xff00000000000000000000000000000000000001;
    address constant REWARD_ACTOR = 0xff00000000000000000000000000000000000002;
    address constant CRON_ACTOR = 0xFF00000000000000000000000000000000000003;
    address constant POWER_ACTOR = 0xFf00000000000000000000000000000000000004;
    address constant MARKET_ACTOR = 0xff00000000000000000000000000000000000005;
    address constant VERIFIED_REGISTRY_ACTOR = 0xFF00000000000000000000000000000000000006;
    address constant DATACAP_TOKEN_ACTOR = 0xfF00000000000000000000000000000000000007;
    address constant EAM_ACTOR = 0xfF0000000000000000000000000000000000000a;

    // FEVM precompile addresses
    address constant RESOLVE_ADDRESS = 0xFE00000000000000000000000000000000000001;
    address constant LOOKUP_DELEGATED_ADDRESS = 0xfE00000000000000000000000000000000000002;
    address constant CALL_ACTOR = 0xfe00000000000000000000000000000000000003;
    // address constant GET_ACTOR_TYPE = 0xFe00000000000000000000000000000000000004; // (deprecated)
    address constant CALL_ACTOR_BY_ID = 0xfe00000000000000000000000000000000000005;

    address constant ZERO_ID_ADDRESS = SYSTEM_ACTOR;

    function normalize(address _a) internal view returns (address) {
        return _a;
    }

    function mustNormalize(address _a) internal view returns (address) {}

    // Used to clear the last 8 bytes of an address    (addr & U64_MASK)
    address constant U64_MASK = 0xFffFfFffffFfFFffffFFFffF0000000000000000;
    // Used to retrieve the last 8 bytes of an address (addr & MAX_U64)
    address constant MAX_U64 = 0x000000000000000000000000fFFFFFffFFFFfffF;

    function isIDAddress(address _a) internal pure returns (bool isID, uint64 id) {}

    function toAddress(uint64 _id) internal view returns (address) {}

    function toIDAddress(uint64 _id) internal pure returns (address addr) {}

    // An address with all bits set. Used to clean higher-order bits
    address constant ADDRESS_MASK = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    function getEthAddress(uint64 _id) internal view returns (bool success, address eth) {}

    function getActorID(address _eth) internal view returns (bool success, uint64 id) {}

    function sendValue(address payable _recipient, uint256 _amount) internal {
        if (address(this).balance < _amount) revert InsufficientFunds();

        (bool success,) = _recipient.call{value: _amount}("");
        if (!success) revert CallFailed();
    }

    function returnDataSize() private pure returns (uint256 size) {}
}
