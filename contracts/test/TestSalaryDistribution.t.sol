// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {SalaryDistributor} from "../src/SalaryDistributor.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TestSalaryDistribution is Test {
    SalaryDistributor distributor;
    address owner = makeAddr("owner");
    address payer1 = makeAddr("payer1");
    address payer2 = makeAddr("payer2");

    address[] recipients = [makeAddr("recipient1"), makeAddr("recipient2"), makeAddr("recipient3")];
    uint256[] amounts = [100, 200, 300];

    function setUp() public {
        vm.startPrank(owner);
        distributor = new SalaryDistributor();
        vm.stopPrank();
    }

    function test_OnlyOwnerCanSetPayer() public {
        //Arrange
        address notOwner = makeAddr("notOwner");
        vm.startPrank(notOwner);
        //Act & Assert
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwner));
        distributor.setPayer(makeAddr("newPayer"));
        vm.stopPrank();
    }

    function test_OwnerCanAddPayer() public {
        //Arrange
        vm.startPrank(owner);
        //Act & Assert
        distributor.setPayer(payer1);
        vm.stopPrank();
    }

    function test_onlyOwnerCanPause() public {
        //Arrange
        address notOwner = makeAddr("notOwner");
        vm.startPrank(notOwner);
        //Act & Assert
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwner));
        distributor.pause();
        vm.stopPrank();
    }

    function test_OwnerCanPause() public {
        //Arrange
        vm.startPrank(owner);
        //Act & Assert
        distributor.pause();
        vm.stopPrank();
    }

    function test_onlyOwnerCanUnpause() public {
        //Arrange
        address notOwner = makeAddr("notOwner");
        vm.startPrank(owner);
        distributor.pause();
        vm.stopPrank();
        vm.startPrank(notOwner);
        //Act & Assert
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwner));
        distributor.unpause();
        vm.stopPrank();
    }

    function test_OwnerCanUnpause() public {
        //Arrange
        vm.startPrank(owner);
        distributor.pause();
        //Act & Assert
        distributor.unpause();
        vm.stopPrank();
    }

    function test_CantAddPayerIfPaused() public {
        //Arrange
        vm.startPrank(owner);
        distributor.pause();
        //Act & Assert
        vm.expectRevert(SalaryDistributor.SalaryDistributor__Paused.selector);
        distributor.setPayer(payer1);
        vm.stopPrank();
    }

    function test_CantDistributeIfPaused() public {
        //Arrange
        vm.startPrank(owner);
        distributor.pause();
        //Act & Assert
        vm.expectRevert(SalaryDistributor.SalaryDistributor__Paused.selector);
        distributor.distribute(recipients, amounts);
        vm.stopPrank();
    }

    function test_CantDistributeIfUnauthorizedPayer() public {
        //Arrange
        vm.startPrank(payer1);
        //Act & Assert
        vm.expectRevert(SalaryDistributor.SalaryDistributor__UnauthorizedPayer.selector);
        distributor.distribute(recipients, amounts);
        vm.stopPrank();
    }

    function test_CantDistributeIfMissingRecipientsToAmounts() public {
        //Arrange
        vm.startPrank(owner);
        distributor.setPayer(payer1);
        vm.stopPrank();
        //Act & Assert
        vm.startPrank(payer1);
        vm.expectRevert(SalaryDistributor.SalaryDistributor__MissingRecipientsToAmounts.selector);
        distributor.distribute(recipients, new uint256[](0));
        vm.stopPrank();
    }

    function test_CantDistributeIfEmptyBatch() public {
        //Arrange
        vm.startPrank(owner);
        distributor.setPayer(payer1);
        vm.stopPrank();
        //Act & Assert
        vm.startPrank(payer1);
        vm.expectRevert(SalaryDistributor.SalaryDistributor__EmptyBatch.selector);
        distributor.distribute(new address[](0), new uint256[](0));
        vm.stopPrank();
    }

    function test_CantDistributeIfInsufficientBalance() public {
        //Arrange
        vm.startPrank(owner);
        distributor.setPayer(payer1);
        vm.stopPrank();
        //Act & Assert
        vm.startPrank(payer1);
        vm.deal(payer1, 100);
        vm.expectRevert(SalaryDistributor.SalaryDistributor__InsufficientBalance.selector);
        distributor.distribute(recipients, amounts);
        vm.stopPrank();
    }

    function test_CantDistributeIfZeroAmount() public {
        //Arrange
        vm.startPrank(owner);
        distributor.setPayer(payer1);
        vm.stopPrank();
        uint256[] memory zeroAmounts = new uint256[](3);
        zeroAmounts[0] = 0;
        zeroAmounts[1] = 200;
        zeroAmounts[2] = 300;
        //Act & Assert
        vm.startPrank(payer1);
        vm.deal(payer1, 1 ether);
        vm.expectRevert(SalaryDistributor.SalaryDistributor__ZeroAmount.selector);
        distributor.distribute{value: 1 ether}(recipients, zeroAmounts);
        vm.stopPrank();
    }

    function test_CantDistributeIfZeroRecipientAddress() public {
        //Arrange
        vm.startPrank(owner);
        distributor.setPayer(payer1);
        vm.stopPrank();
        address[] memory zeroRecipients = new address[](3);
        zeroRecipients[0] = address(0);
        zeroRecipients[1] = makeAddr("r2");
        zeroRecipients[2] = makeAddr("r3");
        //Act & Assert
        vm.startPrank(payer1);
        vm.deal(payer1, 1 ether);
        vm.expectRevert(SalaryDistributor.SalaryDistributor__ZeroRecipientAddress.selector);
        distributor.distribute{value: 1 ether}(zeroRecipients, amounts);
        vm.stopPrank();
    }

    function test_CantSetZeroAddressAsPayer() public {
        //Arrange
        vm.startPrank(owner);
        //Act & Assert
        vm.expectRevert(SalaryDistributor.SalaryDistributor__ZeroPayerAddress.selector);
        distributor.setPayer(address(0));
        vm.stopPrank();
    }

    function test_HappyPath_DistributeAndRefundExcess() public {
        //Arrange — amounts = [100, 200, 300] → total = 600, send 1000 → excess = 400
        uint256 totalRequired = 600;
        uint256 excessSent = 400;
        uint256 totalSent = totalRequired + excessSent;

        vm.startPrank(owner);
        distributor.setPayer(payer1);
        vm.stopPrank();

        vm.deal(payer1, totalSent);

        uint256 payerBalanceBefore = payer1.balance;
        uint256 recipient1BalanceBefore = recipients[0].balance;
        uint256 recipient2BalanceBefore = recipients[1].balance;
        uint256 recipient3BalanceBefore = recipients[2].balance;

        //Act
        vm.startPrank(payer1);
        distributor.distribute{value: totalSent}(recipients, amounts);
        vm.stopPrank();

        //Assert — recipients received exact amounts
        assertEq(recipients[0].balance, recipient1BalanceBefore + amounts[0], "recipient1 balance mismatch");
        assertEq(recipients[1].balance, recipient2BalanceBefore + amounts[1], "recipient2 balance mismatch");
        assertEq(recipients[2].balance, recipient3BalanceBefore + amounts[2], "recipient3 balance mismatch");

        //Assert — payer refunded excess, net cost = totalRequired
        assertEq(payer1.balance, payerBalanceBefore - totalRequired, "payer refund mismatch");

        //Assert — contract holds zero ETH
        assertEq(address(distributor).balance, 0, "contract should hold no ETH");
    }
}
