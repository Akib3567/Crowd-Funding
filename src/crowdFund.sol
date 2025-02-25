// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import {priceConverter} from "./priceConverter.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error notOwner();

contract crowdFund {
    using priceConverter for uint256;

    uint256 public constant minUsd = 5e18;
    address[] private s_funders;
    mapping(address => uint256) private s_fundedAmount;

    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;  // Set the deployer as the contract owner
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
       // require(msg.sender == owner, "Not the owner");
       if(msg.sender != i_owner){
          revert notOwner();        //More efficient than require
       }
        _;
    }

    function fund() public payable{
        require(msg.value.conversionRate(s_priceFeed) >= minUsd);
        s_funders.push(msg.sender);
        s_fundedAmount[msg.sender] += msg.value;
    }

    function withdrawAllFunds() public payable onlyOwner {
        for (uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_fundedAmount[funder] = 0;
        }
        s_funders = new address[](0);

        (bool success, )= payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    //If someone wants to send fund from outside,
    //this functions will redirect them
    receive() external payable { 
        fund();
    }
    fallback() external payable { 
        fund();
    }

    function getAddressToAmountFunded(address funder) public view returns(uint256){
        return s_fundedAmount[funder];
    }

    function getFunders(uint256 index) public view returns(address){
        return s_funders[index];
    }

    function getOwner() public view returns(address){
        return i_owner;
    }
}