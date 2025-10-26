const express = require('express');
const pool = require('../config/database');
const logger = require('../config/logger');
const { authenticateToken, requireRole } = require('../middleware/auth');

const router = express.Router();

// Apply authentication middleware to all routes
router.use(authenticateToken);
router.use(requireRole(['business'])); // Only business owners can access business endpoints

// GET /api/v1/business/owner/projects
router.get('/owner/projects', async (req, res) => {
    try {
        const { status, limit = 50, offset = 0 } = req.query;
        const userId = req.user.id;

        let query = `
            SELECT p.*, po.ownership_type, a.status as application_status, a.id as application_id
            FROM projects p
            INNER JOIN project_ownership po ON p.id = po.project_id
            LEFT JOIN applications a ON p.id = a.project_id AND a.user_id = $1
            WHERE po.user_id = $1
        `;
        const params = [userId];

        if (status) {
            query += ' AND p.verification_status = $2';
            params.push(status);
        }

        query += ' ORDER BY p.created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
        params.push(parseInt(limit), parseInt(offset));

        const result = await pool.query(query, params);

        res.json({
            status: 'success',
            data: result.rows,
            count: result.rows.length
        });
    } catch (error) {
        logger.error('Error fetching business owner projects:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to fetch projects'
        });
    }
});

// POST /api/v1/business/owner/projects
router.post('/owner/projects', async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            name,
            description,
            website,
            contract_address,
            token_symbol,
            token_name,
            network = 'blockdag',
            team_info,
            financial_info,
            community_info
        } = req.body;

        if (!name || !description) {
            return res.status(400).json({
                status: 'error',
                message: 'Name and description are required'
            });
        }

        const client = await pool.connect();
        try {
            await client.query('BEGIN');

            // Create project
            const projectResult = await client.query(
                `INSERT INTO projects (name, description, website, contract_address, token_symbol, token_name, verification_status)
                 VALUES ($1, $2, $3, $4, $5, $6, 'unverified')
                 RETURNING *`,
                [name, description, website, contract_address, token_symbol, token_name]
            );

            const project = projectResult.rows[0];

            // Create project ownership
            await client.query(
                'INSERT INTO project_ownership (project_id, user_id, ownership_type) VALUES ($1, $2, $3)',
                [project.id, userId, 'owner']
            );

            // Create verification criteria entry
            await client.query(
                'INSERT INTO verification_criteria (project_id) VALUES ($1)',
                [project.id]
            );

            // Create initial application if additional data provided
            if (team_info || financial_info || community_info) {
                const applicationData = {
                    team_info: team_info || {},
                    financial_info: financial_info || {},
                    community_info: community_info || {},
                    network: network
                };

                await client.query(
                    `INSERT INTO applications (user_id, project_id, application_type, status, submission_data)
                     VALUES ($1, $2, $3, $4, $5)`,
                    [userId, project.id, 'verification', 'draft', JSON.stringify(applicationData)]
                );
            }

            await client.query('COMMIT');

            logger.info(`Business owner ${userId} created project: ${project.name}`);

            res.status(201).json({
                status: 'success',
                message: 'Project created successfully',
                data: {
                    project: {
                        id: project.id,
                        name: project.name,
                        description: project.description,
                        website: project.website,
                        contractAddress: project.contract_address,
                        tokenSymbol: project.token_symbol,
                        tokenName: project.token_name,
                        verificationStatus: project.verification_status,
                        createdAt: project.created_at
                    }
                }
            });

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }

    } catch (error) {
        logger.error('Error creating project:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to create project'
        });
    }
});

// GET /api/v1/business/owner/applications
router.get('/owner/applications', async (req, res) => {
    try {
        const userId = req.user.id;
        const { status, limit = 50, offset = 0 } = req.query;

        let query = `
            SELECT a.*, p.name as project_name, p.verification_status, p.trust_score
            FROM applications a
            INNER JOIN projects p ON a.project_id = p.id
            WHERE a.user_id = $1
        `;
        const params = [userId];

        if (status) {
            query += ' AND a.status = $2';
            params.push(status);
        }

        query += ' ORDER BY a.created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
        params.push(parseInt(limit), parseInt(offset));

        const result = await pool.query(query, params);

        res.json({
            status: 'success',
            data: result.rows,
            count: result.rows.length
        });
    } catch (error) {
        logger.error('Error fetching applications:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to fetch applications'
        });
    }
});

// POST /api/v1/business/owner/applications
router.post('/owner/applications', async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            project_id,
            application_type = 'verification',
            submission_data = {}
        } = req.body;

        if (!project_id) {
            return res.status(400).json({
                status: 'error',
                message: 'Project ID is required'
            });
        }

        // Verify project ownership
        const ownershipResult = await pool.query(
            'SELECT ownership_type FROM project_ownership WHERE project_id = $1 AND user_id = $2',
            [project_id, userId]
        );

        if (ownershipResult.rows.length === 0) {
            return res.status(403).json({
                status: 'error',
                message: 'You do not have permission to create applications for this project'
            });
        }

        // Check if there's already a pending application
        const existingApplication = await pool.query(
            'SELECT id FROM applications WHERE project_id = $1 AND user_id = $2 AND status IN ($3, $4)',
            [project_id, userId, 'draft', 'submitted']
        );

        if (existingApplication.rows.length > 0) {
            return res.status(409).json({
                status: 'error',
                message: 'An application for this project already exists'
            });
        }

        const result = await pool.query(
            `INSERT INTO applications (user_id, project_id, application_type, status, submission_data)
             VALUES ($1, $2, $3, $4, $5)
             RETURNING *`,
            [userId, project_id, application_type, 'draft', JSON.stringify(submission_data)]
        );

        const application = result.rows[0];

        logger.info(`Business owner ${userId} created application for project ${project_id}`);

        res.status(201).json({
            status: 'success',
            message: 'Application created successfully',
            data: {
                application: {
                    id: application.id,
                    projectId: application.project_id,
                    applicationType: application.application_type,
                    status: application.status,
                    submissionData: JSON.parse(application.submission_data),
                    createdAt: application.created_at
                }
            }
        });

    } catch (error) {
        logger.error('Error creating application:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to create application'
        });
    }
});

