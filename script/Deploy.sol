// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MockGovernor} from "../src/MockGovernor.sol";
import {GovernanceQuorumSentinelTrap} from "../src/GovernanceQuorumSentinelTrap.sol";
import {GovernanceQuorumSentinelResponse} from "../src/GovernanceQuorumSentinelResponse.sol";

/**
 * @title DeployGovernanceQuorumSentinel
 * @dev Deployment script for the Governance Quorum Sentinel system.
 *      IMPORTANT: Drosera only deploys the RESPONSE contract.
 *      The Trap is deployed and configured via drosera.toml and `drosera apply`.
 */
contract DeployGovernanceQuorumSentinel is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy the Mock Governor (our simulation target)
        //    Starting with a reasonable quorum of 1000 tokens
        MockGovernor targetGovernor = new MockGovernor(1000);
        
        // 2. Deploy the Trap contract (reference only - Drosera will deploy its own instance)
        GovernanceQuorumSentinelTrap trap = new GovernanceQuorumSentinelTrap(address(targetGovernor));
        
        // 3. Deploy the Response contract (THIS is what Drosera needs)
        GovernanceQuorumSentinelResponse response = new GovernanceQuorumSentinelResponse(address(trap));

        vm.stopBroadcast();

        // Log addresses for configuration
        console.log("MockGovernor deployed at:", address(targetGovernor));
        console.log("GovernanceQuorumSentinelTrap (reference) deployed at:", address(trap));
        console.log("GovernanceQuorumSentinelResponse deployed at:", address(response));
        
        // Important reminder
        console.log("\n=== DROSERA CONFIGURATION NOTE ===");
        console.log("1. Use the RESPONSE address above in drosera.toml");
        console.log("2. The Trap address logged here is a REFERENCE.");
        console.log("3. Drosera will deploy its own Trap instance when you run 'drosera apply'");
    }
}