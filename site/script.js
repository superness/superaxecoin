// SuperAxeCoin Website JavaScript
class SuperAxeWeb {
    constructor() {
        this.walletConnected = false;
        this.currentTab = 'blocks';
        this.mockData = this.generateMockData();
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.setupNavigation();
        this.setupExplorer();
        this.updateStats();
        this.startDataRefresh();
        this.setupMiningCalculator();
        this.animateElements();
    }

    setupEventListeners() {
        // Mobile menu toggle
        const mobileToggle = document.getElementById('mobileToggle');
        mobileToggle?.addEventListener('click', this.toggleMobileMenu.bind(this));

        // Wallet connection
        document.getElementById('connectWallet')?.addEventListener('click', this.connectWallet.bind(this));
        document.getElementById('webWalletConnect')?.addEventListener('click', this.createWebWallet.bind(this));

        // Wallet actions
        document.getElementById('sendBtn')?.addEventListener('click', () => this.showSendForm());
        document.getElementById('receiveBtn')?.addEventListener('click', () => this.showReceiveAddress());
        document.getElementById('historyBtn')?.addEventListener('click', () => this.showTransactionHistory());
        document.getElementById('confirmSend')?.addEventListener('click', () => this.sendTransaction());

        // Explorer search
        document.getElementById('searchBtn')?.addEventListener('click', this.performSearch.bind(this));
        document.getElementById('explorerSearch')?.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.performSearch();
        });

        // Explorer tabs
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.switchTab(e.target.dataset.tab));
        });

        // Mining calculator
        document.getElementById('calculateBtn')?.addEventListener('click', this.calculateMining.bind(this));

        // Smooth scroll for navigation
        document.querySelectorAll('a[href^="#"]').forEach(link => {
            link.addEventListener('click', this.smoothScroll.bind(this));
        });

        // Window scroll for navbar
        window.addEventListener('scroll', this.handleScroll.bind(this));
    }

    setupNavigation() {
        const navLinks = document.querySelectorAll('.nav-link');
        const sections = document.querySelectorAll('section[id]');

        // Intersection Observer for active nav states
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    navLinks.forEach(link => link.classList.remove('active'));
                    const activeLink = document.querySelector(`[href="#${entry.target.id}"]`);
                    activeLink?.classList.add('active');
                }
            });
        }, { threshold: 0.3 });

        sections.forEach(section => observer.observe(section));
    }

    setupExplorer() {
        this.displayBlocks();
        this.displayTransactions();
        this.displayNetworkStats();
    }

    generateMockData() {
        const now = Date.now();
        const blocks = [];
        const transactions = [];

        // Generate mock blocks
        for (let i = 0; i < 10; i++) {
            const blockHeight = 50000 - i;
            const blockTime = new Date(now - (i * 120000)); // 2 minutes apart
            
            blocks.push({
                height: blockHeight,
                hash: this.generateHash(),
                timestamp: blockTime,
                transactions: Math.floor(Math.random() * 50) + 1,
                size: (Math.random() * 500 + 100).toFixed(0) + ' KB',
                reward: (500 / Math.pow(2, Math.floor(blockHeight / 210000))).toFixed(8)
            });
        }

        // Generate mock transactions
        for (let i = 0; i < 20; i++) {
            const txTime = new Date(now - (Math.random() * 600000)); // Random within 10 minutes
            
            transactions.push({
                hash: this.generateHash(),
                timestamp: txTime,
                amount: (Math.random() * 100).toFixed(8),
                fee: (Math.random() * 0.001).toFixed(8),
                confirmations: Math.floor(Math.random() * 10) + 1
            });
        }

        return { blocks, transactions };
    }

    generateHash() {
        const chars = '0123456789abcdef';
        let hash = '';
        for (let i = 0; i < 64; i++) {
            hash += chars[Math.floor(Math.random() * chars.length)];
        }
        return hash;
    }

    displayBlocks() {
        const container = document.getElementById('blocksContainer');
        const template = document.getElementById('blockTemplate');
        
        if (!container || !template) return;

        container.innerHTML = '';
        
        this.mockData.blocks.forEach(block => {
            const blockElement = template.cloneNode(true);
            blockElement.style.display = 'block';
            blockElement.id = '';
            
            blockElement.querySelector('.height-value').textContent = block.height.toLocaleString();
            blockElement.querySelector('.hash-value').textContent = block.hash.substring(0, 16) + '...';
            blockElement.querySelector('.block-time').textContent = this.formatTime(block.timestamp);
            blockElement.querySelector('.block-txs').textContent = block.transactions;
            blockElement.querySelector('.block-size').textContent = block.size;
            blockElement.querySelector('.reward-value').textContent = block.reward;
            
            container.appendChild(blockElement);
        });
    }

    displayTransactions() {
        const container = document.getElementById('transactionsContainer');
        const template = document.getElementById('txTemplate');
        
        if (!container || !template) return;

        container.innerHTML = '';
        
        this.mockData.transactions.forEach(tx => {
            const txElement = template.cloneNode(true);
            txElement.style.display = 'block';
            txElement.id = '';
            
            txElement.querySelector('.tx-hash-value').textContent = tx.hash.substring(0, 16) + '...';
            txElement.querySelector('.tx-time').textContent = this.formatTime(tx.timestamp);
            txElement.querySelector('.tx-amount').textContent = tx.amount;
            txElement.querySelector('.tx-fee').textContent = tx.fee;
            
            container.appendChild(txElement);
        });
    }

    displayNetworkStats() {
        // Update network statistics
        const hashRate = (Math.random() * 1000 + 500).toFixed(2);
        const difficulty = (Math.random() * 1000000 + 500000).toFixed(0);
        const totalSupply = (25000000 + Math.random() * 1000000).toFixed(0);
        const nextHalving = (210000 - (50000 % 210000)).toLocaleString();

        document.getElementById('networkHashRate').textContent = hashRate + ' TH/s';
        document.getElementById('networkDifficulty').textContent = Number(difficulty).toLocaleString();
        document.getElementById('totalSupply').textContent = Number(totalSupply).toLocaleString() + ' AXE';
        document.getElementById('nextHalving').textContent = nextHalving + ' blocks';
    }

    updateStats() {
        // Update hero stats with mock data
        const price = (Math.random() * 10 + 1).toFixed(4);
        const blockHeight = (50000 + Math.random() * 1000).toFixed(0);
        const hashRate = (Math.random() * 1000 + 500).toFixed(2);

        document.getElementById('currentPrice').textContent = '$' + price;
        document.getElementById('blockHeight').textContent = Number(blockHeight).toLocaleString();
        document.getElementById('hashRate').textContent = hashRate + ' TH/s';

        // Update mining reward
        const currentReward = 500 / Math.pow(2, Math.floor(blockHeight / 210000));
        document.getElementById('currentReward').textContent = currentReward.toFixed(2) + ' AXE';
    }

    startDataRefresh() {
        // Refresh data every 30 seconds
        setInterval(() => {
            this.updateStats();
            this.mockData = this.generateMockData();
            this.displayBlocks();
            this.displayTransactions();
            this.displayNetworkStats();
        }, 30000);
    }

    switchTab(tabName) {
        // Switch explorer tabs
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
        
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
        document.getElementById(tabName).classList.add('active');
        
        this.currentTab = tabName;
    }

    performSearch() {
        const query = document.getElementById('explorerSearch').value.trim();
        if (!query) return;

        // Simulate search functionality
        this.showNotification(`Searching for: ${query}`, 'info');
        
        // In a real implementation, this would query the blockchain
        setTimeout(() => {
            this.showNotification('Search functionality will be implemented with blockchain API', 'warning');
        }, 1000);
    }

    async connectWallet() {
        const btn = document.getElementById('connectWallet');
        const originalText = btn.textContent;
        
        btn.textContent = 'Connecting...';
        btn.disabled = true;

        try {
            // Simulate wallet connection
            await this.sleep(2000);
            
            if (typeof window.ethereum !== 'undefined') {
                // Try MetaMask or other web3 wallet
                this.showNotification('MetaMask detected, but SuperAxeCoin support not yet implemented', 'warning');
            } else {
                // Show wallet options
                this.showWalletOptions();
            }
        } catch (error) {
            this.showNotification('Failed to connect wallet', 'error');
        } finally {
            btn.textContent = originalText;
            btn.disabled = false;
        }
    }

    async createWebWallet() {
        const btn = document.getElementById('webWalletConnect');
        const originalText = btn.textContent;
        
        btn.textContent = 'Creating...';
        btn.disabled = true;

        try {
            await this.sleep(2000);
            
            // Simulate wallet creation
            const walletAddress = 'S' + this.generateHash().substring(0, 33);
            const balance = (Math.random() * 100).toFixed(8);
            
            this.walletConnected = true;
            this.showWalletInterface(walletAddress, balance);
            this.showNotification('Web wallet created successfully!', 'success');
            
        } catch (error) {
            this.showNotification('Failed to create wallet', 'error');
        } finally {
            btn.textContent = originalText;
            btn.disabled = false;
        }
    }

    showWalletInterface(address, balance) {
        const walletInterface = document.getElementById('walletInterface');
        const addressElement = document.getElementById('walletAddress');
        const balanceElement = document.getElementById('walletBalance');
        const balanceUsdElement = document.getElementById('balanceUsd');
        
        walletInterface.style.display = 'block';
        addressElement.textContent = address.substring(0, 20) + '...';
        balanceElement.textContent = balance;
        
        // Calculate USD value
        const price = parseFloat(document.getElementById('currentPrice').textContent.replace('$', ''));
        const usdValue = (parseFloat(balance) * price).toFixed(2);
        balanceUsdElement.textContent = `$${usdValue} USD`;
    }

    showSendForm() {
        const sendForm = document.getElementById('sendForm');
        sendForm.style.display = sendForm.style.display === 'none' ? 'block' : 'none';
    }

    showReceiveAddress() {
        const address = document.getElementById('walletAddress').textContent;
        this.showNotification(`Your receive address: ${address}`, 'info');
    }

    showTransactionHistory() {
        this.showNotification('Transaction history feature coming soon!', 'info');
    }

    sendTransaction() {
        const recipient = document.getElementById('recipientAddress').value;
        const amount = document.getElementById('sendAmount').value;
        const fee = document.getElementById('sendFee').value;
        
        if (!recipient || !amount) {
            this.showNotification('Please fill in all required fields', 'error');
            return;
        }
        
        // Simulate transaction
        this.showNotification(`Sending ${amount} AXE to ${recipient.substring(0, 10)}...`, 'info');
        
        setTimeout(() => {
            this.showNotification('Transaction sent successfully!', 'success');
            document.getElementById('sendForm').style.display = 'none';
            
            // Clear form
            document.getElementById('recipientAddress').value = '';
            document.getElementById('sendAmount').value = '';
        }, 2000);
    }

    calculateMining() {
        const hashRate = parseFloat(document.getElementById('hashRateInput').value);
        const power = parseFloat(document.getElementById('powerInput').value);
        const electricityCost = parseFloat(document.getElementById('electricityInput').value);
        
        if (!hashRate) {
            this.showNotification('Please enter your hash rate', 'error');
            return;
        }
        
        // Mining calculation (simplified)
        const networkHashRate = 750; // TH/s
        const blockReward = 500;
        const blocksPerDay = (24 * 60) / 2; // 720 blocks per day
        
        const dailyEarnings = (hashRate / networkHashRate) * blockReward * blocksPerDay;
        const monthlyEarnings = dailyEarnings * 30;
        
        // Power cost calculation
        const dailyPowerCost = power ? (power / 1000) * 24 * electricityCost : 0;
        const axePrice = parseFloat(document.getElementById('currentPrice').textContent.replace('$', ''));
        const dailyProfit = (dailyEarnings * axePrice) - dailyPowerCost;
        
        // Display results
        document.getElementById('dailyEarnings').textContent = dailyEarnings.toFixed(4) + ' AXE';
        document.getElementById('monthlyEarnings').textContent = monthlyEarnings.toFixed(2) + ' AXE';
        document.getElementById('dailyProfit').textContent = '$' + dailyProfit.toFixed(2);
        
        document.getElementById('miningResults').style.display = 'block';
    }

    setupMiningCalculator() {
        // Auto-calculate on input change
        ['hashRateInput', 'powerInput', 'electricityInput'].forEach(id => {
            document.getElementById(id)?.addEventListener('input', () => {
                if (document.getElementById('hashRateInput').value) {
                    this.calculateMining();
                }
            });
        });
    }

    toggleMobileMenu() {
        const navMenu = document.querySelector('.nav-menu');
        navMenu.classList.toggle('mobile-open');
    }

    smoothScroll(e) {
        e.preventDefault();
        const targetId = e.target.getAttribute('href').substring(1);
        const targetElement = document.getElementById(targetId);
        
        if (targetElement) {
            const offset = 80; // Account for fixed navbar
            const elementPosition = targetElement.getBoundingClientRect().top;
            const offsetPosition = elementPosition + window.pageYOffset - offset;
            
            window.scrollTo({
                top: offsetPosition,
                behavior: 'smooth'
            });
        }
    }

    handleScroll() {
        const navbar = document.querySelector('.navbar');
        if (window.scrollY > 50) {
            navbar.style.background = 'rgba(20, 20, 30, 0.95)';
        } else {
            navbar.style.background = 'var(--glass-bg)';
        }
    }

    animateElements() {
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('fade-in-up');
                }
            });
        }, observerOptions);

        document.querySelectorAll('.feature-card, .wallet-card, .stat-card').forEach(el => {
            observer.observe(el);
        });
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.style.cssText = `
            position: fixed;
            top: 100px;
            right: 20px;
            padding: 16px 24px;
            background: ${this.getNotificationColor(type)};
            color: white;
            border-radius: 8px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.2);
            z-index: 10000;
            max-width: 400px;
            word-wrap: break-word;
            animation: slideIn 0.3s ease;
        `;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        // Remove after 5 seconds
        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 5000);
    }

    getNotificationColor(type) {
        switch(type) {
            case 'success': return '#4ade80';
            case 'error': return '#f87171';
            case 'warning': return '#facc15';
            default: return '#667eea';
        }
    }

    showWalletOptions() {
        this.showNotification('Please download SuperAxeCoin Core wallet or create a web wallet below', 'info');
    }

    formatTime(timestamp) {
        const now = new Date();
        const diff = now - timestamp;
        const minutes = Math.floor(diff / 60000);
        
        if (minutes < 1) return 'Just now';
        if (minutes < 60) return `${minutes}m ago`;
        if (minutes < 1440) return `${Math.floor(minutes / 60)}h ago`;
        return `${Math.floor(minutes / 1440)}d ago`;
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Global functions
function scrollToSection(sectionId) {
    const element = document.getElementById(sectionId);
    if (element) {
        const offset = 80;
        const elementPosition = element.getBoundingClientRect().top;
        const offsetPosition = elementPosition + window.pageYOffset - offset;
        
        window.scrollTo({
            top: offsetPosition,
            behavior: 'smooth'
        });
    }
}

// CSS animations for notifications
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
    
    .nav-menu.mobile-open {
        display: flex !important;
        position: fixed;
        top: 80px;
        left: 0;
        right: 0;
        flex-direction: column;
        background: rgba(20, 20, 30, 0.95);
        backdrop-filter: blur(20px);
        padding: 2rem;
        gap: 1rem;
    }
    
    @media (max-width: 768px) {
        .nav-menu {
            display: none;
        }
    }
`;
document.head.appendChild(style);

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.superAxeWeb = new SuperAxeWeb();
});

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SuperAxeWeb;
}