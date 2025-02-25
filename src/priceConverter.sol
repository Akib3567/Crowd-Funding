// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

//This interface(ABI) is for fetching price data from chainlink
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library priceConverter{
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256)
    {
        //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306

        ( ,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function conversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256)
    {
        return (getPrice(priceFeed) * ethAmount)/1e18;
    }

    function getVersion(AggregatorV3Interface priceFeed) internal view returns(uint256)
    {
        return priceFeed.version();
    }
}