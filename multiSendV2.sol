//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

/**
@title Aurora MultiSend Contract
@author Lance Henderson

@notice Contract allows sending Aurora tokens to 
multiple addresses in a single transaction.

*/

contract MultiSend {

     /* ======= STATE VARIABLES ======= */

    // Underlying token to distribute
    IERC20 public underlying;

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

    constructor(address _underlying, address _admin) {
        underlying = IERC20(_underlying);
        admin = _admin;
    }


    /* ======== MUTLISEND ========= */
    
    // @param _recipients Array of addresses who will receive the underlying
    // @param _amounts The corresponding amount of underlying each address will receive
    // @param _sum Total sum of underlying to distribute
    // Eg. _recipients[i] will recieve _amounts[i] of underlying
    function multiSend(address[] memory _recipients, uint256[] memory _amounts, uint256 _sum) external onlyAdmin {
        require(_recipients.length == _amounts.length, "Array lengths must be equal");
        require(checkSum(_amounts) == _sum, "Sum of amounts != Total sum");
        require(underlying.balanceOf(msg.sender) >= _sum, "Wallet balance not sufficient");

        underlying.transferFrom(msg.sender, address(this), _sum);

        for(uint i; i < _recipients.length; i++) {
            require(_recipients[i] != address(0), "Invalid Address");
            require(_amounts[i] > 0, "Invalid Percentage");
            
            underlying.transfer(_recipients[i], _amounts[i]);
        }

    }

    /* ======== HELPER FUNCTION ======== */

    // Calculates and returns the sum of the array
    function checkSum(uint256[] memory _array) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint i = 0; i < _array.length; i++) {
            sum += _array[i];
        }
        return sum;
    }

    /* ====== MUTATIVE FUNCTION ======= */

    // @notice Allows the admin to change the address of the underlying token
    // @param _underlying Address of the new token
    function changeUnderlying(address _underlying) external onlyAdmin {
        underlying = IERC20(_underlying);
    }

    // @notice Allows the admin to change the admin address
    // @param _newAdmin Address of the new admin
    function changeAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid Address");
        admin = _newAdmin;
    }
    
}
