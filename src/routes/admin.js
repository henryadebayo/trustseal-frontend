const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const logger = require('../config/logger');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// Apply authentication middleware to all admin routes
router.use(authenticateToken);
router.use(requireAdmin); // Only admins can access admin endpoints

// Get verification queue
router.get('/verification-queue', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT p.*, vc.risk_level, vc.overall_score 
             FROM projects p
             LEFT JOIN verification_criteria vc ON p.id = vc.project_id
             WHERE p.verification_status = 'under_review'
             ORDER BY p.created_at ASC`
        );

        res.json({
            data: result.rows,
            count: result.rows.length
        });
    } catch (error) {
        logger.error('Error fetching verification queue:', error);
        res.status(500).json({ error: 'Failed to fetch verification queue' });
    }
});

// Approve project
router.post('/approve/:projectId', async (req, res) => {
    try {
        const { projectId } = req.params;
        const { adminId } = req.body;

        // Update project status to verified
        const result = await pool.query(
            `UPDATE projects 
             SET verification_status = 'verified'
             WHERE id = $1
             RETURNING *`,
            [projectId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Project not found' });
        }

        // Log audit event
        await pool.query(
            `INSERT INTO audit_logs (project_id, action, admin_id, details)
             VALUES ($1, 'approved', $2, $3)`,
            [projectId, adminId, JSON.stringify({ timestamp: new Date() })]
        );

        logger.info(`Project ${projectId} approved by admin ${adminId}`);

        res.json({
            message: 'Project approved successfully',
            project: result.rows[0]
        });
    } catch (error) {
        logger.error('Error approving project:', error);
        res.status(500).json({ error: 'Failed to approve project' });
    }
});

// Reject project
router.post('/reject/:projectId', async (req, res) => {
    try {
        const { projectId } = req.params;
        const { adminId, reason } = req.body;

        // Update project status to rejected
        const result = await pool.query(
            `UPDATE projects 
             SET verification_status = 'rejected'
             WHERE id = $1
             RETURNING *`,
            [projectId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Project not found' });
        }

        // Log audit event
        await pool.query(
            `INSERT INTO audit_logs (project_id, action, admin_id, details)
             VALUES ($1, 'rejected', $2, $3)`,
            [projectId, adminId, JSON.stringify({ reason, timestamp: new Date() })]
        );

        logger.info(`Project ${projectId} rejected by admin ${adminId}: ${reason}`);

        res.json({
            message: 'Project rejected',
            project: result.rows[0]
        });
    } catch (error) {
        logger.error('Error rejecting project:', error);
        res.status(500).json({ error: 'Failed to reject project' });
    }
});

// Get audit logs
router.get('/audit-logs', async (req, res) => {
    try {
        const { projectId, limit = 100, offset = 0 } = req.query;

        let query = 'SELECT * FROM audit_logs';
        const params = [];

        if (projectId) {
            query += ' WHERE project_id = $1';
            params.push(projectId);
        }

        query += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
        params.push(parseInt(limit), parseInt(offset));

        const result = await pool.query(query, params);

        res.json({
            data: result.rows,
            count: result.rows.length
        });
    } catch (error) {
        logger.error('Error fetching audit logs:', error);
        res.status(500).json({ error: 'Failed to fetch audit logs' });
    }
});

// Add verification check
router.post('/verification-checks/:projectId', async (req, res) => {
    try {
        const { projectId } = req.params;
        const { check_type, check_name, status, score, details, verified_by } = req.body;

        if (!check_type || !check_name) {
            return res.status(400).json({ error: 'check_type and check_name are required' });
        }

        const result = await pool.query(
            `INSERT INTO verification_checks 
             (project_id, check_type, check_name, status, score, details, verified_by, verified_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
             RETURNING *`,
            [projectId, check_type, check_name, status || 'pending', score, details, verified_by]
        );

        res.status(201).json(result.rows[0]);
    } catch (error) {
        logger.error('Error adding verification check:', error);
        res.status(500).json({ error: 'Failed to add verification check' });
    }
});

module.exports = router;
