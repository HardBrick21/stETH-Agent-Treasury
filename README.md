# stETH Agent Treasury

> Yield-powered treasury for AI agents using stETH - Earn yield while protecting principal

## Overview

This project creates a treasury system for AI agents using Lido's stETH. Agents can earn yield on their treasury balance while maintaining principal protection.

## Why stETH Treasury?

- **Yield Generation** - Earn staking rewards automatically
- **Principal Protection** - Minimum principal cannot be withdrawn
- **Agent Control** - Agents can withdraw yield, owner controls principal
- **Full Transparency** - All treasury operations on-chain

## Key Features

1. **Yield Accumulation** - Track and accumulate stETH rebasing rewards
2. **Principal Protection** - Minimum 0.1 stETH always protected
3. **Yield Withdrawals** - Agents can withdraw accumulated yield
4. **Cooldown Period** - 24-hour cooldown for security
5. **Full Audit Trail** - All withdrawals recorded on-chain

## Contract Addresses

| Contract | Address | Network |
|----------|---------|---------|
| StETHAgentTreasury | TBD | Ethereum Mainnet |
| stETH | `0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84` | Ethereum |
| wstETH | `0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0` | Ethereum |

## Quick Start

```bash
# Install dependencies
npm install

# Compile
npx hardhat compile

# Deploy to mainnet
npx hardhat run scripts/deploy.js --network mainnet
```

## Usage

### Create Treasury

```javascript
// Deposit 10 stETH for an agent
await contract.createTreasury(
  agentAddress,
  ethers.parseEther("10") // 10 stETH
);
```

### Request Yield Withdrawal

```javascript
// Agent requests to withdraw 1 stETH of yield
await contract.requestYieldWithdrawal(
  agentAddress,
  ethers.parseEther("1")
);
```

### Execute Withdrawal

```javascript
// Owner executes after cooldown
await contract.executeWithdrawal(
  requestId,
  recipientAddress
);
```

## Treasury Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    stETH Agent Treasury                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Principal (Protected)                                      │
│   ├── Minimum: 0.1 stETH                                     │
│   ├── Cannot be withdrawn by agent                          │
│   └── Owner-controlled with cooldown                        │
│                                                              │
│   Yield (Accessible)                                         │
│   ├── Accumulated from staking rewards                       │
│   ├── Agent can withdraw                                     │
│   └── No cooldown required                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

*stETH Treasury - Yield for agents, protection for principals.*