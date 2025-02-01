// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library priceLibrary {
    function getEthPtice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getDonationUsdvalue(uint256 donation, AggregatorV3Interface priceFeed) public view returns (uint256) {
        uint256 currentPrice = getEthPtice(priceFeed);
        uint256 amountDonated = (currentPrice * donation) / 1e18;
        return amountDonated;
    }
}
