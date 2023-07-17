// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before startBroadCast -> not a "real" tx
        HelperConfig helperConfig = new HelperConfig();
        // address ethUsdPriceFeed = helperConfig.activeNetworkConfig().priceFeed;
        // this is totally wrong
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        // mock
        FundMe fundme = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundme;
    }
}