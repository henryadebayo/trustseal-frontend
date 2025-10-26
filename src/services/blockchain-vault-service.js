const { ethers } = require('ethers');
const logger = require('../config/logger');

class BlockchainVaultService {
    constructor() {
        try {
            // Initialize provider
            this.provider = new ethers.JsonRpcProvider(
                process.env.BLOCKDAG_RPC_URL || 'https://rpc.blockdag.network'
            );

            // Contract address and ABI
            this.contractAddress = process.env.VAULT_CONTRACT_ADDRESS || '0xd54d40692605feebbe296e1cd0b5cf910602ad90';
            this.contractABI = [
                {
                    "inputs": [
                        { "name": "receiverAddress", "type": "address" },
                        { "name": "ipfsHash", "type": "string" },
                        { "name": "encryptedFileKey", "type": "string" },
                        { "name": "encryptionMetadata", "type": "bytes" }
                    ],
                    "name": "createKeyHandshakeTransaction",
                    "outputs": [{ "name": "", "type": "uint256" }],
                    "stateMutability": "nonpayable",
                    "type": "function"
                },
                {
                    "inputs": [{ "name": "receiver", "type": "address" }],
                    "name": "getReceiverPublicKey",
                    "outputs": [{ "name": "", "type": "string" }],
                    "stateMutability": "view",
                    "type": "function"
                },
                {
                    "inputs": [{ "name": "newPublicKey", "type": "string" }],
                    "name": "setReceiverPublicKey",
                    "outputs": [],
                    "stateMutability": "nonpayable",
                    "type": "function"
                },
                {
                    "inputs": [],
                    "name": "transactionCounter",
                    "outputs": [{ "name": "", "type": "uint256" }],
                    "stateMutability": "view",
                    "type": "function"
                },
                {
                    "anonymous": false,
                    "inputs": [
                        { "indexed": true, "name": "sender", "type": "address" },
                        { "indexed": true, "name": "receiver", "type": "address" },
                        { "indexed": true, "name": "transactionId", "type": "uint256" },
                        { "indexed": false, "name": "ipfsHash", "type": "string" },
                        { "indexed": false, "name": "encryptedFileKey", "type": "string" }
                    ],
                    "name": "KeyHandshakeTransaction",
                    "type": "event"
                }
            ];

            // Get signer from environment (for admin operations)
            this.signer = null;
            if (process.env.VAULT_PRIVATE_KEY) {
                this.signer = new ethers.Wallet(process.env.VAULT_PRIVATE_KEY, this.provider);
                logger.info('BlockDAG signer configured for contract interactions');
            }

            // Initialize contract instance
            this.contract = new ethers.Contract(
                this.contractAddress,
                this.contractABI,
                this.provider
            );

            this.isAvailable = true;
            logger.info(`Blockchain Vault Service initialized with contract: ${this.contractAddress}`);
        } catch (error) {
            logger.warn('Blockchain Vault Service initialization failed:', error.message);
            this.isAvailable = false;
        }
    }

    /**
     * Create a key handshake transaction on BlockDAG
     * @param {string} receiverAddress - Receiver's BlockDAG address
     * @param {string} ipfsHash - IPFS hash of encrypted file
     * @param {string} encryptedFileKey - Base64 encoded encrypted AES key
     * @param {Object} metadata - Encryption metadata
     * @returns {Promise<Object>} Transaction ID, hash, and block number
     */
    async createKeyHandshakeTransaction(receiverAddress, ipfsHash, encryptedFileKey, metadata) {
        try {
            if (!this.isAvailable) {
                throw new Error('Blockchain service not available');
            }

            if (!this.signer) {
                logger.warn('No signer configured. Skipping blockchain transaction.');
                return null;
            }

            // Convert metadata to bytes
            const metadataJson = JSON.stringify(metadata);
            const metadataBytes = ethers.toUtf8Bytes(metadataJson);

            // Estimate gas
            const gasEstimate = await this.contract
                .connect(this.signer)
                .createKeyHandshakeTransaction.estimateGas(
                    receiverAddress,
                    ipfsHash,
                    encryptedFileKey,
                    metadataBytes
                );

            logger.info(`Gas estimate: ${gasEstimate.toString()}`);

            // Send transaction
            const tx = await this.contract
                .connect(this.signer)
                .createKeyHandshakeTransaction(
                    receiverAddress,
                    ipfsHash,
                    encryptedFileKey,
                    metadataBytes,
                    { gasLimit: gasEstimate + 50000n } // Add buffer
                );

            logger.info(`Transaction sent: ${tx.hash}`);

            // Wait for confirmation
            const receipt = await tx.wait();

            // Extract transaction ID from event
            let transactionId = null;
            if (receipt.logs) {
                const event = receipt.logs.find(log => {
                    try {
                        return this.contract.interface.parseLog(log)?.name === 'KeyHandshakeTransaction';
                    } catch (e) {
                        return false;
                    }
                });

                if (event) {
                    const parsedEvent = this.contract.interface.parseLog(event);
                    transactionId = parsedEvent.args.transactionId.toString();
                }
            }

            if (!transactionId) {
                // Fallback: get from transaction counter
                transactionId = (await this.contract.transactionCounter()).toString();
            }

            logger.info(`Key handshake transaction created on BlockDAG: ${transactionId} (TX: ${receipt.hash})`);

            return {
                transactionId: parseInt(transactionId),
                txHash: receipt.hash,
                blockNumber: receipt.blockNumber
            };
        } catch (error) {
            logger.error('Error creating key handshake transaction:', error);
            throw new Error('Failed to create blockchain transaction');
        }
    }

    /**
     * Get receiver's public key from BlockDAG
     * @param {string} receiverAddress - Receiver's BlockDAG address
     * @returns {Promise<string|null>} RSA public key in PEM format
     */
    async getReceiverPublicKey(receiverAddress) {
        try {
            if (!this.isAvailable) {
                return null;
            }

            const publicKey = await this.contract.getReceiverPublicKey(receiverAddress);

            if (!publicKey || publicKey === '') {
                return null;
            }

            return publicKey;
        } catch (error) {
            logger.error('Error getting receiver public key from blockchain:', error.message);
            return null; // Return null if not found (fallback to database)
        }
    }

    /**
     * Set receiver's public key on BlockDAG
     * @param {string} publicKey - RSA public key in PEM format
     * @returns {Promise<string>} Transaction hash
     */
    async setReceiverPublicKey(publicKey) {
        try {
            if (!this.isAvailable) {
                throw new Error('Blockchain service not available');
            }

            if (!this.signer) {
                throw new Error('No signer configured. Set VAULT_PRIVATE_KEY in environment.');
            }

            const tx = await this.contract
                .connect(this.signer)
                .setReceiverPublicKey(publicKey);

            const receipt = await tx.wait();

            logger.info(`Receiver public key set on BlockDAG: ${receipt.hash}`);

            return receipt.hash;
        } catch (error) {
            logger.error('Error setting receiver public key:', error);
            throw new Error('Failed to set public key on blockchain');
        }
    }

    /**
     * Get total number of vault transactions
     * @returns {Promise<number>} Transaction count
     */
    async getTransactionCount() {
        try {
            if (!this.isAvailable) {
                return 0;
            }

            const count = await this.contract.transactionCounter();
            return parseInt(count.toString());
        } catch (error) {
            logger.error('Error getting transaction count:', error.message);
            return 0;
        }
    }

    /**
     * Check if blockchain service is available
     * @returns {boolean}
     */
    isServiceAvailable() {
        return this.isAvailable && this.signer !== null;
    }
}

module.exports = new BlockchainVaultService();

