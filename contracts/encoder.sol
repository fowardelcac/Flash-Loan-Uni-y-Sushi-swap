// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

contract encoder {
    function set(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _choice
    ) public pure returns (bytes memory) {
        return abi.encode(_tokenIn, _tokenOut, _amountIn, _choice);
    }
}
