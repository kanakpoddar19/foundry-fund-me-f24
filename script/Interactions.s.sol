// SPDX-License-Identifier: MIT

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

// Fund script
// Withdraw script

pragma solidity ^0.8.18;

contract fundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fund(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }

    function run() external {
        // funding most recently deployed contract
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        fund(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract withdrawFundMe is Script {
    function withdraw(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        // withdrawing from the most recently deployed contract
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        withdraw(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}
