#!/bin/bash
#
# SuperAxeCoin Control Panel
# Interactive dashboard for managing SuperAxeCoin infrastructure
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration - UPDATE THESE
DROPLET_1_IP="104.236.106.124"
DROPLET_2_IP="64.225.115.108"
DROPLET_3_IP="161.35.82.147"
DROPLET_USER="root"

LOCAL_DAEMON_PATH="./src/superaxecoind"
LOCAL_CLI_PATH="./src/superaxecoin-cli"
LOCAL_MAINNET_DATA="/tmp/superaxecoin-mainnet"
LOCAL_TESTNET_DATA="/tmp/superaxecoin-testnet"

# Functions
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║     ███████╗██╗   ██╗██████╗ ███████╗██████╗  █████╗ ██╗  ██╗███████╗    ║"
    echo "║     ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗██╔╝██╔════╝    ║"
    echo "║     ███████╗██║   ██║██████╔╝█████╗  ██████╔╝███████║ ╚███╔╝ █████╗      ║"
    echo "║     ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗██╔══██║ ██╔██╗ ██╔══╝      ║"
    echo "║     ███████║╚██████╔╝██║     ███████╗██║  ██║██║  ██║██╔╝ ██╗███████╗    ║"
    echo "║     ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ║"
    echo "║                                                               ║"
    echo "║                    CONTROL PANEL v1.0                         ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status_box() {
    local title=$1
    local status=$2
    local color=$3
    echo -e "  ${color}■${NC} ${title}: ${color}${status}${NC}"
}

check_local_daemon() {
    local network=$1
    local datadir=$2
    local cli=$LOCAL_CLI_PATH

    if [ "$network" == "testnet" ]; then
        result=$($cli -testnet -datadir=$datadir getblockchaininfo 2>/dev/null)
    else
        result=$($cli -datadir=$datadir getblockchaininfo 2>/dev/null)
    fi

    if [ $? -eq 0 ]; then
        blocks=$(echo $result | grep -o '"blocks":[0-9]*' | cut -d: -f2)
        echo "$blocks"
    else
        echo "OFFLINE"
    fi
}

check_remote_daemon() {
    local ip=$1
    local port=$2

    if [ -z "$ip" ]; then
        echo "NOT_CONFIGURED"
        return
    fi

    timeout 2 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "ONLINE"
    else
        echo "OFFLINE"
    fi
}

show_status() {
    print_header
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}                        NETWORK STATUS${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${YELLOW}LOCAL NODES:${NC}"
    echo "─────────────────────────────────────────────────────────────────"

    mainnet_status=$(check_local_daemon "mainnet" "$LOCAL_MAINNET_DATA")
    if [ "$mainnet_status" == "OFFLINE" ]; then
        print_status_box "Mainnet" "OFFLINE" "$RED"
    else
        print_status_box "Mainnet" "ONLINE (Block $mainnet_status)" "$GREEN"
    fi

    testnet_status=$(check_local_daemon "testnet" "$LOCAL_TESTNET_DATA")
    if [ "$testnet_status" == "OFFLINE" ]; then
        print_status_box "Testnet" "OFFLINE" "$RED"
    else
        print_status_box "Testnet" "ONLINE (Block $testnet_status)" "$GREEN"
    fi

    echo ""
    echo -e "${YELLOW}SEED NODES (DROPLETS):${NC}"
    echo "─────────────────────────────────────────────────────────────────"

    for i in 1 2 3; do
        eval "ip=\$DROPLET_${i}_IP"
        if [ -z "$ip" ]; then
            print_status_box "Droplet $i" "NOT CONFIGURED" "$YELLOW"
        else
            mainnet=$(check_remote_daemon "$ip" 8833)
            testnet=$(check_remote_daemon "$ip" 18833)
            if [ "$mainnet" == "ONLINE" ] && [ "$testnet" == "ONLINE" ]; then
                print_status_box "Droplet $i ($ip)" "BOTH ONLINE" "$GREEN"
            elif [ "$mainnet" == "ONLINE" ]; then
                print_status_box "Droplet $i ($ip)" "Mainnet only" "$YELLOW"
            elif [ "$testnet" == "ONLINE" ]; then
                print_status_box "Droplet $i ($ip)" "Testnet only" "$YELLOW"
            else
                print_status_box "Droplet $i ($ip)" "OFFLINE" "$RED"
            fi
        fi
    done

    echo ""
}

