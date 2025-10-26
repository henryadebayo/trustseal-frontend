const express = require('express');
const pool = require('../config/database');
const logger = require('../config/logger');
const { authenticateToken } = require('../middleware/auth');
const {
    upload,
    uploadToS3,
    generateSignedUrl,
    deleteFromS3,
    validateFile,
    DOCUMENT_CATEGORIES
} = require('../config/fileUpload');

const router = express.Router();

// Apply authentication middleware to all routes
router.use(authenticateToken);

// POST /api/v1/files/upload
router.post('/upload', upload.array('files', 10), async (req, res) => {
    try {
        const userId = req.user.id;
        const { category, projectId, applicationId } = req.body;

        if (!req.files || req.files.length === 0) {
            return res.status(400).json({
                status: 'error',
                message: 'No files provided'
            });
        }

        if (!category || !DOCUMENT_CATEGORIES.includes(category)) {
            return res.status(400).json({
                status: 'error',
                message: `Invalid category. Must be one of: ${DOCUMENT_CATEGORIES.join(', ')}`
            });
        }

        // Validate files
        const validationErrors = [];
        for (const file of req.files) {
            const errors = validateFile(file);
            if (errors.length > 0) {
                validationErrors.push({
                    fileName: file.originalname,
                    errors: errors
                });
            }
        }

        if (validationErrors.length > 0) {
            return res.status(400).json({
                status: 'error',
                message: 'File validation failed',
                errors: validationErrors
            });
        }

        // Upload files to S3 and save metadata to database
        const uploadedFiles = [];
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            for (const file of req.files) {
                // Upload to S3
                const s3Result = await uploadToS3(file, category, userId, projectId);

                // Save file metadata to database
                const fileResult = await client.query(
                    `INSERT INTO application_documents 
                     (application_id, document_type, file_name, file_path, file_size, mime_type, uploaded_by)
                     VALUES ($1, $2, $3, $4, $5, $6, $7)
                     RETURNING *`,
                    [
                        applicationId,
                        category,
                        s3Result.fileName,
                        s3Result.key,
                        s3Result.size,
                        s3Result.mimeType,
                        userId
                    ]
                );

                const savedFile = fileResult.rows[0];
                uploadedFiles.push({
                    id: savedFile.id,
                    fileName: savedFile.file_name,
                    originalName: s3Result.originalName,
                    category: savedFile.document_type,
                    size: savedFile.file_size,
                    mimeType: savedFile.mime_type,
                    url: s3Result.url,
                    uploadedAt: savedFile.created_at
                });
            }

            await client.query('COMMIT');

            logger.info(`User ${userId} uploaded ${uploadedFiles.length} files for category ${category}`);

            res.status(201).json({
                status: 'success',
                message: `${uploadedFiles.length} file(s) uploaded successfully`,
                data: {
                    files: uploadedFiles,
                    category: category,
                    projectId: projectId,
                    applicationId: applicationId
                }
            });

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }

    } catch (error) {
        logger.error('File upload error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to upload files',
            error: error.message
        });
    }
});

// GET /api/v1/files/:id
router.get('/:id', async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;

        // Get file metadata
        const fileResult = await pool.query(
            `SELECT ad.*, a.user_id as application_user_id, p.name as project_name
             FROM application_documents ad
             LEFT JOIN applications a ON ad.application_id = a.id
             LEFT JOIN projects p ON a.project_id = p.id
             WHERE ad.id = $1`,
            [id]
        );

        if (fileResult.rows.length === 0) {
            return res.status(404).json({
                status: 'error',
                message: 'File not found'
            });
        }

        const file = fileResult.rows[0];

        // Check if user has access to this file
        if (file.application_user_id !== userId && req.user.user_type !== 'admin') {
            return res.status(403).json({
                status: 'error',
                message: 'Access denied'
            });
        }

        // Generate signed URL for file access
        const signedUrl = await generateSignedUrl(file.file_path, 3600); // 1 hour expiry

        res.json({
            status: 'success',
            data: {
                file: {
                    id: file.id,
                    fileName: file.file_name,
                    documentType: file.document_type,
                    size: file.file_size,
                    mimeType: file.mime_type,
                    projectName: file.project_name,
                    uploadedAt: file.created_at,
                    downloadUrl: signedUrl
                }
            }
        });

    } catch (error) {
        logger.error('File fetch error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to fetch file',
            error: error.message
        });
    }
});

