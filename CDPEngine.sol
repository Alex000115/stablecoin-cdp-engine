// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IStablecoin is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

interface IPriceFeed {
    function getLatestPrice() external view returns (uint256);
}

contract CDPEngine is ReentrancyGuard {
    IStablecoin public immutable stablecoin;
    IPriceFeed public immutable priceFeed;

    uint256 public constant LIQUIDATION_THRESHOLD = 150; // 150%
    uint256 public constant PRECISION = 100;

    mapping(address => uint256) public collateral;
    mapping(address => uint256) public debt;

    event CollateralDeposited(address indexed user, uint256 amount);
    event StablecoinMinted(address indexed user, uint256 amount);

    constructor(address _stablecoin, address _priceFeed) {
        stablecoin = IStablecoin(_stablecoin);
        priceFeed = IPriceFeed(_priceFeed);
    }

    function depositAndMint(uint256 mintAmount) external payable nonReentrant {
        collateral[msg.sender] += msg.value;
        debt[msg.sender] += mintAmount;

        _checkHealthFactor(msg.sender);
        stablecoin.mint(msg.sender, mintAmount);
        
        emit CollateralDeposited(msg.sender, msg.value);
        emit StablecoinMinted(msg.sender, mintAmount);
    }

    function repayAndWithdraw(uint256 repayAmount, uint256 withdrawAmount) external nonReentrant {
        debt[msg.sender] -= repayAmount;
        collateral[msg.sender] -= withdrawAmount;

        stablecoin.burn(msg.sender, repayAmount);
        _checkHealthFactor(msg.sender);

        (bool success, ) = payable(msg.sender).call{value: withdrawAmount}("");
        require(success, "Transfer failed");
    }

    function _checkHealthFactor(address user) internal view {
        uint256 price = priceFeed.getLatestPrice();
        uint256 collateralValue = (collateral[user] * price) / 1e18;
        uint256 minCollateralRequired = (debt[user] * LIQUIDATION_THRESHOLD) / PRECISION;
        
        require(collateralValue >= minCollateralRequired, "Breaches collateral ratio");
    }
}
