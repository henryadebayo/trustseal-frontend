const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const blockchainService = require('../services/blockchain-service');
const verificationEngine = require('../services/verification-engine');
const logger = require('../config/logger');

// Get all projects
router.get('/', async (req, res) => {
    try {
        const { status, limit = 50, offset = 0 } = req.query;

        let query = 'SELECT * FROM projects';
        const params = [];

        if (status) {
            query += ' WHERE verification_status = $1';
            params.push(status);
        }

        query += ' ORDER BY created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
        params.push(parseInt(limit), parseInt(offset));

        const result = await pool.query(query, params);

        res.json({
            data: result.rows,
            count: result.rows.length
        });
    } catch (error) {
        logger.error('Error fetching projects:', error);
        res.status(500).json({ error: 'Failed to fetch projects' });
    }
});

// Get project by ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const projectResult = await pool.query(
            'SELECT * FROM projects WHERE id = $1',
            [id]
        );

        if (projectResult.rows.length === 0) {
            return res.status(404).json({ error: 'Project not found' });
        }

        const project = projectResult.rows[0];

        // Get verification criteria
        const criteriaResult = await pool.query(
            'SELECT * FROM verification_criteria WHERE project_id = $1',
            [id]
        );

        // Get verification checks
        const checksResult = await pool.query(
            'SELECT * FROM verification_checks WHERE project_id = $1 ORDER BY created_at DESC',
            [id]
        );

        res.json({
            ...project,
            verification_criteria: criteriaResult.rows[0] || null,
            verification_checks: checksResult.rows
        });
    } catch (error) {
        logger.error('Error fetching project:', error);
        res.status(500).json({ error: 'Failed to fetch project' });
    }
});

// Create new project
router.post('/', async (req, res) => {
    try {
        const { name, description, website, contract_address, token_symbol, token_name } = req.body;

        if (!name || !description) {
            return res.status(400).json({ error: 'Name and description are required' });
        }

        // Verify contract if provided
        let contractInfo = null;
        if (contract_address) {
            try {
                contractInfo = await blockchainService.verifyContract(contract_address);
            } catch (error) {
                logger.warn('Failed to verify contract:', error.message);
            }
        }

        const result = await pool.query(
            `INSERT INTO projects (name, description, website, contract_address, token_symbol, token_name)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING *`,
            [name, description, website, contract_address, token_symbol, token_name]
        );

        // Create verification criteria entry
        await pool.query(
            'INSERT INTO verification_criteria (project_id) VALUES ($1)',
            [result.rows[0].id]
        );

        res.status(201).json({
            ...result.rows[0],
            contract_info: contractInfo
        });
    } catch (error) {
        logger.error('Error creating project:', error);
        res.status(500).json({ error: 'Failed to create project' });
    }
});

// Update project
router.put('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { name, description, website, contract_address, token_symbol, token_name } = req.body;

        const result = await pool.query(
            `UPDATE projects 
             SET name = COALESCE($1, name),
                 description = COALESCE($2, description),
                 website = COALESCE($3, website),
                 contract_address = COALESCE($4, contract_address),
                 token_symbol = COALESCE($5, token_symbol),
                 token_name = COALESCE($6, token_name)
             WHERE id = $7
             RETURNING *`,
            [name, description, website, contract_address, token_symbol, token_name, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Project not found' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        logger.error('Error updating project:', error);
        res.status(500).json({ error: 'Failed to update project' });
    }
});

// Initiate verification
router.post('/:id/verify', async (req, res) => {
    try {
        const { id } = req.params;

        // Check if project exists
        const projectResult = await pool.query(
            'SELECT * FROM projects WHERE id = $1',
            [id]
        );

        if (projectResult.rows.length === 0) {
            return res.status(404).json({ error: 'Project not found' });
        }

        const project = projectResult.rows[0];

        // Update status to under_review
        await pool.query(
            'UPDATE projects SET verification_status = $1 WHERE id = $2',
            ['under_review', id]
        );

        // Calculate trust score
        const trustScore = await verificationEngine.calculateTrustScore(id);

        // Determine verification tier
        const tier = verificationEngine.determineVerificationTier(trustScore.overallScore);

        // Update verification tier
        await pool.query(
            'UPDATE projects SET verification_tier = $1 WHERE id = $2',
            [tier, id]
        );

        res.json({
            message: 'Verification initiated',
            trust_score: trustScore,
            verification_tier: tier
        });
    } catch (error) {
        logger.error('Error initiating verification:', error);
        res.status(500).json({ error: 'Failed to initiate verification' });
    }
});

// Get verification status
router.get('/:id/verification-status', async (req, res) => {
    try {
        const { id } = req.params;

        const criteriaResult = await pool.query(
            'SELECT * FROM verification_criteria WHERE project_id = $1',
            [id]
        );

        const checksResult = await pool.query(
            'SELECT * FROM verification_checks WHERE project_id = $1',
            [id]
        );

        const projectResult = await pool.query(
            'SELECT verification_status, verification_tier, trust_score FROM projects WHERE id = $1',
            [id]
        );

        res.json({
            project: projectResult.rows[0],
            criteria: criteriaResult.rows[0],
            checks: checksResult.rows
        });
    } catch (error) {
        logger.error('Error fetching verification status:', error);
        res.status(500).json({ error: 'Failed to fetch verification status' });
    }
});

module.exports = router;
