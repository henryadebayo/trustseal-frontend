const express = require('express');
const multer = require('multer');
const pool = require('../config/database');
const logger = require('../config/logger');
const vaultService = require('../services/vault-service');
const { authenticateToken, requireRole } = require('../middleware/auth');

// Import blockchain service (with graceful fallback)
let blockchainVaultService = null;
try {
    blockchainVaultService = require('../services/blockchain-vault-service');
} catch (error) {
    logger.warn('Blockchain vault service not available');
}

const router = express.Router();

// Configure multer for file uploads
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 100 * 1024 * 1024 // 100MB limit
    },
    fileFilter: (req, file, cb) => {
        // Allow all file types for vault (encrypted anyway)
        cb(null, true);
    }
});

// Apply authentication middleware to most routes (except status)
// Note: Individual routes will apply their own middleware

// POST /api/v1/vault/receiver/setup - Generate receiver key pair (Admin only)
router.post('/receiver/setup', authenticateToken, requireRole(['admin']), async (req, res) => {
    try {
        const { receiverId } = req.body;

        if (!receiverId) {
            return res.status(400).json({
                status: 'error',
                message: 'Receiver ID is required'
            });
        }

        const keyPair = await vaultService.generateReceiverKeyPair(receiverId);

        res.json({
            status: 'success',
            data: {
                receiverId: keyPair.receiverId,
                publicKey: keyPair.publicKey,
                message: 'Receiver key pair generated successfully'
            }
        });
    } catch (error) {
        logger.error('Error setting up receiver:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to setup receiver'
        });
    }
});

// GET /api/v1/vault/receiver/:receiverId/public-key - Get receiver's public key
router.get('/receiver/:receiverId/public-key', async (req, res) => {
    try {
        let receiverId = req.params.receiverId;

        // Resolve "admin-uuid" to actual admin UUID
        if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(receiverId)) {
            logger.info(`Resolving receiver ID "${receiverId}" to actual user UUID...`);

            if (receiverId.toLowerCase().includes('admin')) {
                // Prefer admin users that already have receiver keys
                const userResult = await pool.query(
                    `SELECT u.id 
                     FROM users u 
                     INNER JOIN receiver_keys rk ON u.id = rk.receiver_id 
                     WHERE u.user_type = $1 
                     ORDER BY u.created_at LIMIT 1`,
                    ['admin']
                );

                if (userResult.rows.length > 0) {
                    receiverId = userResult.rows[0].id;
                    logger.info(`Resolved to user ID: ${receiverId}`);
                } else {
                    // Fallback to any admin user
                    const fallbackResult = await pool.query(
                        'SELECT id FROM users WHERE user_type = $1 ORDER BY created_at LIMIT 1',
                        ['admin']
                    );

                    if (fallbackResult.rows.length > 0) {
                        receiverId = fallbackResult.rows[0].id;
                        logger.info(`Resolved to admin user ID: ${receiverId} (no keys yet)`);
                    } else {
                        return res.status(404).json({
                            status: 'error',
                            message: 'No admin users found'
                        });
                    }
                }
            } else {
                return res.status(400).json({
                    status: 'error',
                    message: `Invalid receiver ID format: "${receiverId}"`
                });
            }
        }

        const publicKey = await vaultService.getReceiverPublicKey(receiverId);

        res.json({
            status: 'success',
            data: {
                receiverId: receiverId,
                publicKey: publicKey
            }
        });
    } catch (error) {
        logger.error('Error getting receiver public key:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to get receiver public key'
        });
    }
});

