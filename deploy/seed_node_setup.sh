#!/bin/bash
#
# SuperAxeCoin Seed Node Setup Script
# Run this on a fresh Ubuntu 22.04 droplet
#
# Usage: curl -sL <url>/seed_node_setup.sh | bash
#

set -e

echo "=============================================="
echo "SuperAxeCoin Seed Node Setup"
echo "=============================================="

# Create superaxecoin user
echo "[1/8] Creating superaxecoin user..."
if ! id "superaxecoin" &>/dev/null; then
    useradd -m -s /bin/bash superaxecoin
fi

# Install dependencies
echo "[2/8] Installing dependencies..."
apt-get update
apt-get install -y wget tar

# Create directories
echo "[3/8] Creating directories..."
mkdir -p /data/superaxecoin
mkdir -p /data/superaxecoin-testnet
mkdir -p /opt/superaxecoin/bin
chown -R superaxecoin:superaxecoin /data/superaxecoin
chown -R superaxecoin:superaxecoin /data/superaxecoin-testnet

# Download binaries (UPDATE THIS URL when releases are published)
echo "[4/8] Downloading SuperAxeCoin binaries..."
# For now, you'll need to copy binaries manually:
# scp superaxecoind superaxecoin-cli root@<droplet>:/opt/superaxecoin/bin/
echo "NOTE: Copy binaries to /opt/superaxecoin/bin/ manually for now"

# Create mainnet config
echo "[5/8] Creating mainnet configuration..."
cat > /data/superaxecoin/superaxecoin.conf << 'EOF'
# SuperAxeCoin Mainnet Configuration
server=1
daemon=0
listen=1
port=8833
rpcport=8832
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
rpcuser=superaxecoinrpc
rpcpassword=CHANGE_THIS_PASSWORD_$(openssl rand -hex 16)

# Seed node settings
maxconnections=125
discover=1

# Logging
debug=0
printtoconsole=0
EOF

# Create testnet config
echo "[6/8] Creating testnet configuration..."
cat > /data/superaxecoin-testnet/superaxecoin.conf << 'EOF'
# SuperAxeCoin Testnet Configuration
testnet=1
server=1
daemon=0
listen=1
port=18833
rpcport=18832
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
rpcuser=superaxecoinrpc
rpcpassword=CHANGE_THIS_PASSWORD_$(openssl rand -hex 16)

# Seed node settings
maxconnections=125
discover=1

# Logging
debug=0
printtoconsole=0
EOF

chown superaxecoin:superaxecoin /data/superaxecoin/superaxecoin.conf
chown superaxecoin:superaxecoin /data/superaxecoin-testnet/superaxecoin.conf

# Create systemd service for mainnet
echo "[7/8] Creating systemd services..."
cat > /etc/systemd/system/superaxecoind.service << 'EOF'
[Unit]
Description=SuperAxeCoin Mainnet Daemon
After=network.target

[Service]
Type=simple
User=superaxecoin
ExecStart=/opt/superaxecoin/bin/superaxecoind -datadir=/data/superaxecoin -conf=/data/superaxecoin/superaxecoin.conf
Restart=always
RestartSec=10
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for testnet
cat > /etc/systemd/system/superaxecoind-testnet.service << 'EOF'
[Unit]
Description=SuperAxeCoin Testnet Daemon
After=network.target

[Service]
Type=simple
User=superaxecoin
ExecStart=/opt/superaxecoin/bin/superaxecoind -testnet -datadir=/data/superaxecoin-testnet -conf=/data/superaxecoin-testnet/superaxecoin.conf
Restart=always
RestartSec=10
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

# Configure firewall
echo "[8/8] Configuring firewall..."
ufw allow 8833/tcp comment 'SuperAxeCoin Mainnet P2P'
ufw allow 18833/tcp comment 'SuperAxeCoin Testnet P2P'
ufw --force enable

echo ""
echo "=============================================="
echo "Setup Complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "1. Copy binaries to /opt/superaxecoin/bin/"
echo "   scp superaxecoind superaxecoin-cli root@<this-ip>:/opt/superaxecoin/bin/"
echo ""
echo "2. Make binaries executable:"
echo "   chmod +x /opt/superaxecoin/bin/*"
echo ""
echo "3. Update RPC passwords in config files:"
echo "   /data/superaxecoin/superaxecoin.conf"
echo "   /data/superaxecoin-testnet/superaxecoin.conf"
echo ""
echo "4. Start the daemons:"
echo "   systemctl enable superaxecoind"
echo "   systemctl enable superaxecoind-testnet"
echo "   systemctl start superaxecoind"
echo "   systemctl start superaxecoind-testnet"
echo ""
echo "5. Check status:"
echo "   systemctl status superaxecoind"
echo "   systemctl status superaxecoind-testnet"
echo ""
