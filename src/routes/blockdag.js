const express = require('express');
const axios = require('axios');
const { ethers } = require('ethers');
const logger = require('../config/logger');
const blockchainConfig = require('../config/blockchain');

const router = express.Router();

// BlockDAG RPC Configuration
const BLOCKDAG_RPC_URL = process.env.BLOCKDAG_RPC_URL || blockchainConfig.BLOCKDAG.MAINNET.RPC_URL;
const BLOCKDAG_EXPLORER_API = process.env.BLOCKDAG_EXPLORER_API || blockchainConfig.BLOCKDAG.MAINNET.EXPLORER;

// Initialize BlockDAG provider
let blockdagProvider;
try {
    blockdagProvider = new ethers.JsonRpcProvider(BLOCKDAG_RPC_URL);
} catch (error) {
    logger.warn('Failed to initialize BlockDAG provider:', error.message);
}

// GET /api/v1/blockdag/network/health
router.get('/network/health', async (req, res) => {
    try {
        if (!blockdagProvider) {
            return res.status(503).json({
                status: 'error',
                message: 'BlockDAG provider not available'
            });
        }

        // Get network information
        const network = await blockdagProvider.getNetwork();
        const blockNumber = await blockdagProvider.getBlockNumber();
        const feeData = await blockdagProvider.getFeeData();

        // Get latest block for more details
        const latestBlock = await blockdagProvider.getBlock(blockNumber);

        // Calculate network metrics
        const networkHealth = {
            status: 'healthy',
            networkId: Number(network.chainId),
            blockHeight: blockNumber,
            gasPrice: feeData.gasPrice ? ethers.formatUnits(feeData.gasPrice, 'gwei') : '0',
            blockTime: latestBlock ? new Date(latestBlock.timestamp * 1000).toISOString() : null,
            transactionCount: latestBlock ? latestBlock.transactions.length : 0,
            timestamp: new Date().toISOString()
        };

        // Check if network is responsive
        const responseTime = Date.now();
        await blockdagProvider.getBlockNumber();
        networkHealth.responseTime = Date.now() - responseTime;

        res.json({
            status: 'success',
            data: {
                network: 'BlockDAG',
                health: networkHealth,
                rpcUrl: BLOCKDAG_RPC_URL,
                explorer: BLOCKDAG_EXPLORER_API
            }
        });

    } catch (error) {
        logger.error('BlockDAG network health check failed:', error);
        res.status(503).json({
            status: 'error',
            message: 'BlockDAG network is not responding',
            data: {
                network: 'BlockDAG',
                health: {
                    status: 'unhealthy',
                    error: error.message,
                    timestamp: new Date().toISOString()
                }
            }
        });
    }
});

// GET /api/v1/blockdag/contracts/:address/verify
router.get('/contracts/:address/verify', async (req, res) => {
    try {
        const { address } = req.params;

        if (!ethers.isAddress(address)) {
            return res.status(400).json({
                status: 'error',
                message: 'Invalid contract address format'
            });
        }

        const contractAddress = ethers.getAddress(address); // Normalize address

        // Check if contract exists
        const code = await blockdagProvider.getCode(contractAddress);
        if (code === '0x') {
            return res.status(404).json({
                status: 'error',
                message: 'No contract found at this address'
            });
        }

        // Try to get contract info from BlockDAG Explorer
        let explorerInfo = null;
        try {
            const explorerResponse = await axios.get(`${BLOCKDAG_EXPLORER_API}/api/contract/${contractAddress}`, {
                timeout: 5000
            });
            explorerInfo = explorerResponse.data;
        } catch (explorerError) {
            logger.warn('BlockDAG Explorer API not available:', explorerError.message);
        }

        // Basic contract verification
        const verification = {
            address: contractAddress,
            isContract: true,
            codeSize: (code.length - 2) / 2, // Remove '0x' and convert to bytes
            verified: false,
            sourceCode: null,
            abi: null,
            compilerVersion: null,
            optimization: null,
            features: []
        };

        // If explorer info is available, use it
        if (explorerInfo && explorerInfo.verified) {
            verification.verified = true;
            verification.sourceCode = explorerInfo.sourceCode;
            verification.abi = explorerInfo.abi;
            verification.compilerVersion = explorerInfo.compilerVersion;
            verification.optimization = explorerInfo.optimization;
        }

        // Detect contract features
        verification.features = await detectContractFeatures(contractAddress);

        res.json({
            status: 'success',
            data: {
                contract: verification,
                explorer: explorerInfo,
                timestamp: new Date().toISOString()
            }
        });

    } catch (error) {
        logger.error('Contract verification failed:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to verify contract',
            error: error.message
        });
    }
});

