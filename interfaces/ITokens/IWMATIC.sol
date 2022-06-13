// SPDX-License-Identifier: MIT
pragma solidity >=0.4.18;

interface IWMATIC {
    function allowance(address owner, address spender)
        external
        view
        returns (uint256 remaining);

    function balanceOf(address owner) external view returns (uint256 balance);

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}
