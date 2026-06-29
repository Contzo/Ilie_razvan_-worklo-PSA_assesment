// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, NetworkConfig} from "./HelperConfig.s.sol";
import {SalaryDistributor} from "../src/SalaryDistributor.sol";

contract DeploySalaryDistributor is Script {
    function run() public returns (SalaryDistributor, NetworkConfig memory) {
        HelperConfig helperConfig = new HelperConfig();
        NetworkConfig memory config = helperConfig.getCurrentChainConfig();

        vm.startBroadcast(config.deployerKey);

        SalaryDistributor distributor = new SalaryDistributor();
        console.log("SalaryDistributor deployed at:", address(distributor));

        // Authorize the payer address
        distributor.setPayer(config.payerAddress);
        console.log("Payer authorized:", config.payerAddress);

        vm.stopBroadcast();

        return (distributor, config);
    }
}
