// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

interface IFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}
