// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "drosera-contracts/interfaces/ITrap.sol";

/**
 * @title GovernanceQuorumSentinelTrapFixed
 * @dev Monitors a MockGovernor contract's quorum value.
 *      Triggers if quorum becomes 0 (critical failure) or exceeds an unreasonable maximum (1 million).
 *      IMPROVED VERSION with proper ABI encoding and error differentiation.
 */
contract GovernanceQuorumSentinelTrapFixed is ITrap {
    /// @notice Hardcoded address of the MockGovernor contract to monitor
    address public constant TARGET_GOVERNOR = 0xcD8830Cb274857cF0044e0A6b2b4F54138949B2A;
    
    /// @notice Reasonable maximum quorum threshold
    uint256 public constant MAX_QUORUM = 1_000_000;
    
    /// @notice Data structure to differentiate between call failure and actual zero quorum
    struct CollectOutput {
        bool ok;          // Whether the staticcall succeeded
        uint256 quorum;   // Actual quorum value (valid only if ok == true)
    }

    function collect() external view override returns (bytes memory) {
        // Use a low-level staticcall to retrieve the quorum value
        (bool success, bytes memory ret) = TARGET_GOVERNOR.staticcall(
            abi.encodeWithSignature("quorum()")
        );
        
        // Differentiate between call failure and actual zero quorum
        if (!success || ret.length != 32) {
            // Call failed or returned invalid data
            return abi.encode(CollectOutput({ok: false, quorum: 0}));
        }
        
        // Call succeeded, decode the quorum
        uint256 actualQuorum = abi.decode(ret, (uint256));
        return abi.encode(CollectOutput({ok: true, quorum: actualQuorum}));
    }

    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        // Safety check: require at least one data point
        if (data.length == 0) {
            return (false, bytes(""));
        }

        // Decode the most recent data point
        CollectOutput memory current = abi.decode(data[0], (CollectOutput));

        // Check if the call itself failed
        if (!current.ok) {
            return (true, abi.encode("CRITICAL: quorum() staticcall failed - contract may be paused or misconfigured"));
        }

        // Check for critical failure: quorum set to zero
        if (current.quorum == 0) {
            return (true, abi.encode("CRITICAL: Governance quorum is ZERO"));
        }

        // Check for unreasonable misconfiguration
        if (current.quorum > MAX_QUORUM) {
            return (true, abi.encode("CRITICAL: Governance quorum exceeds safe maximum"));
        }

        // All good
        return (false, bytes(""));
    }
}