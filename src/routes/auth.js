const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const pool = require('../config/database');
const logger = require('../config/logger');
const {
    generateTokens,
    isValidWalletAddress,
    isValidEmail,
    validatePasswordStrength
} = require('../middleware/auth');

const router = express.Router();

// POST /api/v1/auth/register
router.post('/register', async (req, res) => {
    try {
        const { email, password, firstName, lastName, userType = 'user' } = req.body;

        // Validation
        if (!email || !password || !firstName || !lastName) {
            return res.status(400).json({
                status: 'error',
                message: 'Email, password, first name, and last name are required'
            });
        }

        if (!isValidEmail(email)) {
            return res.status(400).json({
                status: 'error',
                message: 'Invalid email format'
            });
        }

        const passwordValidation = validatePasswordStrength(password);
        if (!passwordValidation.isValid) {
            return res.status(400).json({
                status: 'error',
                message: 'Password does not meet requirements',
                details: passwordValidation.errors
            });
        }

        if (!['admin', 'business', 'user'].includes(userType)) {
            return res.status(400).json({
                status: 'error',
                message: 'Invalid user type'
            });
        }

        // Check if user already exists
        const existingUser = await pool.query(
            'SELECT id FROM users WHERE email = $1',
            [email.toLowerCase()]
        );

        if (existingUser.rows.length > 0) {
            return res.status(409).json({
                status: 'error',
                message: 'User with this email already exists'
            });
        }

        // Hash password
        const saltRounds = 12;
        const passwordHash = await bcrypt.hash(password, saltRounds);

        // Generate email verification token
        const emailVerificationToken = crypto.randomBytes(32).toString('hex');

        // Create user
        const result = await pool.query(
            `INSERT INTO users (email, password_hash, first_name, last_name, user_type, email_verification_token)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id, email, first_name, last_name, user_type, created_at`,
            [email.toLowerCase(), passwordHash, firstName, lastName, userType, emailVerificationToken]
        );

        const user = result.rows[0];

        // Generate tokens
        const { accessToken, refreshToken } = generateTokens(user.id);

        // Store refresh token
        await pool.query(
            'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)',
            [user.id, crypto.createHash('sha256').update(refreshToken).digest('hex'), new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)]
        );

        logger.info(`New user registered: ${user.email}`);

        res.status(201).json({
            status: 'success',
            message: 'User registered successfully. Please verify your email.',
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.first_name,
                    lastName: user.last_name,
                    userType: user.user_type,
                    isEmailVerified: false
                },
                token: accessToken,
                refreshToken: refreshToken
            }
        });

    } catch (error) {
        logger.error('Registration error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Registration failed'
        });
    }
});

// POST /api/v1/auth/login
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                status: 'error',
                message: 'Email and password are required'
            });
        }

        // Find user
        const userResult = await pool.query(
            'SELECT id, email, password_hash, first_name, last_name, user_type, is_active, is_email_verified FROM users WHERE email = $1',
            [email.toLowerCase()]
        );

        if (userResult.rows.length === 0) {
            return res.status(401).json({
                status: 'error',
                message: 'Invalid email or password'
            });
        }

        const user = userResult.rows[0];

        if (!user.is_active) {
            return res.status(401).json({
                status: 'error',
                message: 'Account is deactivated'
            });
        }

        // Verify password
        const isValidPassword = await bcrypt.compare(password, user.password_hash);
        if (!isValidPassword) {
            return res.status(401).json({
                status: 'error',
                message: 'Invalid email or password'
            });
        }

        // Update last login
        await pool.query(
            'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = $1',
            [user.id]
        );

        // Generate tokens
        const { accessToken, refreshToken } = generateTokens(user.id);

        // Store refresh token
        await pool.query(
            'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)',
            [user.id, crypto.createHash('sha256').update(refreshToken).digest('hex'), new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)]
        );

        logger.info(`User logged in: ${user.email}`);

        res.json({
            status: 'success',
            message: 'Login successful',
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.first_name,
                    lastName: user.last_name,
                    userType: user.user_type,
                    isEmailVerified: user.is_email_verified
                },
                token: accessToken,
                refreshToken: refreshToken
            }
        });

    } catch (error) {
        logger.error('Login error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Login failed'
        });
    }
});

