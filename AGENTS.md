# AGENTS.md - stETH Agent Treasury

## Overview

stETH Agent Treasury is a yield-powered treasury for AI agents using Lido's stETH. Agents earn staking rewards while maintaining principal protection.

## What It Does

- **Yield Generation**: Earn staking rewards automatically via stETH rebasing
- **Principal Protection**: Minimum 0.1 stETH always protected
- **Agent Control**: Agents can withdraw accumulated yield
- **Cooldown Period**: 24-hour cooldown for security
- **Full Transparency**: All treasury operations on-chain

## How to Interact

### Smart Contract Interface

**StETHAgentTreasury** (deploy on Ethereum Mainnet)

```solidity
// Create a new treasury for an agent
function createTreasury(
    address agent,
    uint256 initialDeposit
) external onlyOwner nonReentrant;

// Update yield for an agent's treasury
function updateYield(address agent) external;

// Request withdrawal of yield only (principal protected)
function requestYieldWithdrawal(
    address agent,
    uint256 amount
) external onlyAgent(agent) returns (bytes32 requestId);

// Request withdrawal of principal (requires cooldown)
function requestPrincipalWithdrawal(
    address agent,
    uint256 amount
) external onlyOwner returns (bytes32 requestId);

// Execute a withdrawal request
function executeWithdrawal(
    bytes32 requestId,
    address to
) external onlyOwner nonReentrant;

// Get treasury info
function getTreasuryInfo(address agent) external view returns (
    uint256 principal,
    uint256 yieldAccumulated,
    uint256 totalValue,
    bool isActive
);
```

## Contract Addresses

| Contract | Address | Network |
|----------|---------|---------|
| stETH | `0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84` | Ethereum |
| wstETH | `0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0` | Ethereum |

## Integration Guide

### Create Treasury

```javascript
// Deposit 10 stETH for an agent
await contract.createTreasury(
  agentAddress,
  ethers.parseEther("10") // 10 stETH
);
```

### Update Yield

```javascript
// Update yield for an agent
await contract.updateYield(agentAddress);

// Check accumulated yield
const info = await contract.getTreasuryInfo(agentAddress);
console.log("Yield accumulated:", info.yieldAccumulated);
```

### Request Yield Withdrawal

```javascript
// Agent requests to withdraw 1 stETH of yield
const requestId = await contract.requestYieldWithdrawal(
  agentAddress,
  ethers.parseEther("1")
);
```

### Execute Withdrawal

```javascript
// Owner executes after 24-hour cooldown
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

## Security Features

- **Principal Protection**: Minimum 0.1 stETH cannot be withdrawn
- **Cooldown Period**: 24-hour wait for principal withdrawals
- **Reentrancy Guard**: Protected against reentrancy attacks
- **Owner Control**: Only owner can execute withdrawals

## Target Track

**stETH Agent Treasury** ($3,000)

---

*stETH Treasury - Yield for agents, protection for principals.*