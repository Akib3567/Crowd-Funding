// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {crowdFund} from "../src/crowdFund.sol";

contract FundCrowdFund is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundCrowdFund(address mostRecentlyDeployed) public{
        vm.startBroadcast();
        crowdFund(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded crowdFund with ", SEND_VALUE);
    }
    
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("crowdFund", block.chainid);
        vm.startBroadcast();
        fundCrowdFund(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawCrowdFund is Script {
    function withdrawCrowdFund(address mostRecentlyDeployed) public{
        vm.startBroadcast();
        crowdFund(payable(mostRecentlyDeployed)).withdrawAllFunds();
        vm.stopBroadcast();
    }
    
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("crowdFund", block.chainid);
        vm.startBroadcast();
        withdrawCrowdFund(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

