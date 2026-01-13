// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MockGovernor
 * @dev A simple mock governor for Hoodi Testnet simulation.
 *      In a real scenario, this would be a live protocol's governance contract (like Compound, Uniswap, etc.).
 */
contract MockGovernor {
    uint256 public quorum;
    
    constructor(uint256 _initialQuorum) {
        quorum = _initialQuorum;
    }
    
    /**
     * @dev Function to simulate a misconfiguration or exploit that sets quorum to 0.
     *      Only callable by this contract for simulation purposes.
     */
    function setQuorum(uint256 _newQuorum) external {
        quorum = _newQuorum;
    }
}