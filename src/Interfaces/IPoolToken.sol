// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @dev PoolToken defines the additional functions an IPoolToken must extend in additon
        to the ERC20 interface to include minting and burning.
 */
interface IPoolToken {

    /**
     * @dev Mints PoolTokens. Protected call.
     */
    function mint(address account, uint256 amount) external returns (bool);
    /**
     * @dev Burns PoolTokens. Protected call.
     */
    function burn(address account, uint256 amount) external returns (bool);

    /**
     * @dev Sets the address that can mint tokens. This is currently set to the PreStake contract
     */
    function setMinter(address minter) external;

    /**
     * @dev Sets the address that can burn tokens. The burn role is not yet assigned, it will be when the on ramp launches
     */
    function setBurner(address minter) external;
}
