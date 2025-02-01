// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address public USER = makeAddr("user");
    uint256 public constant SEND_VALUE = 1 ether;
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    modifier funded() {
        fundMe.fund{value: SEND_VALUE}(); // Send 1 ETH to contract
        _;
    }

    function testMinimumUSd() public view {
        assertEq(fundMe.getMinDonation(), 5e18);
    }

    function testOwnerIsSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundRevert() public {
        vm.expectRevert("Mininum amount to donate is 5usd");
        fundMe.fund{value: 4.9e10}(); // Send less than 5 ETH to trigger revert
    }

    function testOwner() public view {
        assertEq(msg.sender, fundMe.getOwner());
    }

    function testWithdrawByOwner() public funded {
        // Get initial balances

        uint256 ownerBalanceBefore = fundMe.getOwner().balance;
        uint256 contractBalanceBefore = address(fundMe).balance;

        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);

        // Owner withdraws funds

        vm.prank(fundMe.getOwner()); // Simulate owner calling
        fundMe.withdraw();
        uint256 gasEnd = gasleft();

        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used: ", gasUsed);

        // Get balances after withdrawal
        uint256 ownerBalanceAfter = fundMe.getOwner().balance;
        uint256 contractBalanceAfter = address(fundMe).balance;

        // Assertions
        assertEq(contractBalanceAfter, 0); // Contract balance should be 0
        assertEq(ownerBalanceAfter, ownerBalanceBefore + contractBalanceBefore); // Owner should receive funds
    }

    function testWithdrawByNonOwner() public {
        vm.expectRevert();
        vm.prank(USER); // Simulate non-owner calling
        fundMe.withdraw();
    }

    function testFunderslistUpdate() public funded {
        // fund the contract first
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddFunderToArray() public {
        // vm.prank(USER);

        // assertEq(fundMe.getFunders(0), USER);
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testWithdrawByPlentyFunders() public funded {
        //ARRANGE
        // Get initial balances
        uint160 noOfFunders = 5;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < noOfFunders; i++) {
            hoax(address(i), SEND_VALUE);

            /* Hoax combines vm.prank(which create address) and vm.deal(which fund the address with ether) */

            fundMe.fund{value: SEND_VALUE}();
        }

        // Get initial balances
        uint256 ownerBalanceBefore = fundMe.getOwner().balance;
        uint256 contractBalanceBefore = address(fundMe).balance;

        //ACT - Owner withdraws funds
        vm.prank(fundMe.getOwner()); // Simulate owner calling
        fundMe.withdraw();

        // Get balances after withdrawal
        uint256 ownerBalanceAfter = fundMe.getOwner().balance;
        uint256 contractBalanceAfter = address(fundMe).balance;

        // ASSERTIONS
        assertEq(contractBalanceAfter, 0); // Contract balance should be 0
        assertEq(ownerBalanceAfter, ownerBalanceBefore + contractBalanceBefore); // Owner should receive funds
    }

    function testWithdrawByPlentyFundersCheaper() public funded {
        //ARRANGE
        // Get initial balances
        uint160 noOfFunders = 5;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < noOfFunders; i++) {
            hoax(address(i), SEND_VALUE);

            /* Hoax combines vm.prank(which create address) and vm.deal(which fund the address with ether) */

            fundMe.fund{value: SEND_VALUE}();
        }

        // Get initial balances
        uint256 ownerBalanceBefore = fundMe.getOwner().balance;
        uint256 contractBalanceBefore = address(fundMe).balance;

        //ACT - Owner withdraws funds
        vm.prank(fundMe.getOwner()); // Simulate owner calling
        fundMe.cheaperWithdraw();

        // Get balances after withdrawal
        uint256 ownerBalanceAfter = fundMe.getOwner().balance;
        uint256 contractBalanceAfter = address(fundMe).balance;

        // ASSERTIONS
        assertEq(contractBalanceAfter, 0); // Contract balance should be 0
        assertEq(ownerBalanceAfter, ownerBalanceBefore + contractBalanceBefore); // Owner should receive funds
    }
}