// POST /api/v1/auth/wallet/connect
router.post('/wallet/connect', async (req, res) => {
    try {
        const { walletAddress, signature, message } = req.body;

        if (!walletAddress || !signature || !message) {
            return res.status(400).json({
                status: 'error',
                message: 'Wallet address, signature, and message are required'
            });
        }

        if (!isValidWalletAddress(walletAddress)) {
            return res.status(400).json({
                status: 'error',
                message: 'Invalid wallet address format'
            });
        }

        // TODO: Implement signature verification
        // For now, we'll just check if the wallet address is valid
        // In production, you should verify the signature against the message

        // Check if wallet is already connected to another user
        const existingWallet = await pool.query(
            'SELECT id, email FROM users WHERE wallet_address = $1',
            [walletAddress.toLowerCase()]
        );

        if (existingWallet.rows.length > 0) {
            return res.status(409).json({
                status: 'error',
                message: 'Wallet address is already connected to another account'
            });
        }

        // For wallet-only registration, create a user without email
        const result = await pool.query(
            `INSERT INTO users (wallet_address, user_type, is_email_verified)
             VALUES ($1, $2, $3)
             RETURNING id, wallet_address, user_type, created_at`,
            [walletAddress.toLowerCase(), 'business', true]
        );

        const user = result.rows[0];

        // Generate tokens
        const { accessToken, refreshToken } = generateTokens(user.id);

        // Store refresh token
        await pool.query(
            'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)',
            [user.id, crypto.createHash('sha256').update(refreshToken).digest('hex'), new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)]
        );

        logger.info(`Wallet connected: ${walletAddress}`);

        res.status(201).json({
            status: 'success',
            message: 'Wallet connected successfully',
            data: {
                user: {
                    id: user.id,
                    walletAddress: user.wallet_address,
                    userType: user.user_type,
                    isEmailVerified: true
                },
                token: accessToken,
                refreshToken: refreshToken
            }
        });

    } catch (error) {
        logger.error('Wallet connection error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Wallet connection failed'
        });
    }
});

// GET /api/v1/auth/profile
router.get('/profile', async (req, res) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) {
            return res.status(401).json({
                status: 'error',
                message: 'Access token required'
            });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const userResult = await pool.query(
            `SELECT u.id, u.email, u.first_name, u.last_name, u.user_type, u.wallet_address, 
                    u.is_email_verified, u.last_login, u.created_at,
                    bo.business_name, bo.business_type, bo.website
             FROM users u
             LEFT JOIN business_owners bo ON u.id = bo.user_id
             WHERE u.id = $1`,
            [decoded.userId]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({
                status: 'error',
                message: 'User not found'
            });
        }

        const user = userResult.rows[0];

        res.json({
            status: 'success',
            data: {
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.first_name,
                    lastName: user.last_name,
                    userType: user.user_type,
                    walletAddress: user.wallet_address,
                    isEmailVerified: user.is_email_verified,
                    lastLogin: user.last_login,
                    createdAt: user.created_at,
                    business: user.business_name ? {
                        name: user.business_name,
                        type: user.business_type,
                        website: user.website
                    } : null
                }
            }
        });

    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                status: 'error',
                message: 'Invalid token'
            });
        }
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                status: 'error',
                message: 'Token expired'
            });
        }

        logger.error('Profile fetch error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to fetch profile'
        });
    }
});

// POST /api/v1/auth/logout
router.post('/logout', async (req, res) => {
    try {
        const { refreshToken } = req.body;

        if (refreshToken) {
            // Invalidate refresh token
            const tokenHash = crypto.createHash('sha256').update(refreshToken).digest('hex');
            await pool.query(
                'DELETE FROM refresh_tokens WHERE token_hash = $1',
                [tokenHash]
            );
        }

        res.json({
            status: 'success',
            message: 'Logged out successfully'
        });

    } catch (error) {
        logger.error('Logout error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Logout failed'
        });
    }
});

// POST /api/v1/auth/refresh
router.post('/refresh', async (req, res) => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            return res.status(400).json({
                status: 'error',
                message: 'Refresh token required'
            });
        }

        const tokenHash = crypto.createHash('sha256').update(refreshToken).digest('hex');

        // Verify refresh token
        const tokenResult = await pool.query(
            'SELECT user_id FROM refresh_tokens WHERE token_hash = $1 AND expires_at > NOW()',
            [tokenHash]
        );

        if (tokenResult.rows.length === 0) {
            return res.status(401).json({
                status: 'error',
                message: 'Invalid or expired refresh token'
            });
        }

        const userId = tokenResult.rows[0].user_id;

        // Check if user is still active
        const userResult = await pool.query(
            'SELECT id, is_active FROM users WHERE id = $1',
            [userId]
        );

        if (userResult.rows.length === 0 || !userResult.rows[0].is_active) {
            return res.status(401).json({
                status: 'error',
                message: 'User not found or inactive'
            });
        }

        // Generate new tokens
        const { accessToken, refreshToken: newRefreshToken } = generateTokens(userId);

        // Delete old refresh token and store new one
        await pool.query('DELETE FROM refresh_tokens WHERE token_hash = $1', [tokenHash]);
        await pool.query(
            'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)',
            [userId, crypto.createHash('sha256').update(newRefreshToken).digest('hex'), new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)]
        );

        res.json({
            status: 'success',
            data: {
                token: accessToken,
                refreshToken: newRefreshToken
            }
        });

    } catch (error) {
        logger.error('Token refresh error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Token refresh failed'
        });
    }
});

module.exports = router;
