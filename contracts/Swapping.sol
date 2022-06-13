// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import "interfaces/SushiSwap/ISushiSwap.sol";
import "interfaces/Uniswap/ISwapRouter.sol";
import "contracts/libraries/TransferHelper.sol";
import "contracts/Pricing.sol";

contract Swapping is Pricing {
    event LogSwapper(uint256 _amountOut1, uint256 _amountOut2, uint256 _choice);
    ISwapRouter internal immutable swapRouter_s;
    ISushiSwap internal immutable sushiRouter_s;

    constructor(
        IUniswapV3Factory _factory,
        IFactory _factoryS,
        ISwapRouter _swapRouter,
        ISushiSwap _sushiRouter
    ) Pricing(_factory, _factoryS) {
        swapRouter_s = _swapRouter;
        sushiRouter_s = _sushiRouter;
    }

    function Swap(bytes memory _params) internal {
        (
            address _tokenIn,
            address _tokenOut,
            uint256 _amountIn,
            uint256 _choice
        ) = abi.decode(_params, (address, address, uint256, uint256));
        require(_amountIn != 0, ">0");
        require(_tokenIn != address(0), "tIn");
        require(_tokenOut != address(0), "tOut");

        address[] memory _path = new address[](2);
        uint256 _secondOut = LowGasSafeMath.math(_amountIn, 25000000000000000) +
            _amountIn;
        if (_choice == 0) {
            uint256 _amountOut = uniSwap(
                _tokenIn,
                _tokenOut,
                _amountIn,
                estimateAmountOut(_tokenIn, _tokenOut, uint128(_amountIn))
            );
            _path[0] = _tokenOut;
            _path[1] = _tokenIn;

            uint256[] memory _amounts = swapSushi(
                _amountOut,
                _path,
                _secondOut
            );
            emit LogSwapper(_amountOut, _amounts[1], 0);
        } else {
            require(_choice == 1, "ic");
            _path[0] = _tokenIn;
            _path[1] = _tokenOut;
            uint256[] memory _amounts = swapSushi(
                _amountIn,
                _path,
                //Sell dai buy token: 1
                estimateSushi(_path[0], _path[1], _amountIn, 1)
            );
            uint256 _amountU = uniSwap(
                _path[1],
                _path[0],
                _amounts[1],
                _secondOut
            );
            emit LogSwapper(_amounts[1], _amountU, 1);
        }
    }

    function uniSwap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountMinimiumOut
    ) internal returns (uint256 _amountOut) {
        TransferHelper.safeApprove(_tokenIn, address(swapRouter_s), _amountIn);
        ISwapRouter.ExactInputSingleParams memory _params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: _amountMinimiumOut,
                sqrtPriceLimitX96: 0
            });
        _amountOut = swapRouter_s.exactInputSingle(_params);
    }

    function swapSushi(
        uint256 _amountIn,
        address[] memory _path,
        uint256 _amountMinimiumOut
    ) internal returns (uint256[] memory _amounts) {
        TransferHelper.safeApprove(_path[0], address(sushiRouter_s), _amountIn);
        _amounts = sushiRouter_s.swapExactTokensForTokens(
            _amountIn,
            _amountMinimiumOut,
            _path,
            address(this),
            block.timestamp
        );
    }
}
