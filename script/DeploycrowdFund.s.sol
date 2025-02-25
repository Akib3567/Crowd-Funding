// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {crowdFund} from "../src/crowdFund.sol";
import {Vm} from "forge-std/Vm.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeploycrowdFund is Script {
    HelperConfig helperConfig = new HelperConfig();
    address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

    function run() external returns(crowdFund) {
        vm.startBroadcast();
        crowdFund fund = new crowdFund(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fund;
    }
}