// PUT /api/v1/business/owner/applications/:id/submit
router.put('/owner/applications/:id/submit', async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const { submission_data } = req.body;

        // Verify application ownership
        const applicationResult = await pool.query(
            'SELECT * FROM applications WHERE id = $1 AND user_id = $2',
            [id, userId]
        );

        if (applicationResult.rows.length === 0) {
            return res.status(404).json({
                status: 'error',
                message: 'Application not found'
            });
        }

        const application = applicationResult.rows[0];

        if (application.status !== 'draft') {
            return res.status(400).json({
                status: 'error',
                message: 'Only draft applications can be submitted'
            });
        }

        // Update application status to submitted
        const updateResult = await pool.query(
            `UPDATE applications 
             SET status = 'submitted', submission_data = $1, updated_at = CURRENT_TIMESTAMP
             WHERE id = $2
             RETURNING *`,
            [JSON.stringify(submission_data || application.submission_data), id]
        );

        // Update project status to under_review
        await pool.query(
            'UPDATE projects SET verification_status = $1 WHERE id = $2',
            ['under_review', application.project_id]
        );

        logger.info(`Business owner ${userId} submitted application ${id}`);

        res.json({
            status: 'success',
            message: 'Application submitted successfully',
            data: {
                application: {
                    id: updateResult.rows[0].id,
                    status: updateResult.rows[0].status,
                    submittedAt: updateResult.rows[0].updated_at
                }
            }
        });

    } catch (error) {
        logger.error('Error submitting application:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to submit application'
        });
    }
});

// GET /api/v1/business/owner/analytics
router.get('/owner/analytics', async (req, res) => {
    try {
        const userId = req.user.id;

        // Get project statistics
        const projectStats = await pool.query(`
            SELECT 
                COUNT(*) as total_projects,
                COUNT(CASE WHEN verification_status = 'verified' THEN 1 END) as verified_projects,
                COUNT(CASE WHEN verification_status = 'under_review' THEN 1 END) as pending_projects,
                COUNT(CASE WHEN verification_status = 'rejected' THEN 1 END) as rejected_projects,
                AVG(CAST(trust_score AS FLOAT)) as average_trust_score
            FROM projects p
            INNER JOIN project_ownership po ON p.id = po.project_id
            WHERE po.user_id = $1
        `, [userId]);

        // Get application statistics
        const applicationStats = await pool.query(`
            SELECT 
                COUNT(*) as total_applications,
                COUNT(CASE WHEN status = 'submitted' THEN 1 END) as submitted_applications,
                COUNT(CASE WHEN status = 'under_review' THEN 1 END) as under_review_applications,
                COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_applications,
                COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_applications
            FROM applications
            WHERE user_id = $1
        `, [userId]);

        // Get recent activity
        const recentActivity = await pool.query(`
            SELECT 
                'project' as type,
                p.name as title,
                p.verification_status as status,
                p.created_at as timestamp
            FROM projects p
            INNER JOIN project_ownership po ON p.id = po.project_id
            WHERE po.user_id = $1
            
            UNION ALL
            
            SELECT 
                'application' as type,
                CONCAT('Application for ', p.name) as title,
                a.status,
                a.created_at as timestamp
            FROM applications a
            INNER JOIN projects p ON a.project_id = p.id
            WHERE a.user_id = $1
            
            ORDER BY timestamp DESC
            LIMIT 10
        `, [userId]);

        const stats = projectStats.rows[0];
        const appStats = applicationStats.rows[0];

        res.json({
            status: 'success',
            data: {
                projects: {
                    total: parseInt(stats.total_projects),
                    verified: parseInt(stats.verified_projects),
                    pending: parseInt(stats.pending_projects),
                    rejected: parseInt(stats.rejected_projects),
                    averageTrustScore: parseFloat(stats.average_trust_score) || 0
                },
                applications: {
                    total: parseInt(appStats.total_applications),
                    submitted: parseInt(appStats.submitted_applications),
                    underReview: parseInt(appStats.under_review_applications),
                    approved: parseInt(appStats.approved_applications),
                    rejected: parseInt(appStats.rejected_applications)
                },
                recentActivity: recentActivity.rows
            }
        });

    } catch (error) {
        logger.error('Error fetching analytics:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to fetch analytics'
        });
    }
});

// GET /api/v1/business/owner/applications/:id
router.get('/owner/applications/:id', async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;

        const result = await pool.query(`
            SELECT a.*, p.name as project_name, p.verification_status, p.trust_score
            FROM applications a
            INNER JOIN projects p ON a.project_id = p.id
            WHERE a.id = $1 AND a.user_id = $2
        `, [id, userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                status: 'error',
                message: 'Application not found'
            });
        }

        const application = result.rows[0];

        res.json({
            status: 'success',
            data: {
                application: {
                    id: application.id,
                    projectId: application.project_id,
                    projectName: application.project_name,
                    applicationType: application.application_type,
                    status: application.status,
                    submissionData: JSON.parse(application.submission_data),
                    reviewNotes: application.review_notes,
                    reviewedBy: application.reviewed_by,
                    reviewedAt: application.reviewed_at,
                    createdAt: application.created_at,
                    updatedAt: application.updated_at
                }
            }
        });

    } catch (error) {
        logger.error('Error fetching application:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to fetch application'
        });
    }
});

module.exports = router;