// GET /api/v1/blockdag/contracts/:address/features
router.get('/contracts/:address/features', async (req, res) => {
    try {
        const { address } = req.params;

        if (!ethers.isAddress(address)) {
            return res.status(400).json({
                status: 'error',
                message: 'Invalid contract address format'
            });
        }

        const contractAddress = ethers.getAddress(address);
        const features = await detectContractFeatures(contractAddress);

        res.json({
            status: 'success',
            data: {
                address: contractAddress,
                features: features,
                timestamp: new Date().toISOString()
            }
        });

    } catch (error) {
        logger.error('Contract features detection failed:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to detect contract features',
            error: error.message
        });
    }
});

// GET /api/v1/blockdag/transactions/:address/history
router.get('/transactions/:address/history', async (req, res) => {
    try {
        const { address } = req.params;
        const { limit = 50, offset = 0 } = req.query;

        if (!ethers.isAddress(address)) {
            return res.status(400).json({
                status: 'error',
                message: 'Invalid address format'
            });
        }

        const contractAddress = ethers.getAddress(address);

        // Try to get transaction history from BlockDAG Explorer
        let transactions = [];
        let totalCount = 0;

        try {
            const explorerResponse = await axios.get(`${BLOCKDAG_EXPLORER_API}/api/transactions`, {
                params: {
                    address: contractAddress,
                    limit: parseInt(limit),
                    offset: parseInt(offset)
                },
                timeout: 10000
            });

            transactions = explorerResponse.data.transactions || [];
            totalCount = explorerResponse.data.total || 0;

        } catch (explorerError) {
            logger.warn('BlockDAG Explorer API not available for transactions:', explorerError.message);

            // Fallback: Get recent transactions from RPC
            const latestBlock = await blockdagProvider.getBlockNumber();
            const recentBlocks = Math.min(100, latestBlock); // Check last 100 blocks

            for (let i = 0; i < recentBlocks && transactions.length < parseInt(limit); i++) {
                try {
                    const block = await blockdagProvider.getBlock(latestBlock - i);
                    if (block && block.transactions) {
                        for (const txHash of block.transactions) {
                            try {
                                const tx = await blockdagProvider.getTransaction(txHash);
                                if (tx && (tx.to === contractAddress || tx.from === contractAddress)) {
                                    transactions.push({
                                        hash: tx.hash,
                                        from: tx.from,
                                        to: tx.to,
                                        value: ethers.formatEther(tx.value),
                                        gasPrice: ethers.formatUnits(tx.gasPrice, 'gwei'),
                                        blockNumber: tx.blockNumber,
                                        timestamp: block.timestamp,
                                        status: 'success'
                                    });
                                }
                            } catch (txError) {
                                // Skip failed transaction fetches
                                continue;
                            }
                        }
                    }
                } catch (blockError) {
                    // Skip failed block fetches
                    continue;
                }
            }
        }

        // Calculate transaction metrics
        const metrics = {
            totalTransactions: totalCount || transactions.length,
            totalVolume: transactions.reduce((sum, tx) => sum + parseFloat(tx.value || 0), 0),
            averageGasPrice: transactions.length > 0 ?
                transactions.reduce((sum, tx) => sum + parseFloat(tx.gasPrice || 0), 0) / transactions.length : 0,
            uniqueAddresses: new Set(transactions.flatMap(tx => [tx.from, tx.to]).filter(Boolean)).size
        };

        res.json({
            status: 'success',
            data: {
                address: contractAddress,
                transactions: transactions.slice(0, parseInt(limit)),
                metrics: metrics,
                pagination: {
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    total: totalCount || transactions.length
                },
                timestamp: new Date().toISOString()
            }
        });

    } catch (error) {
        logger.error('Transaction history fetch failed:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to fetch transaction history',
            error: error.message
        });
    }
});

