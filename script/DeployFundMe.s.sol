// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMeScript is Script {
    function run() external returns (FundMe) {
        /* (Old, Updating both deployment script and Test contrct)
        
        vm.startBroadcast();
        new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();
        */

        // Before startBroadcast -> Not a "Real" tx
        HelperConfig helperConfig = new HelperConfig();
        address ethUSDPriceFeed = helperConfig.activeNetwork();

        // After startBroadcast -> Real tx!
        vm.startBroadcast();

        /* HardCoding Address Again

        FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        */

        FundMe fundMe = new FundMe(ethUSDPriceFeed);

        vm.stopBroadcast();

        return fundMe;
    }
}
