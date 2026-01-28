// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MockGovernor} from "../src/MockGovernor.sol";
import {GovernanceQuorumSentinelTrapFixed} from "../src/GovernanceQuorumSentinelTrapFixed.sol";
import {GovernanceQuorumSentinelResponse} from "../src/GovernanceQuorumSentinelResponse.sol";

/**
 * @title DeployGovernanceQuorumSentinel
 * @dev Deployment script for the FIXED Governance Quorum Sentinel system.
 */
contract DeployGovernanceQuorumSentinel is Script {
    // Drosera executor address for Hoodi Testnet (from drosera.toml)
    address constant DROSERA_EXECUTOR = 0x91cB447BaFc6e0EA0F4Fe056F5a9b1F14bb06e5D;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy the Mock Governor (if not already deployed)
        // MockGovernor targetGovernor = new MockGovernor(1000);
        
        // 2. Deploy the Response contract with Drosera executor address
        GovernanceQuorumSentinelResponse response = new GovernanceQuorumSentinelResponse(DROSERA_EXECUTOR);

        vm.stopBroadcast();

        // Log addresses for configuration
        console.log("Response Contract deployed at:", address(response));
        console.log("Configured Drosera Executor:", DROSERA_EXECUTOR);
        
        // Important notes
        console.log("\n=== DROSERA CONFIGURATION ===");
        console.log("1. Response address for drosera.toml:", address(response));
        console.log("2. Drosera executor is hardcoded in response constructor");
        console.log("3. Trap uses hardcoded TARGET_GOVERNOR: 0xcD8830Cb274857cF0044e0A6b2b4F54138949B2A");
    }
}