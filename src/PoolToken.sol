// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC20} from "shim/ERC20.sol";
// import {IPoolTokenPlus} from "src/Types/Interfaces/IPoolTokenPlus.sol";
import {Operatable} from "src/Operatable.sol";

contract PoolToken is ERC20, Operatable {
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
        address _owner,
        address _operator
    ) ERC20("Infinity Pool Staked FIL", unicode"♾️FIL", 18) Operatable(_owner, _operator) {}

    /*//////////////////////////////////////////////////////////////
                            MINT/BURN TOKENS
    //////////////////////////////////////////////////////////////*/

    function mint(
        address account,
        uint256 _amount
    ) external onlyMinter returns (bool) {
      _mint(account, _amount);
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

    function setMinter(address _minter) external onlyOwnerOperator {
        minter = _minter;
    }

    function setBurner(address _burner) external onlyOwnerOperator {
        burner = _burner;
    }
}