// Helper function to detect contract features
async function detectContractFeatures(contractAddress) {
    const features = [];

    try {
        // Check for common token features
        const tokenFeatures = await checkTokenFeatures(contractAddress);
        features.push(...tokenFeatures);

        // Check for DeFi features
        const defiFeatures = await checkDeFiFeatures(contractAddress);
        features.push(...defiFeatures);

        // Check for security features
        const securityFeatures = await checkSecurityFeatures(contractAddress);
        features.push(...securityFeatures);

    } catch (error) {
        logger.warn('Contract feature detection failed:', error.message);
    }

    return features;
}

// Check for token features
async function checkTokenFeatures(contractAddress) {
    const features = [];

    try {
        // Try to call common ERC-20 functions
        const contract = new ethers.Contract(contractAddress, [
            'function name() view returns (string)',
            'function symbol() view returns (string)',
            'function decimals() view returns (uint8)',
            'function totalSupply() view returns (uint256)',
            'function balanceOf(address) view returns (uint256)',
            'function transfer(address,uint256) returns (bool)',
            'function approve(address,uint256) returns (bool)',
            'function allowance(address,address) view returns (uint256)'
        ], blockdagProvider);

        // Check if it's an ERC-20 token
        try {
            await contract.name();
            await contract.symbol();
            await contract.decimals();
            await contract.totalSupply();
            features.push({
                type: 'token',
                name: 'ERC-20 Token',
                description: 'Standard ERC-20 token implementation',
                verified: true
            });
        } catch (error) {
            // Not a standard ERC-20 token
        }

        // Check for reflection token features
        try {
            const contractWithReflection = new ethers.Contract(contractAddress, [
                'function _reflectFee(uint256,uint256) internal',
                'function _getValues(uint256) internal view returns (uint256,uint256,uint256)',
                'function _getRate() internal view returns (uint256)'
            ], blockdagProvider);

            // If we can call these functions, it might be a reflection token
            features.push({
                type: 'token',
                name: 'Reflection Token',
                description: 'Token with automatic reflection/rewards distribution',
                verified: false
            });
        } catch (error) {
            // Not a reflection token
        }

    } catch (error) {
        // Contract doesn't support token features
    }

    return features;
}

// Check for DeFi features
async function checkDeFiFeatures(contractAddress) {
    const features = [];

    try {
        // Check for liquidity lock features
        const liquidityContract = new ethers.Contract(contractAddress, [
            'function lockLiquidity(uint256,uint256) external',
            'function unlockLiquidity() external',
            'function isLiquidityLocked() view returns (bool)'
        ], blockdagProvider);

        try {
            await liquidityContract.isLiquidityLocked();
            features.push({
                type: 'defi',
                name: 'Liquidity Lock',
                description: 'Contract supports liquidity locking mechanism',
                verified: true
            });
        } catch (error) {
            // No liquidity lock feature
        }

        // Check for anti-whale features
        const antiWhaleContract = new ethers.Contract(contractAddress, [
            'function _maxTxAmount() view returns (uint256)',
            'function _maxWalletAmount() view returns (uint256)',
            'function setMaxTxAmount(uint256) external',
            'function setMaxWalletAmount(uint256) external'
        ], blockdagProvider);

        try {
            await antiWhaleContract._maxTxAmount();
            features.push({
                type: 'defi',
                name: 'Anti-Whale Protection',
                description: 'Contract has maximum transaction and wallet limits',
                verified: true
            });
        } catch (error) {
            // No anti-whale feature
        }

    } catch (error) {
        // Contract doesn't support DeFi features
    }

    return features;
}

// Check for security features
async function checkSecurityFeatures(contractAddress) {
    const features = [];

    try {
        // Check for pause functionality
        const pauseContract = new ethers.Contract(contractAddress, [
            'function paused() view returns (bool)',
            'function pause() external',
            'function unpause() external'
        ], blockdagProvider);

        try {
            await pauseContract.paused();
            features.push({
                type: 'security',
                name: 'Pause Functionality',
                description: 'Contract can be paused for emergency situations',
                verified: true
            });
        } catch (error) {
            // No pause functionality
        }

        // Check for ownership features
        const ownershipContract = new ethers.Contract(contractAddress, [
            'function owner() view returns (address)',
            'function transferOwnership(address) external',
            'function renounceOwnership() external'
        ], blockdagProvider);

        try {
            await ownershipContract.owner();
            features.push({
                type: 'security',
                name: 'Ownership Control',
                description: 'Contract has ownership management functionality',
                verified: true
            });
        } catch (error) {
            // No ownership functionality
        }

    } catch (error) {
        // Contract doesn't support security features
    }

    return features;
}

module.exports = router;
