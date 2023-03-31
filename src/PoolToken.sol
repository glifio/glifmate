// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC20} from "shim/ERC20.sol";
import {OwnedClaimable} from "shim/OwnedClaimable.sol";

/**
 * @title PoolToken
 * @author GLIF
 * @notice The PoolToken contract is used to commit FIL tokens before the Infinity Pool is deployed
 */
contract PoolToken is ERC20, OwnedClaimable {
    address public minter;
    address public burner;

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyMinter() {
        if (msg.sender != minter) {
            revert Unauthorized();
        }
        _;
    }

    modifier onlyBurner() {
        if (msg.sender != burner) {
            revert Unauthorized();
        }
        _;
    }

    constructor(
        address _owner
    ) ERC20("Infinity Pool Staked FIL", "iFIL", 18) OwnedClaimable(_owner) {}

    /*//////////////////////////////////////////////////////////////
                            MINT/BURN TOKENS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints `amount` PoolTokens to `account`
     * @param account The account to mint to
     * @param amount The amount to mint
     */
    function mint(
        address account,
        uint256 amount
    ) external onlyMinter returns (bool) {
      _mint(account, amount);
      return true;
    }

    /**
     * @notice Burns `amount` PoolTokens from `account`
     * @param account The account to burn from
     * @param amount The amount to burn
     */
    function burn(
        address account,
        uint256 amount
    ) external onlyBurner returns (bool) {
      _burn(account, amount);
      return true;
    }

    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the address that can mint tokens. This is currently set to the PreStake contract
     * @param _minter The address of the minter
     *
     * Only the owner can call this, currently set to `PreStake`
     */
    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    /**
     * @notice Sets the address that can burn tokens.
     * The burn role is not yet assigned, it will be when the offramp launches
     */
    function setBurner(address _burner) external onlyOwner {
        burner = _burner;
    }
}
