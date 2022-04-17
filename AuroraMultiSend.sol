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

contract AuroraMultiSend {
    using SafeMath for uint256;

    /* ======= STATE VARIABLES ======= */

    // Hardcoded pointer to the aurora Token
    IERC20 public constant aurora = IERC20(0x8BEc47865aDe3B172A928df8f990Bc7f2A3b9f79);

    // Address of the auroraFoundation - has exclusive access to certain functions
    address public auroraFoundation;

    // Stores whether contract is initialized or not
    bool initialized = false;

    // Addresses of the investors (recipients of the aurora tokens)
    address[] investors;

    // Percentage of aurora tokens corresponding to each investor
    // ie. Investor[i] gets percentages[i] percentage (percentages are out of 1000)
    uint256[] percentages;


    /* ========= MODIFIERS ======== */

    // Modifier to ensure caller is auroraFoundation
    modifier onlyFoundation() {
        require(msg.sender == auroraFoundation, "Access restricted to auroraFoundation");
        _;
    }

    // Modifier to ensure contract has been initialized
    modifier isInitialized() {
        require(initialized == true, "Contract not initialized");
        _;
    } 


    /* ======== CONSTRUCTOR ======== */

    // @param _auroraFoundation Address of the auroraFoundation
    constructor(address _auroraFoundation) {
        auroraFoundation = _auroraFoundation;
    }


    /* ========= INITIALIZE ========== */

     // @param _addresses An array of addresses containing the recipients of the aurora tokens
    // @param _percentages An array of uints representing the percentage of aurora tokens corresponding to each address
    // @dev Eg. _addresses[0] will receive _percentages[0] percentage of the total aurora balance
    function init(address[] memory _addresses, uint256[] memory _percentages) public onlyFoundation {
        require(initialized == false, "Contract already initialized");
        require(checkSum(_percentages), "Sum of percentages must not be greater than 1000"); // 1000 allows for 1 decimal place
        require(_addresses.length == _percentages.length, "Length of arrays must be equal");

        // Check that all addresses/percentages are valid
        for(uint i; i < _addresses.length; i++) {
            require(_addresses[i] != address(0), "Invalid Address");
            require(_percentages[i] > 0, "Invalid Percentage");
        }

        investors = _addresses;
        percentages = _percentages;

        initialized = true;

    }


    /* ======== DEPOSIT / WITHDRAW ========= */

    // @notice Allows the foundation to deposit aurora tokens 
    // @param _amount Amount to deposit
    function depositAuroraTokens(uint256 _amount) public onlyFoundation {
        require(aurora.balanceOf(msg.sender) >= _amount, "Specified amount > wallet balance");
        aurora.transferFrom(msg.sender, address(this), _amount);
    }

    // @notice Allows foundation to deposit and send aurora tokens in 1 tx
    function depositAndSend(uint256 _amount) external onlyFoundation {
        depositAuroraTokens(_amount);
        multiSend();
    }

    // @notice Allows the foundation to withdraw aurora tokens
    // @param _amount Amount to withdraw
    function withdrawAuroraTokens(uint256 _amount) external onlyFoundation {
        require(auroraBalance() >= _amount, "Specified amount > contract balance");
        aurora.transfer(msg.sender, _amount);
    }

    /* ======== MUTLISEND ========= */

    // @notice Distributes the current balance of aurora tokens in the contract to the specified addresses
    function multiSend() public onlyFoundation isInitialized {
        uint256 totalBalance = auroraBalance();
        
        for(uint i; i < investors.length; i++) {
             aurora.transfer(investors[i], totalBalance.mul(percentages[i]).div(1000)); // Assumes percentages range from 0-100
        }
    }

    /* ======== HELPER FUNCTIONS ======== */

    // Check aurora balance of the contract
    function auroraBalance() public view returns (uint256) {
        return aurora.balanceOf(address(this));
    }

    // Checks that the sum of the array is <= 100
    function checkSum(uint256[] memory _array) public pure returns (bool) {
        uint256 sum = 0;
        for (uint i = 0; i < _array.length; i++) {
            sum += _array[i];
        }
        return sum <= 1000;
    }

    // Returns list of investors
    function getInvestors() external view returns (address[] memory) {
        return investors;
    }

    // Returns list of percentages
    function getPercentages() external view returns (uint256[] memory) {
        return percentages;
    }

    /* ======== EDIT LIST OF INVESTORS ======= */

    // Allows foundation to change the list of investor addresses/percentages
    function updateInvestorList(
        address[] memory _addresses, 
        uint256[] memory _percentages) 
    external onlyFoundation isInitialized {
        initialized = false;
        init(_addresses, _percentages);
    }

}
