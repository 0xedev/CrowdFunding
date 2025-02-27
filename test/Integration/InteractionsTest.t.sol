// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    FundMe public fundMe;
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

    function testUsersCanFundInteractions() public {
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();
        hoax(USER, SEND_VALUE);
        //WithdrawFundMe
        // WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // withdrawFundMe.withdrawFundMe(address(fundMe));

        new WithdrawFundMe().withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
