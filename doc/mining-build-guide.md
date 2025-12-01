# SuperAxeCoin Mining Pool Build Guide

This guide provides specific instructions for building SuperAxeCoin daemon for mining pool integration with SQLite wallet support.

## Overview

SuperAxeCoin uses a 2-minute block time with LWMA (Linear Weighted Moving Average) difficulty adjustment. The daemon built with SQLite wallet support provides modern descriptor wallets suitable for mining pool operations.

## Prerequisites

- Ubuntu/Debian Linux (tested on WSL2)
- Minimum 2GB RAM for compilation
- 4GB+ disk space for build artifacts

## Build Steps

### 1. Install Dependencies

```bash
# Core build dependencies
sudo apt-get update
sudo apt-get install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3

# SuperAxeCoin specific dependencies
sudo apt-get install libevent-dev libboost-dev libsqlite3-dev
```

### 2. Configure and Build

```bash
# Generate build configuration
./autogen.sh

# Configure with wallet support (SQLite backend)
./configure --enable-wallet

# Clean any previous build artifacts
make clean

# Build daemon and CLI (use all CPU cores)
make src/superaxecoind src/superaxecoin-cli -j$(nproc)
```

### 3. Verify Build

```bash
# Check binary size and dependencies
ls -lh src/superaxecoind src/superaxecoin-cli

# Verify SQLite support
ldd src/superaxecoind | grep sqlite

# Test daemon startup
src/superaxecoind --version
```

### 4. Deploy to Production

```bash
# Create production directory
sudo mkdir -p /home/nodes/superaxecoin/bin

# Copy binaries
sudo cp src/superaxecoind src/superaxecoin-cli /home/nodes/superaxecoin/bin/

# Set permissions
sudo chmod +x /home/nodes/superaxecoin/bin/*

# Verify deployment
/home/nodes/superaxecoin/bin/superaxecoind --version
```

## Mining Pool Configuration

### Basic Daemon Configuration

Create `/home/nodes/superaxecoin/superaxecoin.conf`:

```
# Network
rpcuser=your_rpc_user
rpcpassword=your_secure_password
rpcport=9999
rpcbind=127.0.0.1
rpcallowip=127.0.0.1

# Mining
server=1
txindex=1

# Wallet (SQLite backend)
descriptors=1
```

### Starting the Daemon

```bash
# Start daemon
/home/nodes/superaxecoin/bin/superaxecoind -daemon

# Check status
/home/nodes/superaxecoin/bin/superaxecoin-cli getblockchaininfo

# Create wallet for mining rewards
/home/nodes/superaxecoin/bin/superaxecoin-cli createwallet "mining"
```

## Troubleshooting

### Build Issues

1. **Linking errors**: Run `make clean` and rebuild
2. **SQLite missing**: Ensure `libsqlite3-dev` is installed
3. **Memory issues**: Use fewer parallel jobs (`-j2` instead of `-j$(nproc)`)

### Runtime Issues

1. **Permission denied**: Check binary permissions with `ls -l`
2. **Library missing**: Verify dependencies with `ldd src/superaxecoind`
3. **Config errors**: Check `/home/nodes/superaxecoin/debug.log`

## Performance Notes

- Built daemon is ~255MB with debug symbols
- SQLite wallet provides better performance than legacy BDB
- Use descriptor wallets for modern features
- Enable `txindex=1` for mining pool operations

## Network Information

- **Block Time**: 2 minutes
- **Difficulty Adjustment**: LWMA (Linear Weighted Moving Average)
- **Default P2P Port**: 9998
- **Default RPC Port**: 9999
- **Testnet**: Available for testing mining operations