show_main_menu() {
    show_status
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}                         MAIN MENU${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${CYAN}LOCAL OPERATIONS:${NC}"
    echo "  [1] Start local mainnet daemon"
    echo "  [2] Start local testnet daemon"
    echo "  [3] Stop local mainnet daemon"
    echo "  [4] Stop local testnet daemon"
    echo "  [5] Get mainnet wallet info"
    echo "  [6] Get testnet wallet info"
    echo ""
    echo -e "  ${CYAN}DROPLET OPERATIONS:${NC}"
    echo "  [7] Configure droplet IPs"
    echo "  [8] Deploy to droplet"
    echo "  [9] Check droplet status (SSH)"
    echo ""
    echo -e "  ${CYAN}MINING:${NC}"
    echo "  [10] Mine testnet blocks (local)"
    echo "  [11] Mine mainnet blocks (local)"
    echo "  [12] Show stratum config for Bitaxe"
    echo ""
    echo -e "  ${CYAN}OTHER:${NC}"
    echo "  [0] Exit"
    echo ""
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -n "Select option: "
}

start_local_mainnet() {
    echo -e "${YELLOW}Starting local mainnet daemon...${NC}"
    mkdir -p $LOCAL_MAINNET_DATA
    $LOCAL_DAEMON_PATH -datadir=$LOCAL_MAINNET_DATA -daemon
    sleep 2
    echo -e "${GREEN}Done!${NC}"
    read -p "Press Enter to continue..."
}

start_local_testnet() {
    echo -e "${YELLOW}Starting local testnet daemon...${NC}"
    mkdir -p $LOCAL_TESTNET_DATA
    $LOCAL_DAEMON_PATH -testnet -datadir=$LOCAL_TESTNET_DATA -daemon
    sleep 2
    echo -e "${GREEN}Done!${NC}"
    read -p "Press Enter to continue..."
}

stop_local_mainnet() {
    echo -e "${YELLOW}Stopping local mainnet daemon...${NC}"
    $LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA stop 2>/dev/null || echo "Not running"
    echo -e "${GREEN}Done!${NC}"
    read -p "Press Enter to continue..."
}

stop_local_testnet() {
    echo -e "${YELLOW}Stopping local testnet daemon...${NC}"
    $LOCAL_CLI_PATH -testnet -datadir=$LOCAL_TESTNET_DATA stop 2>/dev/null || echo "Not running"
    echo -e "${GREEN}Done!${NC}"
    read -p "Press Enter to continue..."
}

get_mainnet_info() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}MAINNET WALLET INFO${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${YELLOW}Blockchain:${NC}"
    $LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA getblockchaininfo 2>/dev/null || echo "Daemon not running"

    echo ""
    echo -e "${YELLOW}Wallet Balance:${NC}"
    $LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA getbalance 2>/dev/null || echo "No wallet loaded"

    echo ""
    echo -e "${YELLOW}Network Info:${NC}"
    $LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA getnetworkinfo 2>/dev/null | grep -E '"version"|"subversion"|"connections"' || echo "Daemon not running"

    echo ""
    read -p "Press Enter to continue..."
}

get_testnet_info() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}TESTNET WALLET INFO${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    echo -e "${YELLOW}Blockchain:${NC}"
    $LOCAL_CLI_PATH -testnet -datadir=$LOCAL_TESTNET_DATA getblockchaininfo 2>/dev/null || echo "Daemon not running"

    echo ""
    echo -e "${YELLOW}Wallet Balance:${NC}"
    $LOCAL_CLI_PATH -testnet -datadir=$LOCAL_TESTNET_DATA getbalance 2>/dev/null || echo "No wallet loaded"

    echo ""
    read -p "Press Enter to continue..."
}

