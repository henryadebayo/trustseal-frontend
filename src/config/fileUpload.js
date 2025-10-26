const multer = require('multer');
const AWS = require('aws-sdk');
const sharp = require('sharp');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const fs = require('fs').promises;

// AWS S3 Configuration
const s3 = new AWS.S3({
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    region: process.env.AWS_REGION || 'us-east-1'
});

const S3_BUCKET = process.env.AWS_S3_BUCKET || 'trustseal-documents';

// File type validation
const ALLOWED_FILE_TYPES = {
    'image/jpeg': '.jpg',
    'image/png': '.png',
    'image/gif': '.gif',
    'image/webp': '.webp',
    'application/pdf': '.pdf',
    'application/msword': '.doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
    'application/vnd.ms-excel': '.xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
    'text/csv': '.csv',
    'text/plain': '.txt'
};

// File size limits (in bytes)
const FILE_SIZE_LIMITS = {
    'image/jpeg': 10 * 1024 * 1024, // 10MB
    'image/png': 10 * 1024 * 1024,   // 10MB
    'image/gif': 10 * 1024 * 1024,  // 10MB
    'image/webp': 10 * 1024 * 1024, // 10MB
    'application/pdf': 50 * 1024 * 1024, // 50MB
    'application/msword': 25 * 1024 * 1024, // 25MB
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 25 * 1024 * 1024, // 25MB
    'application/vnd.ms-excel': 25 * 1024 * 1024, // 25MB
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 25 * 1024 * 1024, // 25MB
    'text/csv': 25 * 1024 * 1024, // 25MB
    'text/plain': 5 * 1024 * 1024 // 5MB
};

// Document categories
const DOCUMENT_CATEGORIES = [
    'team_photos',
    'financial_documents',
    'legal_documents',
    'technical_documents',
    'marketing_materials'
];

// Multer configuration for memory storage
const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
    if (ALLOWED_FILE_TYPES[file.mimetype]) {
        cb(null, true);
    } else {
        cb(new Error(`File type ${file.mimetype} is not allowed`), false);
    }
};

const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 50 * 1024 * 1024, // 50MB max file size
        files: 10 // Max 10 files per request
    }
});

// Upload file to S3 (with local fallback for testing)
const uploadToS3 = async (file, category, userId, projectId = null) => {
    try {
        const fileExtension = ALLOWED_FILE_TYPES[file.mimetype];
        const fileName = `${uuidv4()}${fileExtension}`;
        const key = `documents/${userId}/${category}/${fileName}`;

        // Process image files with Sharp
        let processedBuffer = file.buffer;
        if (file.mimetype.startsWith('image/')) {
            processedBuffer = await sharp(file.buffer)
                .resize(1920, 1080, {
                    fit: 'inside',
                    withoutEnlargement: true
                })
                .jpeg({ quality: 85 })
                .toBuffer();
        }

        // Check if AWS credentials are configured
        if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_ACCESS_KEY_ID !== 'your-aws-access-key-id') {
            const uploadParams = {
                Bucket: S3_BUCKET,
                Key: key,
                Body: processedBuffer,
                ContentType: file.mimetype,
                Metadata: {
                    'original-name': file.originalname,
                    'user-id': userId,
                    'category': category,
                    'project-id': projectId || 'none',
                    'upload-date': new Date().toISOString()
                }
            };

            const result = await s3.upload(uploadParams).promise();

            return {
                key: key,
                url: result.Location,
                fileName: fileName,
                originalName: file.originalname,
                size: processedBuffer.length,
                mimeType: file.mimetype
            };
        } else {
            // Local fallback for testing
            const uploadDir = path.join(__dirname, '../../uploads');
            await fs.mkdir(uploadDir, { recursive: true });

            const filePath = path.join(uploadDir, fileName);
            await fs.writeFile(filePath, processedBuffer);

            return {
                key: key,
                url: `/uploads/${fileName}`,
                fileName: fileName,
                originalName: file.originalname,
                size: processedBuffer.length,
                mimeType: file.mimetype
            };
        }
    } catch (error) {
        throw new Error(`File upload failed: ${error.message}`);
    }
};

// Generate signed URL for file access (with local fallback)
const generateSignedUrl = async (key, expiresIn = 3600) => {
    try {
        // Check if AWS credentials are configured
        if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_ACCESS_KEY_ID !== 'your-aws-access-key-id') {
            const params = {
                Bucket: S3_BUCKET,
                Key: key,
                Expires: expiresIn
            };

            return await s3.getSignedUrlPromise('getObject', params);
        } else {
            // Local fallback - return direct file path
            return `/uploads/${path.basename(key)}`;
        }
    } catch (error) {
        throw new Error(`Signed URL generation failed: ${error.message}`);
    }
};

// Delete file from S3
const deleteFromS3 = async (key) => {
    try {
        const params = {
            Bucket: S3_BUCKET,
            Key: key
        };

        await s3.deleteObject(params).promise();
        return true;
    } catch (error) {
        throw new Error(`S3 delete failed: ${error.message}`);
    }
};

// Validate file
const validateFile = (file) => {
    const errors = [];

    // Check file type
    if (!ALLOWED_FILE_TYPES[file.mimetype]) {
        errors.push(`File type ${file.mimetype} is not allowed`);
    }

    // Check file size
    const maxSize = FILE_SIZE_LIMITS[file.mimetype];
    if (file.size > maxSize) {
        errors.push(`File size ${(file.size / 1024 / 1024).toFixed(2)}MB exceeds limit of ${(maxSize / 1024 / 1024).toFixed(2)}MB`);
    }

    // Check file name
    if (!file.originalname || file.originalname.length > 255) {
        errors.push('Invalid file name');
    }

    return errors;
};

module.exports = {
    upload,
    uploadToS3,
    generateSignedUrl,
    deleteFromS3,
    validateFile,
    ALLOWED_FILE_TYPES,
    FILE_SIZE_LIMITS,
    DOCUMENT_CATEGORIES,
    S3_BUCKET
};
