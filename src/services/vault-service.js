const crypto = require('crypto');
const forge = require('node-forge');
const axios = require('axios');
const fs = require('fs').promises;
const path = require('path');
const logger = require('../config/logger');
const pool = require('../config/database');

// Import blockchain service (with graceful fallback if not available)
let blockchainVaultService;
try {
    blockchainVaultService = require('./blockchain-vault-service');
} catch (error) {
    logger.warn('Blockchain vault service not available:', error.message);
    blockchainVaultService = null;
}

class VaultService {
    constructor() {
        // Initialize IPFS client using direct HTTP API calls
        this.ipfsAvailable = false;
        this.ipfsHost = process.env.IPFS_HOST || 'localhost';
        this.ipfsPort = parseInt(process.env.IPFS_PORT) || 5001;
        this.ipfsProtocol = process.env.IPFS_PROTOCOL || 'http';
        this.ipfsApiUrl = `${this.ipfsProtocol}://${this.ipfsHost}:${this.ipfsPort}/api/v0`;

        // Local storage directory for fallback
        this.localStorageDir = path.join(__dirname, '../../vault-storage');

        // Encryption constants
        this.algorithm = 'aes-256-cbc';
        this.keyLength = 32; // 256 bits
        this.ivLength = 16;  // 128 bits
        this.tagLength = 16; // 128 bits

        // Initialize connection status (will be checked on first use)
        this.checkIpfsConnection();
    }

    async checkIpfsConnection() {
        try {
            // Test IPFS connection
            const response = await axios.post(`${this.ipfsApiUrl}/version`);
            if (response.data && response.data.Version) {
                this.ipfsAvailable = true;
                logger.info(`IPFS client initialized successfully: ${this.ipfsProtocol}://${this.ipfsHost}:${this.ipfsPort} (Version: ${response.data.Version})`);
            }
        } catch (error) {
            logger.warn('IPFS connection failed, using local storage fallback:', error.message);
            this.ipfsAvailable = false;
        }
    }

    // Step 1: Receiver (Auditor) Setup - Generate permanent key pair
    async generateReceiverKeyPair(receiverId) {
        try {
            // Generate RSA key pair (2048 bits for security)
            const keyPair = forge.pki.rsa.generateKeyPair(2048);

            const publicKeyPem = forge.pki.publicKeyToPem(keyPair.publicKey);
            const privateKeyPem = forge.pki.privateKeyToPem(keyPair.privateKey);

            // Store in database
            await pool.query(
                `INSERT INTO receiver_keys (receiver_id, public_key, private_key, created_at) 
                 VALUES ($1, $2, $3, NOW()) 
                 ON CONFLICT (receiver_id) 
                 DO UPDATE SET public_key = $2, private_key = $3, updated_at = NOW()`,
                [receiverId, publicKeyPem, privateKeyPem]
            );

            logger.info(`Generated key pair for receiver: ${receiverId}`);

            return {
                receiverId,
                publicKey: publicKeyPem,
                privateKey: privateKeyPem
            };
        } catch (error) {
            logger.error('Error generating receiver key pair:', error);
            throw new Error('Failed to generate receiver key pair');
        }
    }

    // Get receiver's public key from database
    async getReceiverPublicKey(receiverId) {
        try {
            const result = await pool.query(
                'SELECT public_key FROM receiver_keys WHERE receiver_id = $1',
                [receiverId]
            );

            if (result.rows.length === 0) {
                throw new Error(`Receiver key pair not found for receiver ID: ${receiverId}`);
            }

            return result.rows[0].public_key;
        } catch (error) {
            logger.error('Error getting receiver public key:', error);
            throw new Error('Failed to get receiver public key');
        }
    }

    // Step 2: File Encryption with One-Time Symmetric Key
    async encryptFile(fileBuffer, fileName) {
        try {
            // Generate one-time symmetric key (FileKey)
            const fileKey = crypto.randomBytes(this.keyLength);

            // Generate random IV
            const iv = crypto.randomBytes(this.ivLength);

            // Create cipher using AES-256-CBC with IV
            const cipher = crypto.createCipheriv('aes-256-cbc', fileKey, iv);

            // Encrypt the file
            let encrypted = cipher.update(fileBuffer);
            encrypted = Buffer.concat([encrypted, cipher.final()]);

            // For CBC mode, we don't need a separate tag
            const tag = Buffer.alloc(this.tagLength); // Placeholder tag

            logger.info(`File encrypted: ${fileName}, Key length: ${fileKey.length} bytes`);

            return {
                encryptedData: encrypted,
                fileKey: fileKey,
                iv: iv,
                tag: tag,
                fileName: fileName
            };
        } catch (error) {
            logger.error('Error encrypting file:', error);
            throw new Error('Failed to encrypt file');
        }
    }