configure_droplets() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}CONFIGURE DROPLET IPS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Current configuration:"
    echo "  Droplet 1: ${DROPLET_1_IP:-not set}"
    echo "  Droplet 2: ${DROPLET_2_IP:-not set}"
    echo "  Droplet 3: ${DROPLET_3_IP:-not set}"
    echo ""

    read -p "Enter Droplet 1 IP (NYC): " new_ip1
    read -p "Enter Droplet 2 IP (SFO): " new_ip2
    read -p "Enter Droplet 3 IP (AMS): " new_ip3

    # Update the script itself
    sed -i "s/^DROPLET_1_IP=.*/DROPLET_1_IP=\"$new_ip1\"/" "$0"
    sed -i "s/^DROPLET_2_IP=.*/DROPLET_2_IP=\"$new_ip2\"/" "$0"
    sed -i "s/^DROPLET_3_IP=.*/DROPLET_3_IP=\"$new_ip3\"/" "$0"

    DROPLET_1_IP="$new_ip1"
    DROPLET_2_IP="$new_ip2"
    DROPLET_3_IP="$new_ip3"

    echo -e "${GREEN}Configuration saved!${NC}"
    read -p "Press Enter to continue..."
}

deploy_to_droplet() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}DEPLOY TO DROPLET${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Available droplets:"
    echo "  [1] Droplet 1: ${DROPLET_1_IP:-not configured}"
    echo "  [2] Droplet 2: ${DROPLET_2_IP:-not configured}"
    echo "  [3] Droplet 3: ${DROPLET_3_IP:-not configured}"
    echo ""
    read -p "Select droplet (1-3): " droplet_num

    eval "target_ip=\$DROPLET_${droplet_num}_IP"

    if [ -z "$target_ip" ]; then
        echo -e "${RED}Droplet not configured!${NC}"
        read -p "Press Enter to continue..."
        return
    fi

    echo ""
    echo -e "${YELLOW}Deploying to $target_ip...${NC}"
    echo ""

    echo "[1/4] Copying setup script..."
    scp deploy/seed_node_setup.sh ${DROPLET_USER}@${target_ip}:/tmp/

    echo "[2/4] Running setup script..."
    ssh ${DROPLET_USER}@${target_ip} "bash /tmp/seed_node_setup.sh"

    echo "[3/4] Copying binaries..."
    scp src/superaxecoind src/superaxecoin-cli ${DROPLET_USER}@${target_ip}:/opt/superaxecoin/bin/
    ssh ${DROPLET_USER}@${target_ip} "chmod +x /opt/superaxecoin/bin/*"

    echo "[4/4] Starting services..."
    ssh ${DROPLET_USER}@${target_ip} "systemctl enable superaxecoind superaxecoind-testnet && systemctl start superaxecoind superaxecoind-testnet"

    echo ""
    echo -e "${GREEN}Deployment complete!${NC}"
    read -p "Press Enter to continue..."
}

check_droplet_ssh() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}DROPLET SSH STATUS CHECK${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Select droplet:"
    echo "  [1] Droplet 1: ${DROPLET_1_IP:-not configured}"
    echo "  [2] Droplet 2: ${DROPLET_2_IP:-not configured}"
    echo "  [3] Droplet 3: ${DROPLET_3_IP:-not configured}"
    echo ""
    read -p "Select droplet (1-3): " droplet_num

    eval "target_ip=\$DROPLET_${droplet_num}_IP"

    if [ -z "$target_ip" ]; then
        echo -e "${RED}Droplet not configured!${NC}"
        read -p "Press Enter to continue..."
        return
    fi

    echo ""
    echo -e "${YELLOW}Checking services on $target_ip...${NC}"
    echo ""

    ssh ${DROPLET_USER}@${target_ip} "
        echo '=== MAINNET STATUS ==='
        systemctl status superaxecoind --no-pager -l | head -20
        echo ''
        echo '=== TESTNET STATUS ==='
        systemctl status superaxecoind-testnet --no-pager -l | head -20
        echo ''
        echo '=== MAINNET BLOCKCHAIN ==='
        /opt/superaxecoin/bin/superaxecoin-cli -datadir=/data/superaxecoin getblockchaininfo 2>/dev/null || echo 'Not running'
        echo ''
        echo '=== TESTNET BLOCKCHAIN ==='
        /opt/superaxecoin/bin/superaxecoin-cli -testnet -datadir=/data/superaxecoin-testnet getblockchaininfo 2>/dev/null || echo 'Not running'
    "

    echo ""
    read -p "Press Enter to continue..."
}

