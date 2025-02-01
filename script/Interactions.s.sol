// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function fundFundMe(address mostRecentdeployed) public {
        FundMe(payable(mostRecentdeployed)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe contract at address: ", mostRecentdeployed);
    }

    function run() external {
        address mostRecentdeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentdeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentdeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentdeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentdeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        withdrawFundMe(mostRecentdeployed);
    }
}
