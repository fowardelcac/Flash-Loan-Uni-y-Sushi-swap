// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.6;

/// @notice Interface for SushiSwap.
interface ISushiSwap {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
