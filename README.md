# Stablecoin CDP Engine

This repository provides a minimalist version of a MakerDAO-style decentralized stablecoin engine. It demonstrates the fundamental mechanics of DeFi lending: over-collateralization, debt minting, and liquidation thresholds.

## Core Mechanism
- **Deposit**: Users lock ETH as collateral.
- **Mint**: Users mint `STBL` tokens against their ETH up to a 150% collateralization ratio.
- **Liquidation**: If the value of the ETH drops below the 150% threshold, the position becomes eligible for liquidation to ensure protocol solvency.
- **Repay**: Users burn `STBL` to unlock their ETH.



## Key Calculations
- **Health Factor**: Determines how close a position is to liquidation.
- **Price Oracle**: Integrates with Chainlink to fetch real-time ETH/USD prices.

## Security
- **Over-collateralization**: Essential to buffer against crypto volatility.
- **Safe Math**: Handled natively by Solidity 0.8+.
