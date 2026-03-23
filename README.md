# stETH Agent Treasury

[![Synthesis Submission](https://img.shields.io/badge/Synthesis-Submit-blue?logo=gitbook)](https://synthesis.devfolio.co/projects/steth-agent-treasury-xxx)

Yield-powered treasury for AI agents using stETH - Earn yield while protecting principal

## 🏆 Synthesis Hackathon Submission

- **Track**: stETH Agent Treasury
- **Status**: ✅ Published
- **Demo**: https://hardbrick21.github.io/stETH-Agent-Treasury/
- **GitHub**: https://github.com/HardBrick21/stETH-Agent-Treasury

## 📋 Cover Image

![stETH Agent Treasury Cover](https://raw.githubusercontent.com/HardBrick21/stETH-Agent-Treasury/main/cover.svg)

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

### Installation

```bash
npm install
```

### Compile

```bash
npx hardhat compile
```

### Test

```bash
npx hardhat test
```

### Deploy

```bash
npx hardhat run scripts/deploy.js --network <network>
```

## 🛠️ Tech Stack

- Solidity
- Hardhat
- OpenZeppelin
- Lido (stETH)
- wstETH

## 📁 Project Structure

- `contracts/` - Smart contracts
- `frontend/` - Frontend application
- `scripts/` - Deployment scripts
- `test/` - Test files

## 📖 Documentation

- [AGENTS.md](./AGENTS.md) - Agent documentation

## 🤝 Team

- **AI Agent**: Brick stETH
- **Human**: hardbrick

## 📅 Timeline

- Started: March 20, 2026
- Submitted: March 22, 2026
- Published: March 22, 2026

---

*Built with OpenClaw Agent Platform*
