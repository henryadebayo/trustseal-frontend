const cron = require('node-cron');
const pool = require('../config/database');
const logger = require('../config/logger');
const blockchainService = require('./blockchain-service');
const verificationEngine = require('./verification-engine');

class MonitoringService {
    constructor() {
        this.isRunning = false;
    }

    start() {
        if (this.isRunning) {
            logger.warn('Monitoring service already running');
            return;
        }

        this.isRunning = true;
        logger.info('Starting monitoring service...');

        // Check liquidity locks every hour
        cron.schedule('0 * * * *', async () => {
            await this.checkLiquidityLocks();
        });

        // Risk reassessment every 6 hours
        cron.schedule('0 */6 * * *', async () => {
            await this.reassessRiskLevels();
        });

        // Generate daily reports at 9 AM
        cron.schedule('0 9 * * *', async () => {
            await this.generateDailyReport();
        });

        logger.info('Monitoring service started successfully');
    }

    async checkLiquidityLocks() {
        try {
            logger.info('Running liquidity lock check...');

            const result = await pool.query(
                `SELECT * FROM projects 
         WHERE verification_status IN ('verified', 'ongoing') 
         AND contract_address IS NOT NULL`
            );

            for (const project of result.rows) {
                try {
                    const lockStatus = await blockchainService.verifyLiquidityLock(
                        project.contract_address
                    );

                    if (lockStatus && lockStatus.expiryDate) {
                        const expiryDate = new Date(lockStatus.expiryDate);
                        const now = new Date();

                        // Check if lock is expiring soon (within 30 days)
                        if (expiryDate < now) {
                            // Lock has expired
                            await this.updateProjectStatus(project.id, 'ongoing');
                            await this.logAuditEvent(
                                project.id,
                                'liquidity_lock_expired',
                                { expiryDate: lockStatus.expiryDate }
                            );
                            logger.warn(`Liquidity lock expired for project ${project.name}`);
                        } else if (expiryDate.getTime() - now.getTime() < 30 * 24 * 60 * 60 * 1000) {
                            // Lock expiring soon
                            await this.notifyAdmins(project.id, 'Liquidity lock expiring soon');
                            logger.warn(`Liquidity lock expiring soon for project ${project.name}`);
                        }
                    }
                } catch (error) {
                    logger.error(`Error checking liquidity lock for project ${project.id}:`, error);
                }
            }

            logger.info('Liquidity lock check completed');
        } catch (error) {
            logger.error('Error in checkLiquidityLocks:', error);
        }
    }

    async reassessRiskLevels() {
        try {
            logger.info('Running risk level reassessment...');

            const result = await pool.query(
                'SELECT id FROM projects WHERE verification_status IN (\'under_review\', \'ongoing\')'
            );

            for (const project of result.rows) {
                try {
                    const riskLevel = await verificationEngine.assessRiskLevel(project.id);

                    if (riskLevel === 'high') {
                        await this.triggerUrgentReview(project.id);
                        await this.notifyAdmins(project.id, 'High risk detected');
                        logger.warn(`High risk detected for project ${project.id}`);
                    }

                    // Update risk level in verification criteria
                    await pool.query(
                        `UPDATE verification_criteria 
             SET risk_level = $1, updated_at = NOW() 
             WHERE project_id = $2`,
                        [riskLevel, project.id]
                    );
                } catch (error) {
                    logger.error(`Error reassessing risk for project ${project.id}:`, error);
                }
            }

            logger.info('Risk level reassessment completed');
        } catch (error) {
            logger.error('Error in reassessRiskLevels:', error);
        }
    }

    async generateDailyReport() {
        try {
            logger.info('Generating daily report...');

            // Get statistics
            const stats = await pool.query(`
        SELECT 
          verification_status,
          COUNT(*) as count,
          AVG(trust_score) as avg_trust_score
        FROM projects
        GROUP BY verification_status
      `);

            const report = {
                date: new Date().toISOString().split('T')[0],
                statistics: stats.rows,
                timestamp: new Date()
            };

            logger.info('Daily report generated:', JSON.stringify(report, null, 2));

            // Here you could send the report via email or store it in a database
        } catch (error) {
            logger.error('Error generating daily report:', error);
        }
    }

    async updateProjectStatus(projectId, status) {
        await pool.query(
            'UPDATE projects SET verification_status = $1 WHERE id = $2',
            [status, projectId]
        );
    }

    async logAuditEvent(projectId, action, details) {
        await pool.query(
            `INSERT INTO audit_logs (project_id, action, details) 
       VALUES ($1, $2, $3)`,
            [projectId, action, JSON.stringify(details)]
        );
    }

    async notifyAdmins(projectId, message) {
        // Placeholder for notification logic
        logger.info(`Admin notification for project ${projectId}: ${message}`);
    }

    async triggerUrgentReview(projectId) {
        // Placeholder for urgent review trigger
        logger.warn(`Triggering urgent review for project ${projectId}`);
    }

    stop() {
        this.isRunning = false;
        logger.info('Monitoring service stopped');
    }
}

module.exports = new MonitoringService();