// DELETE /api/v1/files/:id
router.delete('/:id', async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;

        // Get file metadata
        const fileResult = await pool.query(
            `SELECT ad.*, a.user_id as application_user_id
             FROM application_documents ad
             LEFT JOIN applications a ON ad.application_id = a.id
             WHERE ad.id = $1`,
            [id]
        );

        if (fileResult.rows.length === 0) {
            return res.status(404).json({
                status: 'error',
                message: 'File not found'
            });
        }

        const file = fileResult.rows[0];

        // Check if user has permission to delete this file
        if (file.application_user_id !== userId && req.user.user_type !== 'admin') {
            return res.status(403).json({
                status: 'error',
                message: 'Access denied'
            });
        }

        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            // Delete from S3
            await deleteFromS3(file.file_path);

            // Delete from database
            await client.query('DELETE FROM application_documents WHERE id = $1', [id]);

            await client.query('COMMIT');

            logger.info(`User ${userId} deleted file ${file.file_name}`);

            res.json({
                status: 'success',
                message: 'File deleted successfully'
            });

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }

    } catch (error) {
        logger.error('File deletion error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to delete file',
            error: error.message
        });
    }
});

// GET /api/v1/files/project/:projectId
router.get('/project/:projectId', async (req, res) => {
    try {
        const userId = req.user.id;
        const { projectId } = req.params;
        const { category, limit = 50, offset = 0 } = req.query;

        // Verify project ownership
        const projectResult = await pool.query(
            `SELECT p.*, po.user_id as owner_id
             FROM projects p
             LEFT JOIN project_ownership po ON p.id = po.project_id
             WHERE p.id = $1 AND po.user_id = $2`,
            [projectId, userId]
        );

        if (projectResult.rows.length === 0 && req.user.user_type !== 'admin') {
            return res.status(403).json({
                status: 'error',
                message: 'Access denied to project files'
            });
        }

        // Build query for files
        let query = `
            SELECT ad.*, a.status as application_status, p.name as project_name
            FROM application_documents ad
            INNER JOIN applications a ON ad.application_id = a.id
            INNER JOIN projects p ON a.project_id = p.id
            WHERE a.project_id = $1
        `;
        const params = [projectId];

        if (category) {
            query += ' AND ad.document_type = $2';
            params.push(category);
        }

        query += ' ORDER BY ad.created_at DESC LIMIT $' + (params.length + 1) + ' OFFSET $' + (params.length + 2);
        params.push(parseInt(limit), parseInt(offset));

        const filesResult = await pool.query(query, params);

        // Generate signed URLs for files
        const filesWithUrls = await Promise.all(
            filesResult.rows.map(async (file) => {
                try {
                    const signedUrl = await generateSignedUrl(file.file_path, 3600);
                    return {
                        id: file.id,
                        fileName: file.file_name,
                        documentType: file.document_type,
                        size: file.file_size,
                        mimeType: file.mime_type,
                        projectName: file.project_name,
                        applicationStatus: file.application_status,
                        uploadedAt: file.created_at,
                        downloadUrl: signedUrl
                    };
                } catch (error) {
                    logger.warn(`Failed to generate signed URL for file ${file.id}:`, error.message);
                    return {
                        id: file.id,
                        fileName: file.file_name,
                        documentType: file.document_type,
                        size: file.file_size,
                        mimeType: file.mime_type,
                        projectName: file.project_name,
                        applicationStatus: file.application_status,
                        uploadedAt: file.created_at,
                        downloadUrl: null,
                        error: 'Failed to generate download URL'
                    };
                }
            })
        );

        res.json({
            status: 'success',
            data: {
                files: filesWithUrls,
                projectId: projectId,
                category: category,
                pagination: {
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    total: filesWithUrls.length
                }
            }
        });

    } catch (error) {
        logger.error('Project files fetch error:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to fetch project files',
            error: error.message
        });
    }
});

// GET /api/v1/files/categories/list
router.get('/categories/list', (req, res) => {
    res.json({
        status: 'success',
        data: {
            categories: DOCUMENT_CATEGORIES.map(category => ({
                value: category,
                label: category.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
                description: getCategoryDescription(category)
            }))
        }
    });
});

// Helper function to get category descriptions
function getCategoryDescription(category) {
    const descriptions = {
        'team_photos': 'Photos of team members, founders, and key personnel',
        'financial_documents': 'Financial reports, audits, revenue statements, and financial projections',
        'legal_documents': 'Legal certificates, licenses, terms of service, and compliance documents',
        'technical_documents': 'Technical specifications, whitepapers, architecture diagrams, and code documentation',
        'marketing_materials': 'Logos, banners, presentations, and promotional materials'
    };
    return descriptions[category] || 'Document category';
}

module.exports = router;
