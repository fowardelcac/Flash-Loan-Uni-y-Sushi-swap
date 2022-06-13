// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import "interfaces/Uniswap/IUniswapV3Factory.sol";
import "interfaces/SushiSwap/IFactory.sol";
import "interfaces/SushiSwap/IPair.sol";
import "contracts/libraries/OracleLibrary.sol";

contract Pricing {
    IUniswapV3Factory internal immutable factory_s;
    IFactory internal immutable factoryS_s;

    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;

    constructor(IUniswapV3Factory _factory, IFactory _factoryS) {
        factory_s = _factory;
        factoryS_s = _factoryS;
    }

    function estimateAmountOut(
        address _tokenIn,
        address _tokenOut,
        uint128 _amountIn
    ) internal view returns (uint256 _amountOut) {
        address _pool = factory_s.getPool(_tokenIn, _tokenOut, 3000);
        uint32[] memory _secondsAgo = new uint32[](2);
        _secondsAgo[0] = 1;
        _secondsAgo[1] = 0;
        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(_pool).observe(
            _secondsAgo
        );
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        int24 tick = int24(tickCumulativesDelta / 1);

        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % 1 != 0)) {
            tick--;
        }

        uint256 _initPrice = OracleLibrary.getQuoteAtTick(
            tick,
            _amountIn,
            _tokenIn,
            _tokenOut
        );
        /////////////////////////////////
        _amountOut = _initPrice.math(996000000000000000);
    }

    function estimateSushi(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _choice
    ) internal view returns (uint256 _amountOut) {
        IPair _pair = IPair(factoryS_s.getPair(_tokenIn, _tokenOut));
        (uint256 _reserve0, uint256 _reserve1, ) = _pair.getReserves();
        uint256 _amountPlusFee = _amountIn.mul(997);
        if (_choice == 0) {
            //weth/dai _> gasto weth y recibo daui 1weth==1.9k
            _amountOut =
                _amountIn.mul(997).mul(_reserve1) /
                _reserve0.mul(1000).add(_amountPlusFee);
        } else {
            // dai/weth 1dai=0.000049weth
            require(_choice == 1, "ic");
            _amountOut =
                _amountIn.mul(997).mul(_reserve0) /
                _reserve1.mul(1000).add(_amountPlusFee);
        }
    }
}
