require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const logger = require('./config/logger');
const pool = require('./config/database');
const monitoringService = require('./services/monitoring-service');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.status(200).json({
            status: 'healthy',
            timestamp: new Date().toISOString(),
            service: 'trustseal-backend'
        });
    } catch (error) {
        res.status(503).json({
            status: 'unhealthy',
            error: error.message
        });
    }
});

// API Routes
app.use('/api/v1/auth', require('./routes/auth'));
app.use('/api/v1/business', require('./routes/business'));
app.use('/api/v1/blockdag', require('./routes/blockdag'));
app.use('/api/v1/files', require('./routes/files'));
app.use('/api/v1/vault', require('./routes/vault'));
app.use('/api/v1/projects', require('./routes/projects'));
app.use('/api/v1/admin', require('./routes/admin'));

// Error handling middleware
app.use((err, req, res, next) => {
    logger.error('Error:', err);
    res.status(err.status || 500).json({
        error: {
            message: err.message || 'Internal Server Error',
            ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
        }
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not Found' });
});

// Start server
app.listen(PORT, async () => {
    logger.info(`Server running on port ${PORT}`);

    // Start monitoring service
    try {
        await pool.query('SELECT 1');
        logger.info('Database connection established');

        monitoringService.start();

        logger.info('TrustSeal Backend started successfully');
    } catch (error) {
        logger.error('Failed to start services:', error);
        process.exit(1);
    }
});

// Graceful shutdown
process.on('SIGTERM', () => {
    logger.info('SIGTERM received, shutting down gracefully');
    monitoringService.stop();
    pool.end();
    process.exit(0);
});

module.exports = app;
