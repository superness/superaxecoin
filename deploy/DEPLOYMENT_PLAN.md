# SuperAxeCoin Deployment Plan

## Phase 1: Seed Node Droplets

### Droplet Specifications
- **OS**: Ubuntu 22.04 LTS
- **Size**: 2GB RAM, 1 vCPU, 50GB SSD ($12/month each)
- **Locations**:
  - Droplet 1: NYC (US East)
  - Droplet 2: SFO (US West)
  - Droplet 3: AMS (Europe)

### DNS Setup (do this after droplets are created)
```
seed1.superaxecoin.org  →  <NYC droplet IP>
seed2.superaxecoin.org  →  <SFO droplet IP>
seed3.superaxecoin.org  →  <AMS droplet IP>
testnet-seed.superaxecoin.org  →  <any droplet IP>
```

---

## Phase 2: Seed Node Deployment

Each droplet runs BOTH testnet and mainnet daemons:

| Network | Port | RPC Port | Data Directory |
|---------|------|----------|----------------|
| Mainnet | 8833 | 8832 | /data/superaxecoin |
| Testnet | 18833 | 18832 | /data/superaxecoin-testnet |

### Deployment Steps (per droplet)
1. SSH into droplet
2. Run the deployment script (see deploy/seed_node_setup.sh)
3. Verify both daemons are running

---

## Phase 3: Testnet Pool + Mining

### Your Local Setup
1. Run SuperAxeCoin testnet daemon locally
2. Configure your stratum software to connect to local daemon
3. Point Bitaxe to your stratum server
4. Mine testnet blocks

### Stratum Configuration
- Daemon RPC: localhost:18832 (testnet)
- Stratum Port: 3333 (for miners)
- Coin: SuperAxeCoin
- Algorithm: SHA256d

---

## Phase 4: Mainnet Pool + Mining

Same as Phase 3, but:
- Daemon RPC: localhost:8832 (mainnet)
- Different stratum port if running both: 3334

---

## Network Summary

### Mainnet
- **Genesis**: `000000f8fbca27c6b0401c11badfe6525ea6211aa929209cabde3aa4f7c28c12`
- **Port**: 8833
- **Address Prefix**: `axe1...`
- **Block Reward**: 500 AXE
- **Block Time**: 2 minutes

### Testnet
- **Genesis**: `0000023ec7b5434923708046e5ac5c6c817ad1926646f7d03edcb506295a0267`
- **Port**: 18833
- **Address Prefix**: `taxe1...`
- **Block Reward**: 500 AXE
- **Block Time**: 2 minutes
