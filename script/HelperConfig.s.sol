// SPDX-License-Identifier: MIT

/* PURPOSE

1. to deploy mock contracts on our local Anvil Chain
2. to keep track of various important contract addresses across different chains.

For example: 
address of Sepolia ETH/USD
address of Mainnet ETH/USD
*/

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        // Data that can be retrieved from a network

        address priceFeed_Address; // ETH/USD price feed Address
    }

    NetworkConfig public activeNetwork;

    // for Anvil Pricefeed Contract  (1ETH = 2000USD)
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetwork = getSepoliaETHConfig();

            /* If we are on Sepolia Chain then use details of sepolia.
             */
        } else if (block.chainid == 1) {
            activeNetwork = getMainnetETHConfig();
        } else {
            activeNetwork = getAnvilETHConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        // fn that will provide everything that we need from SEPOLIA network

        NetworkConfig memory sepoliaDetails = NetworkConfig({
            priceFeed_Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaDetails;
    }

    function getAnvilETHConfig() public returns (NetworkConfig memory) {
        /* fn that will provide everything that we need from ANVIL network

        1. Deploy MOCK Contract (Mock Pricefeed)
        2. Return its address
        */

        if (activeNetwork.priceFeed_Address != address(0)) {
            return activeNetwork;

            // address(0) : default address -> ZERO(0)
            // If "priceFeed_Address" is pointing to Zero (default) address, only then proceed with anvil network details.

            // It is when we doesn't provide any rpc url
        }

        vm.startBroadcast(); // to deploy
        MockV3Aggregator mockPricefeedAddress = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); // 1ETH = 2000USD
        vm.stopBroadcast(); // to deploy

        NetworkConfig memory anvilDetails = NetworkConfig({
            priceFeed_Address: address(mockPricefeedAddress)
        });

        return anvilDetails;
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory) {
        // fn that will provide everything that we need from Ethereum Mainnet network

        NetworkConfig memory mainnetETHDetails = NetworkConfig({
            priceFeed_Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });

        return mainnetETHDetails;
    }
}