// POST /api/v1/vault/upload - Upload file to vault (Business users)
router.post('/upload', authenticateToken, requireRole(['business']), upload.single('file'), async (req, res) => {
    try {
        const { receiverId } = req.body;
        const file = req.file;
        const senderId = req.user.id;

        if (!file) {
            return res.status(400).json({
                status: 'error',
                message: 'No file provided'
            });
        }

        if (!receiverId) {
            return res.status(400).json({
                status: 'error',
                message: 'Receiver ID is required'
            });
        }

        // Upload file to vault with complete encryption workflow
        const result = await vaultService.uploadToVaultComplete(
            file.buffer,
            file.originalname,
            senderId,
            receiverId
        );

        // Store file metadata
        await pool.query(
            `INSERT INTO vault_files (transaction_id, sender_id, receiver_id, original_filename, 
             encrypted_filename, file_size, mime_type, ipfs_hash, status) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
            [
                result.transactionId,
                senderId,
                receiverId,
                file.originalname,
                `${file.originalname}.encrypted`,
                file.size,
                file.mimetype,
                result.vaultHash,
                'uploaded'
            ]
        );

        logger.info(`File uploaded to vault: ${file.originalname} by ${senderId} for ${receiverId}`);

        res.json({
            status: 'success',
            data: {
                transactionId: result.transactionId,
                vaultHash: result.vaultHash,
                vaultUrl: result.vaultUrl,
                fileName: result.fileName,
                receiverId: result.receiverId,
                message: 'File uploaded to vault successfully'
            }
        });
    } catch (error) {
        logger.error('Error uploading to vault:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to upload file to vault'
        });
    }
});

// GET /api/v1/vault/receiver/:receiverId/transactions - Get receiver's transactions
router.get('/receiver/:receiverId/transactions', authenticateToken, requireRole(['admin']), async (req, res) => {
    try {
        const { receiverId } = req.params;

        const transactions = await vaultService.getReceiverTransactions(receiverId);

        res.json({
            status: 'success',
            data: {
                receiverId: receiverId,
                transactions: transactions,
                count: transactions.length
            }
        });
    } catch (error) {
        logger.error('Error getting receiver transactions:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to get receiver transactions'
        });
    }
});

// POST /api/v1/vault/download/:transactionId - Download and decrypt file
router.post('/download/:transactionId', authenticateToken, requireRole(['admin']), async (req, res) => {
    try {
        const { transactionId } = req.params;
        const receiverId = req.user.id;

        // Download and decrypt file from vault
        const result = await vaultService.downloadFromVaultComplete(transactionId, receiverId);

        // Update file status
        await pool.query(
            'UPDATE vault_files SET status = $1, updated_at = NOW() WHERE transaction_id = $2',
            ['downloaded', transactionId]
        );

        logger.info(`File downloaded from vault: ${result.fileName} by ${receiverId}`);

        // Set appropriate headers for file download
        res.setHeader('Content-Type', 'application/octet-stream');
        res.setHeader('Content-Disposition', `attachment; filename="${result.fileName}"`);
        res.setHeader('Content-Length', result.decryptedData.length);

        res.send(result.decryptedData);
    } catch (error) {
        logger.error('Error downloading from vault:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to download file from vault'
        });
    }
});

// GET /api/v1/vault/files/sender - Get files uploaded by sender
router.get('/files/sender', authenticateToken, requireRole(['business']), async (req, res) => {
    try {
        const senderId = req.user.id;
        const { limit = 50, offset = 0 } = req.query;

        const result = await pool.query(
            `SELECT vf.*, vt.transaction_data, vt.created_at as transaction_created_at
             FROM vault_files vf
             JOIN vault_transactions vt ON vf.transaction_id = vt.id
             WHERE vf.sender_id = $1
             ORDER BY vf.created_at DESC
             LIMIT $2 OFFSET $3`,
            [senderId, parseInt(limit), parseInt(offset)]
        );

        res.json({
            status: 'success',
            data: {
                files: result.rows,
                count: result.rows.length
            }
        });
    } catch (error) {
        logger.error('Error getting sender files:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to get sender files'
        });
    }
});

// GET /api/v1/vault/files/receiver - Get files for receiver
router.get('/files/receiver', authenticateToken, requireRole(['admin']), async (req, res) => {
    try {
        const receiverId = req.user.id;
        const { limit = 50, offset = 0 } = req.query;

        const result = await pool.query(
            `SELECT vf.*, vt.transaction_data, vt.created_at as transaction_created_at
             FROM vault_files vf
             JOIN vault_transactions vt ON vf.transaction_id = vt.id
             WHERE vf.receiver_id = $1
             ORDER BY vf.created_at DESC
             LIMIT $2 OFFSET $3`,
            [receiverId, parseInt(limit), parseInt(offset)]
        );

        res.json({
            status: 'success',
            data: {
                files: result.rows,
                count: result.rows.length
            }
        });
    } catch (error) {
        logger.error('Error getting receiver files:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to get receiver files'
        });
    }
});

// GET /api/v1/vault/status - Get vault system status
router.get('/status', async (req, res) => {
    try {
        // Check IPFS connection
        let ipfsStatus = 'disconnected';
        if (vaultService.ipfsAvailable) {
            try {
                await vaultService.ipfs.version();
                ipfsStatus = 'connected';
            } catch (error) {
                logger.warn('IPFS connection check failed:', error.message);
                ipfsStatus = 'disconnected';
            }
        } else {
            ipfsStatus = 'local-fallback';
        }

        // Get vault statistics
        const statsResult = await pool.query(`
            SELECT 
                COUNT(*) as total_files,
                COUNT(CASE WHEN status = 'uploaded' THEN 1 END) as uploaded_files,
                COUNT(CASE WHEN status = 'downloaded' THEN 1 END) as downloaded_files,
                COUNT(DISTINCT sender_id) as unique_senders,
                COUNT(DISTINCT receiver_id) as unique_receivers
            FROM vault_files
        `);

        const stats = statsResult.rows[0];

        res.json({
            status: 'success',
            data: {
                vaultStatus: 'operational',
                ipfsStatus: ipfsStatus,
                statistics: {
                    totalFiles: parseInt(stats.total_files),
                    uploadedFiles: parseInt(stats.uploaded_files),
                    downloadedFiles: parseInt(stats.downloaded_files),
                    uniqueSenders: parseInt(stats.unique_senders),
                    uniqueReceivers: parseInt(stats.unique_receivers)
                },
                encryption: {
                    algorithm: 'AES-256-CBC',
                    keyExchange: 'RSA-2048',
                    storage: 'IPFS'
                },
                blockchain: {
                    enabled: blockchainVaultService && blockchainVaultService.isServiceAvailable(),
                    contractAddress: process.env.VAULT_CONTRACT_ADDRESS || '0xd54d40692605feebbe296e1cd0b5cf910602ad90',
                    network: 'BlockDAG'
                }
            }
        });
    } catch (error) {
        logger.error('Error getting vault status:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to get vault status'
        });
    }
});

// ============================================================================
// BLOCKCHAIN ENDPOINTS FOR FRONTEND INTEGRATION
// ============================================================================

// POST /api/v1/vault/blockchain/create-transaction - Create blockchain transaction
router.post('/blockchain/create-transaction', authenticateToken, requireRole(['business']), async (req, res) => {
    try {
        const { receiverAddress, ipfsHash, encryptedFileKey, encryptionMetadata } = req.body;
        const senderId = req.user.id;

        if (!receiverAddress || !ipfsHash || !encryptedFileKey) {
            return res.status(400).json({
                status: 'error',
                message: 'receiverAddress, ipfsHash, and encryptedFileKey are required'
            });
        }

        if (!blockchainVaultService || !blockchainVaultService.isServiceAvailable()) {
            return res.status(503).json({
                status: 'error',
                message: 'Blockchain service is not available'
            });
        }

        // Call blockchain service to create transaction
        const result = await blockchainVaultService.createKeyHandshakeTransaction(
            receiverAddress,
            ipfsHash,
            encryptedFileKey,
            encryptionMetadata || {}
        );

        // Also store in database for reference
        await pool.query(
            `INSERT INTO vault_transactions 
             (id, sender_id, receiver_id, ipfs_hash, encrypted_file_key, transaction_data)
             VALUES ($1, $2, $3, $4, $5, $6)`,
            [
                require('crypto').randomUUID(),
                senderId,
                receiverAddress, // Store receiver address
                ipfsHash,
                encryptedFileKey,
                JSON.stringify({
                    ...encryptionMetadata,
                    blockchainTxHash: result.txHash,
                    transactionId: result.transactionId,
                    blockNumber: result.blockNumber
                })
            ]
        );

        res.json({
            status: 'success',
            data: {
                txHash: result.txHash,
                transactionId: result.transactionId,
                blockNumber: result.blockNumber
            }
        });
    } catch (error) {
        logger.error('Error creating blockchain transaction:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to create blockchain transaction',
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
});

// GET /api/v1/vault/blockchain/public-key?receiver=0x... - Get receiver's public key from blockchain
router.get('/blockchain/public-key', async (req, res) => {
    try {
        const { receiver } = req.query;

        if (!receiver) {
            return res.status(400).json({
                status: 'error',
                message: 'receiver address is required'
            });
        }

        if (!blockchainVaultService || !blockchainVaultService.isServiceAvailable()) {
            return res.status(503).json({
                status: 'error',
                message: 'Blockchain service is not available'
            });
        }

        // Try to get from blockchain first
        const publicKey = await blockchainVaultService.getReceiverPublicKey(receiver);

        if (publicKey) {
            return res.json({
                status: 'success',
                data: {
                    receiver: receiver,
                    publicKey: publicKey
                }
            });
        }

        // Fallback: get from database
        const dbResult = await pool.query(
            'SELECT public_key FROM receiver_keys WHERE user_id = $1',
            [receiver]
        );

        if (dbResult.rows.length > 0) {
            return res.json({
                status: 'success',
                data: {
                    receiver: receiver,
                    publicKey: dbResult.rows[0].public_key
                }
            });
        }

        return res.status(404).json({
            status: 'error',
            message: 'Public key not found for receiver'
        });
    } catch (error) {
        logger.error('Error getting public key from blockchain:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to get public key'
        });
    }
});

// GET /api/v1/vault/blockchain/transaction/:hash - Get transaction details from blockchain
router.get('/blockchain/transaction/:hash', async (req, res) => {
    try {
        const { hash } = req.params;

        if (!hash) {
            return res.status(400).json({
                status: 'error',
                message: 'Transaction hash is required'
            });
        }

        // Get from database
        const result = await pool.query(
            `SELECT vt.*, 
                    u.email as sender_email,
                    u.wallet_address as sender_address
             FROM vault_transactions vt
             LEFT JOIN users u ON vt.sender_id = u.id
             WHERE vt.transaction_data->>'blockchainTxHash' = $1
             ORDER BY vt.created_at DESC
             LIMIT 1`,
            [hash]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                status: 'error',
                message: 'Transaction not found'
            });
        }

        const transaction = result.rows[0];
        const blockchainData = transaction.transaction_data;

        res.json({
            status: 'success',
            data: {
                transactionId: transaction.id,
                sender: transaction.sender_address || transaction.sender_id,
                receiver: transaction.receiver_id,
                ipfsHash: transaction.ipfs_hash,
                encryptedFileKey: transaction.encrypted_file_key,
                txHash: blockchainData?.blockchainTxHash,
                blockNumber: blockchainData?.blockNumber,
                timestamp: new Date(transaction.created_at).toISOString(),
                status: 'confirmed'
            }
        });
    } catch (error) {
        logger.error('Error getting transaction details:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to get transaction details'
        });
    }
});

module.exports = router;




