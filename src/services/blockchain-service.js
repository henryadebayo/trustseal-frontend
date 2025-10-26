const { ethers } = require('ethers');
const axios = require('axios');
const logger = require('../config/logger');
const blockchainConfig = require('../config/blockchain');

class BlockchainService {
    constructor() {
        // Default to BlockDAG network
        this.network = blockchainConfig.BLOCKDAG.MAINNET;
        this.provider = new ethers.JsonRpcProvider(this.network.RPC_URL);
        this.etherscanApiKey = process.env.ETHERSCAN_API_KEY;
        this.blockdagExplorerApiKey = process.env.BLOCKDAG_EXPLORER_API_KEY;
    }

    // Set network (BlockDAG, Ethereum, BSC, etc.)
    setNetwork(networkName) {
        switch (networkName.toLowerCase()) {
            case 'blockdag':
                this.network = blockchainConfig.BLOCKDAG.MAINNET;
                break;
            case 'blockdag-testnet':
                this.network = blockchainConfig.BLOCKDAG.TESTNET;
                break;
            case 'ethereum':
                this.network = blockchainConfig.ETHEREUM;
                break;
            case 'bsc':
                this.network = blockchainConfig.BSC;
                break;
            default:
                this.network = blockchainConfig.BLOCKDAG.MAINNET;
        }
        this.provider = new ethers.JsonRpcProvider(this.network.RPC_URL);
        logger.info(`Switched to ${this.network.NAME} network`);
    }

    async verifyContract(contractAddress, networkType = 'blockdag') {
        try {
            this.setNetwork(networkType);

            let verificationStatus = false;

            // Check BlockDAG Explorer if BlockDAG network
            if (networkType.includes('blockdag')) {
                verificationStatus = await this.checkBlockDAGExplorer(contractAddress);
            } else {
                // Check Etherscan for Ethereum/BSC
                verificationStatus = await this.checkEtherscanVerification(contractAddress);
            }

            const contractCode = await this.provider.getCode(contractAddress);
            const hasSourceCode = contractCode !== '0x';

            return {
                isVerified: verificationStatus,
                hasSourceCode,
                contractAddress,
                network: this.network.NAME,
                verifiedOn: verificationStatus ? this.network.EXPLORER : null
            };
        } catch (error) {
            logger.error('Error verifying contract:', error);
            throw error;
        }
    }

    async checkBlockDAGExplorer(address) {
        try {
            if (!this.blockdagExplorerApiKey) {
                logger.warn('BlockDAG Explorer API key not configured');
                return false;
            }

            // BlockDAG Explorer API endpoint (adjust based on actual API)
            const response = await axios.get(
                `${this.network.EXPLORER}/api/contract/${address}`,
                {
                    headers: { 'X-API-Key': this.blockdagExplorerApiKey }
                }
            );

            // Check if contract has verified source code
            return response.data && response.data.sourceCode ? true : false;
        } catch (error) {
            logger.error('Error checking BlockDAG Explorer:', error);
            return false;
        }
    }

    async checkEtherscanVerification(address) {
        try {
            if (!this.etherscanApiKey) {
                logger.warn('Etherscan API key not configured');
                return false;
            }

            const response = await axios.get(
                `https://api.etherscan.io/api?module=contract&action=getsourcecode&address=${address}&apikey=${this.etherscanApiKey}`
            );

            if (response.data.status === '1' && response.data.result[0].SourceCode) {
                return true;
            }
            return false;
        } catch (error) {
            logger.error('Error checking Etherscan verification:', error);
            return false;
        }
    }

    async getTokenMetrics(contractAddress) {
        try {
            // Basic ERC20 ABI for standard functions
            const erc20Abi = [
                'function totalSupply() view returns (uint256)',
                'function decimals() view returns (uint8)',
                'function symbol() view returns (string)',
                'function name() view returns (string)',
                'function balanceOf(address) view returns (uint256)'
            ];

            const contract = new ethers.Contract(contractAddress, erc20Abi, this.provider);

            const [totalSupply, decimals, symbol, name] = await Promise.all([
                contract.totalSupply(),
                contract.decimals(),
                contract.symbol(),
                contract.name()
            ]);

            return {
                totalSupply: ethers.formatUnits(totalSupply, decimals),
                decimals: Number(decimals),
                symbol,
                name,
                network: this.network.NAME
            };
        } catch (error) {
            logger.error('Error getting token metrics:', error);
            throw error;
        }
    }

    async verifyLiquidityLock(contractAddress, lockProvider = 'uniswap') {
        try {
            // This is a simplified version - in production, you'd need to check
            // actual liquidity lock contracts on different platforms

            // For now, we'll simulate checking a liquidity lock
            const isLocked = await this.checkLiquidityLockStatus(contractAddress);

            if (isLocked) {
                return {
                    isLocked: true,
                    lockProvider,
                    lockDuration: 12, // months - would be fetched from actual contract
                    expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(),
                    network: this.network.NAME
                };
            }

            return {
                isLocked: false,
                lockProvider: null,
                lockDuration: 0,
                expiryDate: null,
                network: this.network.NAME
            };
        } catch (error) {
            logger.error('Error verifying liquidity lock:', error);
            throw error;
        }
    }

    async checkLiquidityLockStatus(contractAddress) {
        // Placeholder for actual liquidity lock checking logic
        // This would need to interact with actual lock contracts
        // like Unicrypt, Team Finance, etc.
        return false;
    }

    async getContractInfo(address) {
        try {
            const code = await this.provider.getCode(address);
            const balance = await this.provider.getBalance(address);

            return {
                address,
                hasCode: code !== '0x',
                balance: ethers.formatEther(balance),
                isContract: code !== '0x',
                network: this.network.NAME
            };
        } catch (error) {
            logger.error('Error getting contract info:', error);
            throw error;
        }
    }

    // BlockDAG-specific methods
    async getBlockDAGBlockInfo(blockNumber) {
        try {
            const block = await this.provider.getBlock(blockNumber);
            return {
                number: block.number,
                hash: block.hash,
                timestamp: block.timestamp,
                transactions: block.transactions.length,
                network: this.network.NAME
            };
        } catch (error) {
            logger.error('Error getting BlockDAG block info:', error);
            throw error;
        }
    }

    async getBlockDAGTransactionInfo(txHash) {
        try {
            const tx = await this.provider.getTransaction(txHash);
            return {
                hash: tx.hash,
                from: tx.from,
                to: tx.to,
                value: ethers.formatEther(tx.value),
                confirmations: await tx.wait().then(() => true),
                network: this.network.NAME
            };
        } catch (error) {
            logger.error('Error getting BlockDAG transaction info:', error);
            throw error;
        }
    }
}

module.exports = new BlockchainService();
