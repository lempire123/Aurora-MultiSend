//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

/**
@title Aurora MultiSend Contract
@author Lance Henderson

@notice Contract allows sending Aurora tokens to 
multiple addresses in a single transaction.
*/

contract AuroraMultiSend {
    using SafeMath for uint256;

    // Hardcoded pointer to the aurora Token
    IERC20 public constant aurora = IERC20(0x8BEc47865aDe3B172A928df8f990Bc7f2A3b9f79);

    // Address of the auroraFoundation - has exclusive access to certain functions
    address public auroraFoundation;

    // Modifier to ensure caller is auroraFoundation
    modifier onlyFoundation() {
        require(msg.sender == auroraFoundation, "Access restricted to auroraFoundation");
        _;
    }

    /* ======== CONSTRUCTOR ======== */

    // @param _auroraFoundation Address of the auroraFoundation
    constructor(address _auroraFoundation) {
        auroraFoundation = _auroraFoundation;
    }

    /* ======== CORE FUNCTIONS ========= */

    // @notice Allows the foundation to deposit aurora tokens 
    // @param _amount Amount of aurora tokens to deposit
    function depositAuroraTokens(uint256 _amount) external onlyFoundation {
        require(aurora.balanceOf(msg.sender) >= _amount, "Specified amount > wallet balance");
        aurora.transferFrom(msg.sender, address(this), _amount);
    }

    // @notice Distributes the current balance of aurora tokens in the contract to the specified addresses
    // @param _addresses An array of addresses containing the recipients of the aurora tokens
    // @param _percentages An array of uints representing the percentage of aurora tokens corresponding to each address
    // @dev Eg. _addresses[0] will receive _percentages[0] percentage of the total aurora balance
    function multiSend(address[] _addresses, uint[] _percentages) external onlyFoundation {
        require(_addresses.length == _percentages.length, "Array lengths must be equal");
        uint256 totalBalance = auroraBalance();
        
        for(uint i; i < _addresses.length; i++) {
             require(_addresses[i] != address(0), "Invalid Address");
             require(_percentages[i] > 0, "Invalid Percentage");

             aurora.transfer(_addresses[i], totalBalance.mul(_percentages[i]).div(100)); // Assumes percentages range from 0-100
        }
    }

    /* ======== HELPER FUNCTIONS ======== */

    function auroraBalance() external view returns (uint256) {
        return aurora.balanceOf(address(this));
    }

}
