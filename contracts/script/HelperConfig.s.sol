// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

struct NetworkConfig {
    address deployerAddress;
    uint256 deployerKey;
    address payerAddress;
}

contract HelperConfig is Script {
    uint256 constant POLYGON_AMOY_CHAIN_ID = 80002;
    uint256 constant LOCAL_CHAIN_ID = 31337;

    address constant DEFAULT_ANVIL_WALLET = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    mapping(uint256 chainId => NetworkConfig networkConfig) public networkConfigs;

    constructor() {
        if (block.chainid == POLYGON_AMOY_CHAIN_ID) {
            networkConfigs[POLYGON_AMOY_CHAIN_ID] = getPolygonAmoyConfig();
        }
        if (block.chainid == LOCAL_CHAIN_ID) {
            networkConfigs[LOCAL_CHAIN_ID] = getAnvilConfig();
        }
    }

    function getPolygonAmoyConfig() public view returns (NetworkConfig memory) {
        uint256 deployerKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerKey);
        return NetworkConfig({
            deployerAddress: deployerAddress,
            deployerKey: deployerKey,
            payerAddress: vm.envOr("PAYER_ADDRESS", deployerAddress)
        });
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (networkConfigs[LOCAL_CHAIN_ID].deployerAddress != address(0)) {
            return networkConfigs[LOCAL_CHAIN_ID];
        }

        uint256 localKey = vm.envOr("LOCAL_KEY", DEFAULT_ANVIL_KEY);
        address localWallet = vm.envOr("LOCAL_WALLET", DEFAULT_ANVIL_WALLET);

        NetworkConfig memory anvilConfig =
            NetworkConfig({deployerAddress: localWallet, deployerKey: localKey, payerAddress: localWallet});

        networkConfigs[LOCAL_CHAIN_ID] = anvilConfig;
        return anvilConfig;
    }

    function getConfigByChainId(uint256 chainId) public view returns (NetworkConfig memory) {
        if (networkConfigs[chainId].deployerAddress == address(0)) revert("HelperConfig: chain not supported");
        return networkConfigs[chainId];
    }

    function getCurrentChainConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }
}
