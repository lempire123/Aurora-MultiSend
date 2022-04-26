//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

/**
@title Aurora MultiSend Contract
@author Lance Henderson

@notice Contract allows sending any ERC20 token to 
multiple addresses in a single transaction.

*/

contract MultiSend {
    using SafeMath for uint256;

    /* ======= STATE VARIABLES ======= */

    // Address of the admin - has exclusive access to certain functions
    address public admin;
    
    /* ========= MODIFIER ======== */

    // Modifier to ensure caller is admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Access restricted to admin");
        _;
    }

    /* ======== CONSTRUCTOR ======== */

    // @param _underlying Token to distribute
    // @param _admin Address with exclusive access
    constructor(address _admin) {
        admin = _admin;
    }

    /* ======== MUTLISEND ========= */
    
    // @param _recipients Array of addresses who will receive the underlying
    // @param _amounts The corresponding amount of underlying each address will receive
    // @param _sum Total sum of underlying to distribute
    // Eg. _recipients[i] will recieve _amounts[i] of underlying
    // @dev Prior to calling multiSend, Sender must give allowance to the contract for transferring the tokens
    function multiSend(address _underlying, address[] memory _recipients, uint256[] memory _amounts) external onlyAdmin {
        require(_recipients.length == _amounts.length, "Array lengths must be equal");

        IERC20 underlying = IERC20(_underlying);

        for(uint i; i < _recipients.length; i++) {
            require(_recipients[i] != address(0), "Invalid Address");
            require(_amounts[i] > 0, "Invalid Amount");
            
            underlying.transferFrom(msg.sender, _recipients[i], _amounts[i]);
        }
    }

    /* ====== MUTATIVE FUNCTION ======= */

    // @notice Allows the admin to change the admin address
    // @param _newAdmin Address of the new admin
    function changeAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid Address");
        admin = _newAdmin;
    }
    
}
