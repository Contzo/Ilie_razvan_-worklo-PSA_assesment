// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SalaryDistributor is Ownable {
    /*//////////////////////////////////////////////////////////////
                            State variables
    //////////////////////////////////////////////////////////////*/
    mapping(address payer => bool isAuthorized) s_authorizedPayers;
    // 1 = not paused, 2 = paused
    uint256 s_paused;

    /*//////////////////////////////////////////////////////////////
                                 Errors
    //////////////////////////////////////////////////////////////*/
    error SalaryDistributor__Paused();
    error SalaryDistributor__UnauthorizedPayer();
    error SalaryDistributor__MissingRecipientsToAmounts();
    error SalaryDistributor__EmptyBatch();
    error SalaryDistributor__InsufficientBalance();
    error SalaryDistributor__ZeroAmount();
    error SalaryDistributor__ZeroRecipientAddress();
    error SalaryDistributor__ZeroPayerAddress();
    error SalaryDistributor__TransferFailed(address recipient, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                 Events
    //////////////////////////////////////////////////////////////*/
    event PayerAdded(address indexed payer);
    event PaymentPaused();
    event PaymentUnpaused();
    event Distributed(address indexed recipient, uint256 amount);
    event BatchCompleted(uint256 totalAmount, uint256 recipientCount);

    /*//////////////////////////////////////////////////////////////
                               Modifiers
    //////////////////////////////////////////////////////////////*/
    modifier isPaused() {
        _isPaused();
        _;
    }

    modifier isAuthorizedPayer(address _payer) {
        _isAuthorizedPayer(_payer);
        _;
    }

    constructor() Ownable(msg.sender) {
        s_paused = 1;
    }

    /*//////////////////////////////////////////////////////////////
                           External functions
    //////////////////////////////////////////////////////////////*/

    function distribute(address[] calldata _recipients, uint256[] calldata _amounts)
        external
        payable
        isPaused
        isAuthorizedPayer(msg.sender)
    {
        // ── Checks ───────────────────────────────
        _validateBatch(_recipients, _amounts);
        // ── Effects ───────────────────────────────
        uint256 totalAmount = _getTotalAmountForBatch(_amounts);
        uint256 len = _recipients.length;
        _distribute(_recipients, _amounts);
        _handleRefunds(_amounts);
        emit BatchCompleted(totalAmount, len);
    }

    /// @notice External function to add a new payer
    /// @dev Can only be called by the owner
    /// @param _newPayer The address of the new payer
    function setPayer(address _newPayer) external onlyOwner isPaused {
        if (_newPayer == address(0)) revert SalaryDistributor__ZeroPayerAddress();
        s_authorizedPayers[_newPayer] = true;
        emit PayerAdded(_newPayer);
    }

    /// @notice External function to pause the contract
    /// @dev Can only be called by the owner
    function pause() external onlyOwner {
        s_paused = 2;
        emit PaymentPaused();
    }

    /// @notice External function to unpause the contract
    /// @dev Can only be called by the owner
    function unpause() external onlyOwner {
        s_paused = 1;
        emit PaymentUnpaused();
    }

    /*//////////////////////////////////////////////////////////////
                                Getters
    //////////////////////////////////////////////////////////////*/
    function getAuthorizedPayer(address _payer) external view returns (bool) {
        return s_authorizedPayers[_payer];
    }

    function getPaused() external view returns (uint256) {
        return s_paused;
    }

    /*//////////////////////////////////////////////////////////////
                           Internal functions
    //////////////////////////////////////////////////////////////*/

    function _isPaused() internal view {
        if (s_paused == 2) revert SalaryDistributor__Paused();
    }

    function _isAuthorizedPayer(address _payer) internal view {
        if (!s_authorizedPayers[_payer]) revert SalaryDistributor__UnauthorizedPayer();
    }

    function _getTotalAmountForBatch(uint256[] calldata _amounts) internal pure returns (uint256) {
        uint256 totalAmount;
        for (uint256 i = 0; i < _amounts.length; i++) {
            totalAmount += _amounts[i];
        }
        return totalAmount;
    }

    function _validateBatch(address[] calldata _recipients, uint256[] calldata _amounts) internal view {
        if (_recipients.length != _amounts.length) revert SalaryDistributor__MissingRecipientsToAmounts();
        if (_recipients.length == 0) revert SalaryDistributor__EmptyBatch();
        uint256 totalAmount = _getTotalAmountForBatch(_amounts);
        if (msg.value < totalAmount) revert SalaryDistributor__InsufficientBalance();
        uint256 len = _recipients.length;
        for (uint256 i = 0; i < len; i++) {
            if (_amounts[i] == 0) revert SalaryDistributor__ZeroAmount();
            if (_recipients[i] == address(0)) revert SalaryDistributor__ZeroRecipientAddress();
        }
    }

    function _distribute(address[] calldata _recipients, uint256[] calldata _amounts) internal {
        uint256 len = _recipients.length;
        for (uint256 i = 0; i < len; i++) {
            (bool success,) = _recipients[i].call{value: _amounts[i]}("");
            if (!success) revert SalaryDistributor__TransferFailed(_recipients[i], _amounts[i]);
            emit Distributed(_recipients[i], _amounts[i]);
        }
    }

    function _handleRefunds(uint256[] calldata _amounts) internal {
        uint256 totalAmount = _getTotalAmountForBatch(_amounts);
        uint256 excessFunds = msg.value - totalAmount;
        if (excessFunds > 0) {
            (bool refunded,) = msg.sender.call{value: excessFunds}("");
            if (!refunded) revert SalaryDistributor__TransferFailed(msg.sender, excessFunds);
        }
    }
}
