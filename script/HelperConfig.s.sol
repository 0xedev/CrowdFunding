//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../Test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetwork;

    struct NetworkConfig {
        address pricefeed;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 200000000000;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetwork = getSepoliaEthUsdPriceFeed();
        } else if (block.chainid == 1) {
            activeNetwork = getBaseEthMainnetUsdPriceFeed();
        } else if (block.chainid == 8453) {
            activeNetwork = getEthMainnetUsdPriceFeed();
        } else if (block.chainid == 10) {
            activeNetwork = getOptimismEthMainnetUsdPriceFeed();
        } else {
            activeNetwork = getOrCreateAnvilEthUsdPriceFeed();
        }
    }

    function getSepoliaEthUsdPriceFeed() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({pricefeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getEthMainnetUsdPriceFeed() public pure returns (NetworkConfig memory) {
        // NetworkConfig memory ethConfig =
        return NetworkConfig({pricefeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    }

    function getBaseEthMainnetUsdPriceFeed() public pure returns (NetworkConfig memory) {
        // NetworkConfig memory ethConfig =
        return NetworkConfig({pricefeed: 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70});
    }

    function getOptimismEthMainnetUsdPriceFeed() public pure returns (NetworkConfig memory) {
        // NetworkConfig memory ethConfig =
        return NetworkConfig({pricefeed: 0x13e3Ee699D1909E989722E753853AE30b17e08c5});
    }

    function getOrCreateAnvilEthUsdPriceFeed() public returns (NetworkConfig memory) {
        if (activeNetwork.pricefeed != address(0)) {
            return activeNetwork;
        }
        /// Depoy mocks for testing

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();

        // return the mock
        NetworkConfig memory anvilConfig = NetworkConfig({pricefeed: address(mockV3Aggregator)});
        return anvilConfig;
    }
}
