// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "drosera-contracts/interfaces/ITrap.sol";

/**
 * @title GovernanceQuorumSentinelTrap
 * @dev Monitors a MockGovernor contract's quorum value.
 *      Triggers if quorum becomes 0 (critical failure) or exceeds an unreasonable maximum (1 million).
 *      This is a SINGLE VECTOR trap for gas efficiency.
 */
contract GovernanceQuorumSentinelTrap is ITrap {
    /// @notice Address of the MockGovernor contract to monitor
    address public immutable TARGET_GOVERNOR;

    /// @notice Reasonable maximum quorum threshold (guards against extreme misconfiguration)
    uint256 public constant MAX_QUORUM = 1_000_000;

    /**
     * @dev Initialize the trap with the target governor address.
     * @param _targetGovernor Address of the MockGovernor contract.
     */
    constructor(address _targetGovernor) {
        // Basic validation - ensure address is not zero
        require(_targetGovernor != address(0), "Invalid target governor");
        TARGET_GOVERNOR = _targetGovernor;
    }

    /**
     * @dev Collects the current quorum value from the target governor.
     * @return bytes-encoded quorum (abi.encode(uint256)).
     */
    function collect() external view override returns (bytes memory) {
        // Use a low-level staticcall to retrieve the quorum value
        (bool success, bytes memory data) = TARGET_GOVERNOR.staticcall(
            abi.encodeWithSignature("quorum()")
        );
        
        // If staticcall fails, return a default value (0) to avoid revert
        // This ensures the trap can always collect data
        if (!success || data.length != 32) {
            return abi.encode(uint256(0));
        }
        
        return data; // Returns abi.encode(uint256)
    }

    /**
     * @dev Evaluates if the collected quorum data indicates a failure.
     *      Failure conditions: quorum == 0 OR quorum > MAX_QUORUM.
     * @param data Array of historical data points from collect().
     * @return (bool shouldRespond, bytes memory reason) 
     */
    function shouldRespond(bytes[] calldata data) 
        external 
        pure 
        override 
        returns (bool, bytes memory) 
    {
        // Safety check: require at least one data point
        if (data.length == 0) {
            return (false, bytes("No data"));
        }

        // Decode the most recent data point (data[0])
        // data[0] should be abi.encode(uint256) from collect()
        uint256 currentQuorum;
        
        // Safe decoding - if decode fails, treat as zero
        if (data[0].length == 32) {
            currentQuorum = abi.decode(data[0], (uint256));
        } else {
            currentQuorum = 0;
        }

        // Check for critical failure: quorum set to zero
        if (currentQuorum == 0) {
            return (true, bytes("CRITICAL: Governance quorum is ZERO"));
        }

        // Check for unreasonable misconfiguration
        if (currentQuorum > MAX_QUORUM) {
            return (true, bytes("CRITICAL: Governance quorum exceeds safe maximum"));
        }

        // All good
        return (false, bytes(""));
    }
}