// SPDX-License-Identifier: MIT
pragma solidity >=0.6.8;

import {IFlashLoanReceiver} from "interfaces/Aave/IFlashLoanReceiverV2.sol";
import {ILendingPoolAddressesProvider} from "interfaces/Aave/ILendingPoolAddressesProviderV2.sol";
import {ILendingPool} from "interfaces/Aave/ILendingPoolV2.sol";
import "interfaces/ITokens/IERC20.sol";
import "contracts/libraries/LowGasSafeMath.sol";

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
    using LowGasSafeMath for uint256;
    using LowGasSafeMath for IERC20;

    ILendingPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;
    ILendingPool public immutable override LENDING_POOL;

    constructor(ILendingPoolAddressesProvider provider) {
        ADDRESSES_PROVIDER = provider;
        LENDING_POOL = ILendingPool(provider.getLendingPool());
    }
}
