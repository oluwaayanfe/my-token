# My Token - Stacks Smart Contract

A fully-featured fungible token contract built on Stacks (Clarity), implementing core token functionality with admin controls, ERC-20-style approvals, and a staking system.

## Features

### Core Token Operations
- **Mint**: Owner-only token creation
- **Burn**: Users can destroy their own tokens
- **Transfer**: Direct token transfers between accounts
- **Total Supply Tracking**: Automatic supply management

### Approval System (ERC-20 Compatible)
- **Approve**: Grant spending rights to another principal
- **Transfer From**: Spend approved tokens on behalf of another user
- Allowance tracking and validation

### Staking System
- **Stake**: Lock tokens to earn or participate in governance
- **Unstake**: Retrieve staked tokens back to balance
- Total staked amount tracking
- Separate staking balance ledger

### Access Control
- Owner-based authorization
- Optional owner pattern for flexible deployment
- Authorization checks on sensitive operations (mint)

## Contract Structure

### Constants
```clarity
ERR_UNAUTHORIZED (u100)           ;; Owner-only operation denied
ERR_INSUFFICIENT_BALANCE (u101)   ;; Not enough tokens
ERR_INVALID_AMOUNT (u102)         ;; Invalid operation amount
ERR_NOT_APPROVED (u103)           ;; Spending not approved
ERR_ALREADY_STAKED (u104)         ;; Reserved for future use
ERR_NOT_STAKED (u105)             ;; Unstaking from zero balance
