// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {priceLibrary} from "./Price.sol";

error FundME__notOwner();
error FundME__notEnoughDonation();

contract FundMe {
    address private immutable i_owner;
    uint256 private constant MIN_DONATION = 5e18;
    address[] private s_funders;
    mapping(address funderAddress => uint256 s_amountDonated) private s_fundersList;

    using priceLibrary for uint256;

    AggregatorV3Interface private currentEthPrice;

    constructor(address pricefeed) {
        i_owner = msg.sender;
        currentEthPrice = AggregatorV3Interface(pricefeed);
    }

    function fund() public payable minDonation {
        require(msg.value.getDonationUsdvalue(currentEthPrice) >= MIN_DONATION, "Mininum amount to donate is 5usd");
        s_funders.push(msg.sender);
        s_fundersList[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return currentEthPrice.version();
    }

    function cheaperWithdraw() public owner {
        uint256 fundersLength = s_funders.length;
        for (uint256 firstdonation = 0; firstdonation < fundersLength; firstdonation++) {
            address donor = s_funders[firstdonation];
            s_fundersList[donor] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

    function withdraw() public owner {
        for (uint256 firstDonation = 0; firstDonation < s_funders.length; firstDonation++) {
            address donor = s_funders[firstDonation];
            s_fundersList[donor] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

    modifier owner() {
        if (msg.sender != i_owner) revert FundME__notOwner();
        _;
    }

    modifier minDonation() {
        if (msg.value == MIN_DONATION) revert FundME__notEnoughDonation();
        _;
    }

    receive() external payable {
        fund;
    }

    fallback() external payable {
        fund;
    }

    ///
    /* Getters*/
    ///

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address fundingaddress) external view returns (uint256) {
        return s_fundersList[fundingaddress];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getMinDonation() external pure returns (uint256) {
        return MIN_DONATION;
    }
}