    // Step 3: Upload Encrypted File to IPFS Vault (with local fallback)
    async uploadToVault(encryptedData, fileName) {
        try {
            if (this.ipfsAvailable) {
                // Upload to IPFS using direct HTTP API (IPFS HTTP API expects multipart/form-data)
                const FormData = require('form-data');
                const formData = new FormData();
                formData.append('file', encryptedData, {
                    filename: fileName + '.encrypted',
                    contentType: 'application/octet-stream'
                });

                const response = await axios.post(`${this.ipfsApiUrl}/add`, formData, {
                    headers: formData.getHeaders(),
                    maxContentLength: Infinity,
                    maxBodyLength: Infinity
                });

                const ipfsHash = response.data.Hash || response.data.hash;
                logger.info(`File uploaded to IPFS vault: ${ipfsHash}`);

                return {
                    ipfsHash: ipfsHash,
                    ipfsUrl: `ipfs://${ipfsHash}`,
                    fileName: fileName
                };
            } else {
                // Local fallback
                await fs.mkdir(this.localStorageDir, { recursive: true });
                const filePath = path.join(this.localStorageDir, `${Date.now()}-${fileName}.encrypted`);
                await fs.writeFile(filePath, encryptedData);

                const localHash = `local-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
                logger.info(`File stored locally (fallback): ${localHash}`);

                return {
                    ipfsHash: localHash,
                    ipfsUrl: `local://${localHash}`,
                    fileName: fileName,
                    localPath: filePath
                };
            }
        } catch (error) {
            logger.error('Error uploading to vault:', error);
            throw new Error('Failed to upload to vault');
        }
    }

    // Step 4: Encrypt FileKey with Receiver's Public Key
    async encryptFileKey(fileKey, receiverPublicKey) {
        try {
            // Convert PEM to forge public key
            const publicKey = forge.pki.publicKeyFromPem(receiverPublicKey);

            // Encrypt the file key
            const encryptedKey = publicKey.encrypt(fileKey.toString('base64'));

            logger.info('FileKey encrypted with receiver public key');

            return encryptedKey;
        } catch (error) {
            logger.error('Error encrypting file key:', error);
            throw new Error('Failed to encrypt file key');
        }
    }

    // Step 5: Create BlockDAG Transaction for Key Handshake
    async createKeyHandshakeTransaction(senderId, receiverId, ipfsHash, encryptedFileKey, encryptionMetadata = {}) {
        try {
            // Base64 encode the encrypted file key to avoid UTF8 issues
            const encodedFileKey = Buffer.from(encryptedFileKey, 'binary').toString('base64');

            const transactionData = {
                type: 'VAULT_HANDSHAKE',
                senderId: senderId,
                receiverId: receiverId,
                ipfsHash: ipfsHash,
                encryptedFileKey: encodedFileKey, // Use base64 encoded version
                encryptionMetadata: encryptionMetadata,
                timestamp: new Date().toISOString()
            };

            // Store transaction in database (in real implementation, this would be signed and sent to BlockDAG)

            const result = await pool.query(
                `INSERT INTO vault_transactions (sender_id, receiver_id, ipfs_hash, encrypted_file_key, transaction_data, created_at) 
                 VALUES ($1, $2, $3, $4, $5, NOW()) 
                 RETURNING id`,
                [senderId, receiverId, ipfsHash, encodedFileKey, JSON.stringify(transactionData)]
            );

            const transactionId = result.rows[0].id;

            logger.info(`Key handshake transaction created: ${transactionId}`);

            return {
                transactionId: transactionId,
                transactionData: transactionData
            };
        } catch (error) {
            logger.error('Error creating key handshake transaction:', error);
            throw new Error('Failed to create key handshake transaction');
        }
    }

    // Step 6: Receiver Decryption Workflow
    async decryptFileKey(encryptedFileKeyBase64, receiverPrivateKey) {
        try {
            // Convert base64 back to binary
            const encryptedFileKey = Buffer.from(encryptedFileKeyBase64, 'base64').toString('binary');

            // Convert PEM to forge private key
            const privateKey = forge.pki.privateKeyFromPem(receiverPrivateKey);

            // Decrypt the file key
            const decryptedKeyBase64 = privateKey.decrypt(encryptedFileKey);
            const fileKey = Buffer.from(decryptedKeyBase64, 'base64');

            logger.info('FileKey decrypted successfully');

            return fileKey;
        } catch (error) {
            logger.error('Error decrypting file key:', error);
            throw new Error('Failed to decrypt file key');
        }
    }

    // Step 7: Download and Decrypt File from Vault (with local fallback)
    async downloadAndDecryptFile(ipfsHash, fileKey, fileName, iv, tag) {
        try {
            let encryptedData;

            if (this.ipfsAvailable && !ipfsHash.startsWith('local-')) {
                // Download file from IPFS using HTTP API
                const response = await axios.get(`${this.ipfsApiUrl}/cat`, {
                    params: { arg: ipfsHash },
                    responseType: 'arraybuffer'
                });
                encryptedData = Buffer.from(response.data);
            } else {
                // Local fallback - read from local storage
                const hashPart = ipfsHash.split('-')[1];
                const files = await fs.readdir(this.localStorageDir);
                // Find file that starts with the timestamp part
                const targetFile = files.find(file => file.startsWith(hashPart.substring(0, 10)));

                if (!targetFile) {
                    throw new Error('File not found in local storage');
                }

                const filePath = path.join(this.localStorageDir, targetFile);
                encryptedData = await fs.readFile(filePath);
            }

            // Decrypt the file using AES-256-CBC with IV
            const decipher = crypto.createDecipheriv('aes-256-cbc', fileKey, iv);

            let decrypted = decipher.update(encryptedData);
            decrypted = Buffer.concat([decrypted, decipher.final()]);

            logger.info(`File decrypted successfully: ${fileName}`);

            return {
                decryptedData: decrypted,
                fileName: fileName
            };
        } catch (error) {
            logger.error('Error downloading and decrypting file:', error);
            throw new Error('Failed to download and decrypt file');
        }
    }

    // Get vault transactions for a receiver
    async getReceiverTransactions(receiverId) {
        try {
            const result = await pool.query(
                `SELECT id, sender_id, ipfs_hash, encrypted_file_key, transaction_data, created_at 
                 FROM vault_transactions 
                 WHERE receiver_id = $1 
                 ORDER BY created_at DESC`,
                [receiverId]
            );

            return result.rows.map(row => ({
                id: row.id,
                senderId: row.sender_id,
                ipfsHash: row.ipfs_hash,
                encryptedFileKey: row.encrypted_file_key,
                transactionData: typeof row.transaction_data === 'string'
                    ? JSON.parse(row.transaction_data)
                    : row.transaction_data,
                createdAt: row.created_at
            }));
        } catch (error) {
            logger.error('Error getting receiver transactions:', error);
            throw new Error('Failed to get receiver transactions');
        }
    }

    // Complete vault workflow for sender
    async uploadToVaultComplete(fileBuffer, fileName, senderId, receiverId) {
        try {
            // Resolve receiver ID (in case it's a special identifier like "admin-uuid")
            let actualReceiverId = receiverId;
            if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(receiverId)) {
                logger.info(`Resolving receiver ID "${receiverId}" to actual user UUID...`);

                if (receiverId.toLowerCase().includes('admin')) {
                    const userResult = await pool.query(
                        'SELECT id FROM users WHERE user_type = $1 ORDER BY created_at LIMIT 1',
                        ['admin']
                    );

                    if (userResult.rows.length > 0) {
                        actualReceiverId = userResult.rows[0].id;
                        logger.info(`Resolved "${receiverId}" to user ID: ${actualReceiverId}`);
                    } else {
                        throw new Error(`No admin users found to resolve "${receiverId}"`);
                    }
                } else {
                    throw new Error(`Invalid receiver ID format: "${receiverId}"`);
                }
            }

            // Step 1: Encrypt file with one-time key
            const encryptionResult = await this.encryptFile(fileBuffer, fileName);

            // Step 2: Upload encrypted file to IPFS
            const vaultResult = await this.uploadToVault(encryptionResult.encryptedData, fileName);

            // Step 3: Get receiver's public key
            const receiverPublicKey = await this.getReceiverPublicKey(actualReceiverId);

            // Step 4: Encrypt file key with receiver's public key
            const encryptedFileKey = await this.encryptFileKey(encryptionResult.fileKey, receiverPublicKey);

            // Step 4b: Create on-chain transaction (NEW - BlockDAG Integration)
            let blockchainTx = null;
            if (blockchainVaultService && blockchainVaultService.isServiceAvailable()) {
                try {
                    // Get receiver's wallet address from database
                    const userResult = await pool.query(
                        'SELECT wallet_address FROM users WHERE id = $1',
                        [actualReceiverId]
                    );

                    if (userResult.rows.length > 0 && userResult.rows[0].wallet_address) {
                        const receiverAddress = userResult.rows[0].wallet_address;

                        // Create blockchain transaction
                        blockchainTx = await blockchainVaultService.createKeyHandshakeTransaction(
                            receiverAddress,
                            vaultResult.ipfsHash,
                            encryptedFileKey.toString('base64'),
                            {
                                iv: encryptionResult.iv.toString('base64'),
                                tag: encryptionResult.tag.toString('base64'),
                                fileName: fileName,
                                sender: senderId,
                                algorithm: this.algorithm
                            }
                        );

                        logger.info(`Blockchain transaction created: ${blockchainTx.txHash}`);
                    } else {
                        logger.warn(`Receiver ${actualReceiverId} has no wallet_address set. Skipping blockchain transaction.`);
                    }
                } catch (blockchainError) {
                    logger.warn('Blockchain transaction failed, continuing with database only:', blockchainError.message);
                    // Continue without blockchain (fallback mode)
                }
            } else {
                logger.info('Blockchain service not available or not configured. Using database-only mode.');
            }

            // Step 5: Create key handshake transaction in database
            const transactionResult = await this.createKeyHandshakeTransaction(
                senderId,
                actualReceiverId,  // Use resolved receiver ID
                vaultResult.ipfsHash,
                encryptedFileKey,
                {
                    iv: encryptionResult.iv.toString('base64'),
                    tag: encryptionResult.tag.toString('base64'),
                    fileName: fileName
                }
            );

            logger.info(`Vault upload complete for ${fileName} to receiver ${receiverId}`);

            return {
                vaultHash: vaultResult.ipfsHash,
                vaultUrl: vaultResult.ipfsUrl,
                transactionId: transactionResult.transactionId,
                fileName: fileName,
                senderId: senderId,
                receiverId: receiverId,
                blockchainTx: blockchainTx // Include blockchain transaction info if available
            };
        } catch (error) {
            logger.error('Error in complete vault upload:', error);
            throw new Error('Failed to complete vault upload');
        }
    }

    // Complete vault workflow for receiver
    async downloadFromVaultComplete(transactionId, receiverId) {
        try {
            // Get transaction details
            const result = await pool.query(
                'SELECT * FROM vault_transactions WHERE id = $1 AND receiver_id = $2',
                [transactionId, receiverId]
            );

            if (result.rows.length === 0) {
                throw new Error('Transaction not found or access denied');
            }

            const transaction = result.rows[0];

            // Get receiver's private key
            const keyResult = await pool.query(
                'SELECT private_key FROM receiver_keys WHERE receiver_id = $1',
                [receiverId]
            );

            if (keyResult.rows.length === 0) {
                throw new Error('Receiver private key not found');
            }

            const receiverPrivateKey = keyResult.rows[0].private_key;

            // Step 1: Decrypt file key
            const fileKey = await this.decryptFileKey(transaction.encrypted_file_key, receiverPrivateKey);

            // Step 2: Download and decrypt file
            const transactionData = typeof transaction.transaction_data === 'string'
                ? JSON.parse(transaction.transaction_data)
                : transaction.transaction_data;
            const encryptionMetadata = transactionData.encryptionMetadata || {};

            const decryptionResult = await this.downloadAndDecryptFile(
                transaction.ipfs_hash,
                fileKey,
                encryptionMetadata.fileName || 'unknown',
                Buffer.from(encryptionMetadata.iv || '', 'base64'),
                Buffer.from(encryptionMetadata.tag || '', 'base64')
            );

            logger.info(`Vault download complete for transaction ${transactionId}`);

            return {
                decryptedData: decryptionResult.decryptedData,
                fileName: decryptionResult.fileName,
                transactionId: transactionId,
                senderId: transaction.sender_id
            };
        } catch (error) {
            logger.error('Error in complete vault download:', error);
            throw new Error('Failed to complete vault download');
        }
    }
}

module.exports = new VaultService();
