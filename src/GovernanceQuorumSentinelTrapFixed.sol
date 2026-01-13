// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "drosera-contracts/interfaces/ITrap.sol";

/**
 * @title GovernanceQuorumSentinelTrapFixed
 * @dev Same monitoring logic but with hardcoded target address.
 *      This avoids constructor argument issues with Drosera deployment.
 */
contract GovernanceQuorumSentinelTrapFixed is ITrap {
    /// @notice Hardcoded address of the MockGovernor contract to monitor
    address public constant TARGET_GOVERNOR = 0xcD8830Cb274857cF0044e0A6b2b4F54138949B2A;
    
    /// @notice Reasonable maximum quorum threshold
    uint256 public constant MAX_QUORUM = 1_000_000;

    // No constructor needed - address is hardcoded

    function collect() external view override returns (bytes memory) {
        // Use a low-level staticcall to retrieve the quorum value
        (bool success, bytes memory data) = TARGET_GOVERNOR.staticcall(
            abi.encodeWithSignature("quorum()")
        );
        
        // If staticcall fails, return a default value (0)
        if (!success || data.length != 32) {
            return abi.encode(uint256(0));
        }
        
        return data;
    }

    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        if (data.length == 0) {
            return (false, bytes("No data"));
        }

        uint256 currentQuorum;
        
        if (data[0].length == 32) {
            currentQuorum = abi.decode(data[0], (uint256));
        } else {
            currentQuorum = 0;
        }

        if (currentQuorum == 0) {
            return (true, bytes("CRITICAL: Governance quorum is ZERO"));
        }

        if (currentQuorum > MAX_QUORUM) {
            return (true, bytes("CRITICAL: Governance quorum exceeds safe maximum"));
        }

        return (false, bytes(""));
    }
}