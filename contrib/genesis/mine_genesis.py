#!/usr/bin/env python3
"""
SuperAxeCoin Genesis Block Miner

This script mines the genesis block for SuperAxeCoin.
It finds a nonce that produces a block hash below the target difficulty.

Usage:
    python3 mine_genesis.py

Parameters (matching SuperAxeCoin spec):
    - Timestamp: 1732924800 (Nov 30, 2024 00:00:00 UTC)
    - Message: "SuperAxeCoin - Mining for the rest of us"
    - nBits: 0x1d00ffff (standard difficulty 1.0)
    - Reward: 500 AXE
"""

import hashlib
import struct
import time
import sys

def sha256(data):
    return hashlib.sha256(data).digest()

def sha256d(data):
    return sha256(sha256(data))

def uint256_from_compact(bits):
    """Convert compact difficulty target to uint256."""
    size = bits >> 24
    word = bits & 0x007fffff
    if size <= 3:
        word >>= 8 * (3 - size)
    else:
        word <<= 8 * (size - 3)
    return word

def serialize_script(message):
    """Create coinbase script with timestamp message."""
    script = bytes([0x04, 0xff, 0xff, 0x00, 0x1d])  # nBits push
    script += bytes([0x01, 0x04])  # Push 4 bytes
    msg_bytes = message.encode('utf-8')
    script += bytes([len(msg_bytes)]) + msg_bytes
    return script

def create_coinbase_tx(timestamp_str, reward_satoshis):
    """Create the genesis coinbase transaction."""
    # Version (4 bytes)
    tx = struct.pack('<I', 1)

    # Input count (varint)
    tx += bytes([1])

    # Previous output hash (32 bytes of zeros)
    tx += bytes(32)

    # Previous output index (0xffffffff)
    tx += struct.pack('<I', 0xffffffff)

    # Script with timestamp
    script = serialize_script(timestamp_str)
    tx += bytes([len(script)]) + script

    # Sequence
    tx += struct.pack('<I', 0xffffffff)

    # Output count
    tx += bytes([1])

    # Value (500 AXE = 500 * 100000000 satoshis)
    tx += struct.pack('<Q', reward_satoshis)

    # Output script (standard P2PK to well-known pubkey)
    pubkey = bytes.fromhex('04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f')
    output_script = bytes([len(pubkey)]) + pubkey + bytes([0xac])  # OP_CHECKSIG
    tx += bytes([len(output_script)]) + output_script

    # Locktime
    tx += struct.pack('<I', 0)

    return tx

def merkle_root(txhashes):
    """Calculate merkle root from transaction hashes."""
    if len(txhashes) == 0:
        return bytes(32)
    if len(txhashes) == 1:
        return txhashes[0]

    while len(txhashes) > 1:
        if len(txhashes) % 2 != 0:
            txhashes.append(txhashes[-1])
        new_hashes = []
        for i in range(0, len(txhashes), 2):
            new_hashes.append(sha256d(txhashes[i] + txhashes[i+1]))
        txhashes = new_hashes

    return txhashes[0]

def create_block_header(version, prev_hash, merkle_root_hash, timestamp, bits, nonce):
    """Create a block header."""
    header = struct.pack('<I', version)           # Version
    header += prev_hash                            # Previous block hash
    header += merkle_root_hash                     # Merkle root
    header += struct.pack('<I', timestamp)         # Timestamp
    header += struct.pack('<I', bits)              # nBits (difficulty)
    header += struct.pack('<I', nonce)             # Nonce
    return header

def mine_genesis():
    """Mine the SuperAxeCoin genesis block."""

    print("=" * 60)
    print("SuperAxeCoin Genesis Block Miner")
    print("=" * 60)

    # Genesis block parameters (from spec)
    timestamp = 1732924800  # Nov 30, 2024 00:00:00 UTC
    message = "SuperAxeCoin - Mining for the rest of us"
    # Use easier difficulty for faster genesis mining
    # 0x1e00ffff is 256x easier than 0x1d00ffff (Bitcoin's "difficulty 1")
    # LWMA will adjust difficulty based on actual network hashrate
    bits = 0x1e00ffff  # Easier starting difficulty
    version = 1
    reward = 500 * 100000000  # 500 AXE in satoshis

    print(f"\nParameters:")
    print(f"  Timestamp: {timestamp}")
    print(f"  Message: {message}")
    print(f"  nBits: 0x{bits:08x}")
    print(f"  Reward: {reward / 100000000} AXE")

    # Create coinbase transaction
    coinbase_tx = create_coinbase_tx(message, reward)
    coinbase_hash = sha256d(coinbase_tx)
    merkle = merkle_root([coinbase_hash])

    print(f"\nCoinbase TX Hash: {coinbase_hash[::-1].hex()}")
    print(f"Merkle Root: {merkle[::-1].hex()}")

    # Calculate target
    target = uint256_from_compact(bits)
    print(f"\nTarget: {target}")
    print(f"\nMining genesis block...")

    prev_hash = bytes(32)  # Genesis has no previous block
    start_time = time.time()
    nonce = 0

    while True:
        header = create_block_header(version, prev_hash, merkle, timestamp, bits, nonce)
        block_hash = sha256d(header)

        # Convert to integer for comparison (little-endian)
        hash_int = int.from_bytes(block_hash, 'little')

        if hash_int < target:
            # Found valid hash!
            elapsed = time.time() - start_time
            print(f"\n" + "=" * 60)
            print("SUCCESS! Genesis block found!")
            print("=" * 60)
            print(f"\nNonce: {nonce}")
            print(f"Hash: {block_hash[::-1].hex()}")
            print(f"Merkle Root: {merkle[::-1].hex()}")
            print(f"Time elapsed: {elapsed:.2f} seconds")
            print(f"Hashrate: {nonce / elapsed:.0f} H/s")

            print("\n" + "-" * 60)
            print("C++ Code for chainparams.cpp:")
            print("-" * 60)
            print(f'''
genesis = CreateGenesisBlock({timestamp}, {nonce}, 0x{bits:08x}, 1, 500 * COIN);
consensus.hashGenesisBlock = genesis.GetHash();
assert(consensus.hashGenesisBlock == uint256S("0x{block_hash[::-1].hex()}"));
assert(genesis.hashMerkleRoot == uint256S("0x{merkle[::-1].hex()}"));
''')
            return nonce, block_hash[::-1].hex(), merkle[::-1].hex()

        nonce += 1

        if nonce % 100000 == 0:
            elapsed = time.time() - start_time
            hashrate = nonce / elapsed if elapsed > 0 else 0
            print(f"  Nonce: {nonce:,} | Hashrate: {hashrate:.0f} H/s | Time: {elapsed:.1f}s")

        if nonce > 0xffffffff:
            print("Error: Nonce overflow! Try different timestamp.")
            sys.exit(1)

if __name__ == "__main__":
    mine_genesis()
