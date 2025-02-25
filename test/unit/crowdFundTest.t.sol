// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {crowdFund} from "../../src/crowdFund.sol";
import {priceConverter} from "../../src/priceConverter.sol";
import {DeploycrowdFund} from "../../script/DeploycrowdFund.s.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract crowdFundTest is Test {
    crowdFund fund;
    address USER = makeAddr("USER");
    uint256 private constant StartingBalance = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external{
        //fund = new crowdFund(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeploycrowdFund deploy = new DeploycrowdFund();
        fund = deploy.run();
        vm.deal(USER, StartingBalance);
    }

    function testDemo() public view{
        assertEq(fund.minUsd(), 5e18);
    }

    function testVersion() public {
        //uint256 version = priceConverter.getVersion(AggregatorV3Interface(address(0x694AA1769357215DE4FAC081bf1f309aDC325306)));
        uint256 version = priceConverter.getVersion(AggregatorV3Interface(HelperConfig(new HelperConfig()).activeNetworkConfig()));
        assertEq(version, 4);
    }

    function testFundUpdates () public {
        vm.prank(USER);
        fund.fund{value: 5e18}();
        uint256 fundedAmount = fund.getAddressToAmountFunded(USER);
        assertEq(fundedAmount, 5e18);
    }

    modifier funded() {
        vm.prank(USER);
        fund.fund{value: 5e18}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fund.withdrawAllFunds();
    }

    function testWithdrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fund.getOwner().balance;
        uint256 startingFundBalance = address(fund).balance;

        //Act  
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fund.getOwner());
        fund.withdrawAllFunds();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fund.getOwner().balance;
        uint256 endingFundBalance = address(fund).balance;
        assertEq(endingFundBalance, 0);
        assertEq(startingFundBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded{
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i <= numberOfFunders; i++){
            hoax(address(i), 5e18);
            fund.fund{value: 5e18}();
        }

        uint256 startingOwnerBalance = fund.getOwner().balance;
        uint256 startingFundBalance = address(fund).balance;

        //Act
        vm.prank(fund.getOwner());
        fund.withdrawAllFunds();

        //assert
        assert(address(fund).balance == 0);
        assert(startingFundBalance + startingOwnerBalance == fund.getOwner().balance);

    }
}