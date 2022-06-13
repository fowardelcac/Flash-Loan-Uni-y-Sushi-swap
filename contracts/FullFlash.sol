// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import "contracts/FlashLoanReceiverBaseV2.sol";
import "contracts/Swapping.sol";

contract FullFlash is FlashLoanReceiverBase, Swapping {
    address internal immutable _owner;

    constructor(
        ILendingPoolAddressesProvider _provider,
        IUniswapV3Factory _factory,
        IFactory _factoryS,
        ISwapRouter _swapRouter,
        ISushiSwap _sushiRouter
    )
        FlashLoanReceiverBase(_provider)
        Swapping(_factory, _factoryS, _swapRouter, _sushiRouter)
    {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "OO");
        _;
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        Swap(params);
        uint256 _size = assets.length;
        for (uint256 i = 0; i < _size; ++i) {
            uint256 _debt = LowGasSafeMath.add(amounts[i], premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), _debt);
        }
        return true;
    }

    function initFlashLoan(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _choice
    ) external onlyOwner {
        bytes memory _params = abi.encode(
            _tokenIn,
            _tokenOut,
            _amountIn,
            _choice
        );

        address[] memory _asset = new address[](1);
        _asset[0] = _tokenIn;
        uint256[] memory _amount = new uint256[](1);
        _amount[0] = _amountIn;

        _initFlash(_asset, _amount, _params);
    }

    function withdraw(address _asset) external onlyOwner {
        uint256 _balance = IERC20(_asset).balanceOf(address(this));
        require(_balance != 0, "No balance");
        IERC20(_asset).transfer(_owner, _balance);
    }

    function _initFlash(
        address[] memory _asset,
        uint256[] memory _amount,
        bytes memory _params
    ) internal {
        uint256 _size = _asset.length;
        uint256[] memory _modes = new uint256[](_size);
        for (uint256 i = 0; i < _size; ++i) {
            _modes[i] = 0;
        }
        LENDING_POOL.flashLoan(
            address(this),
            _asset,
            _amount,
            _modes,
            address(this),
            _params,
            0
        );
    }
}
