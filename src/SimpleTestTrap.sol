// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "drosera-contracts/interfaces/ITrap.sol";

contract SimpleTestTrap is ITrap {
    function collect() external view override returns (bytes memory) {
        return abi.encode(block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length == 0) return (false, bytes("No data"));
        return (false, bytes("")); // Never triggers for testing
    }
}