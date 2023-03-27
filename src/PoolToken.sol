// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC20} from "shim/ERC20.sol";
import {OwnedClaimable} from "shim/OwnedClaimable.sol";

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
    ) ERC20("Infinity Pool Staked FIL", "stFIL", 18) OwnedClaimable(_owner) {}

    /*//////////////////////////////////////////////////////////////
                            MINT/BURN TOKENS
    //////////////////////////////////////////////////////////////*/

    function mint(
        address account,
        uint256 amount
    ) external onlyMinter returns (bool) {
      _mint(account, amount);
      return true;
    }

    function burn(
        address account,
        uint256 _amount
    ) external onlyBurner returns (bool) {
      _burn(account, _amount);
      return true;
    }
    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    function setBurner(address _burner) external onlyOwner {
        burner = _burner;
    }
}