mine_testnet() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}MINE TESTNET BLOCKS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Get or create address
    addr=$($LOCAL_CLI_PATH -testnet -datadir=$LOCAL_TESTNET_DATA getnewaddress 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Creating wallet..."
        $LOCAL_CLI_PATH -testnet -datadir=$LOCAL_TESTNET_DATA createwallet "mining" 2>/dev/null
        addr=$($LOCAL_CLI_PATH -testnet -datadir=$LOCAL_TESTNET_DATA getnewaddress)
    fi

    echo "Mining address: $addr"
    read -p "Number of blocks to mine: " num_blocks

    echo -e "${YELLOW}Mining $num_blocks blocks...${NC}"
    $LOCAL_CLI_PATH -testnet -datadir=$LOCAL_TESTNET_DATA generatetoaddress $num_blocks $addr 10000000

    echo ""
    echo -e "${GREEN}Done!${NC}"
    balance=$($LOCAL_CLI_PATH -testnet -datadir=$LOCAL_TESTNET_DATA getbalance)
    echo "Current balance: $balance AXE"
    read -p "Press Enter to continue..."
}

mine_mainnet() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}MINE MAINNET BLOCKS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    addr=$($LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA getnewaddress 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Creating wallet..."
        $LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA createwallet "mining" 2>/dev/null
        addr=$($LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA getnewaddress)
    fi

    echo "Mining address: $addr"
    read -p "Number of blocks to mine: " num_blocks

    echo -e "${YELLOW}Mining $num_blocks blocks...${NC}"
    $LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA generatetoaddress $num_blocks $addr 10000000

    echo ""
    echo -e "${GREEN}Done!${NC}"
    balance=$($LOCAL_CLI_PATH -datadir=$LOCAL_MAINNET_DATA getbalance)
    echo "Current balance: $balance AXE"
    read -p "Press Enter to continue..."
}

show_stratum_config() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}STRATUM CONFIGURATION FOR BITAXE${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}For your stratum server software, use these settings:${NC}"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│ TESTNET                                                         │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ Daemon RPC Host:     127.0.0.1                                  │"
    echo "│ Daemon RPC Port:     18832                                      │"
    echo "│ Stratum Port:        3333                                       │"
    echo "│ Coin Algorithm:      SHA256d                                    │"
    echo "│ Address Prefix:      taxe1...                                   │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│ MAINNET                                                         │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ Daemon RPC Host:     127.0.0.1                                  │"
    echo "│ Daemon RPC Port:     8832                                       │"
    echo "│ Stratum Port:        3334                                       │"
    echo "│ Coin Algorithm:      SHA256d                                    │"
    echo "│ Address Prefix:      axe1...                                    │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    echo -e "${YELLOW}Bitaxe Configuration:${NC}"
    echo "  Stratum URL:  stratum+tcp://<your-ip>:3333  (testnet)"
    echo "  Stratum URL:  stratum+tcp://<your-ip>:3334  (mainnet)"
    echo "  Worker:       <your-axe-address>"
    echo "  Password:     x"
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_main_menu
    read choice

    case $choice in
        1) start_local_mainnet ;;
        2) start_local_testnet ;;
        3) stop_local_mainnet ;;
        4) stop_local_testnet ;;
        5) get_mainnet_info ;;
        6) get_testnet_info ;;
        7) configure_droplets ;;
        8) deploy_to_droplet ;;
        9) check_droplet_ssh ;;
        10) mine_testnet ;;
        11) mine_mainnet ;;
        12) show_stratum_config ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done
