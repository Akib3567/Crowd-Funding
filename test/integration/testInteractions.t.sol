//SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {crowdFund} from "../../src/crowdFund.sol";
import {priceConverter} from "../../src/priceConverter.sol";
import {DeploycrowdFund} from "../../script/DeploycrowdFund.s.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {FundCrowdFund, WithdrawCrowdFund} from "../../script/interactions.s.sol";

contract InteractionsTest is Test {
    crowdFund fund;
    address USER = makeAddr("USER");
    uint256 private constant StartingBalance = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external{
        DeploycrowdFund deploy = new DeploycrowdFund();
        fund = deploy.run();
        vm.deal(USER, StartingBalance);
    }

    function testUserCanFundInteractions() public {
        FundCrowdFund fundCrowdFund = new FundCrowdFund();
        fundCrowdFund.fundCrowdFund(address(fund));

        WithdrawCrowdFund withdrawCrowdFund = new WithdrawCrowdFund();
        withdrawCrowdFund.withdrawCrowdFund(address(fund));

        assert(address(fund).balance == 0);
    }
}