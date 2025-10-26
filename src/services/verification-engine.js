const pool = require('../config/database');
const logger = require('../config/logger');

class VerificationEngine {
    constructor() {
        this.weights = {
            team: 0.25,
            technical: 0.30,
            financial: 0.25,
            community: 0.20
        };
    }

    async calculateTrustScore(projectId) {
        try {
            // Get project data
            const projectResult = await pool.query(
                'SELECT * FROM projects WHERE id = $1',
                [projectId]
            );

            if (projectResult.rows.length === 0) {
                throw new Error('Project not found');
            }

            const project = projectResult.rows[0];

            // Calculate individual scores
            const teamScore = await this.calculateTeamScore(projectId);
            const technicalScore = await this.calculateTechnicalScore(projectId);
            const financialScore = await this.calculateFinancialScore(projectId);
            const communityScore = await this.calculateCommunityScore(projectId);

            // Calculate weighted overall score
            const overallScore =
                (teamScore * this.weights.team) +
                (technicalScore * this.weights.technical) +
                (financialScore * this.weights.financial) +
                (communityScore * this.weights.community);

            // Apply risk adjustments
            const riskAdjustedScore = await this.applyRiskAdjustments(
                overallScore,
                project
            );

            // Update verification criteria
            await pool.query(
                `INSERT INTO verification_criteria 
         (project_id, team_verification_score, technical_verification_score, 
          financial_verification_score, community_verification_score, overall_score)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (project_id) DO UPDATE SET
         team_verification_score = $2,
         technical_verification_score = $3,
         financial_verification_score = $4,
         community_verification_score = $5,
         overall_score = $6,
         updated_at = NOW()`,
                [projectId, teamScore, technicalScore, financialScore,
                    communityScore, riskAdjustedScore]
            );

            // Update project trust score
            await pool.query(
                'UPDATE projects SET trust_score = $1 WHERE id = $2',
                [riskAdjustedScore, projectId]
            );

            return {
                overallScore: riskAdjustedScore,
                breakdown: {
                    team: teamScore,
                    technical: technicalScore,
                    financial: financialScore,
                    community: communityScore
                }
            };
        } catch (error) {
            logger.error('Error calculating trust score:', error);
            throw error;
        }
    }

    async calculateTeamScore(projectId) {
        let score = 0;

        // Get team verification checks
        const checksResult = await pool.query(
            `SELECT * FROM verification_checks 
       WHERE project_id = $1 AND check_type LIKE 'team_%'`,
            [projectId]
        );

        const checks = checksResult.rows;

        // Team doxxing (40% of team score)
        const doxxedCheck = checks.find(c => c.check_name === 'team_doxxed');
        if (doxxedCheck && doxxedCheck.status === 'passed') score += 4.0;

        // LinkedIn verification (20% of team score)
        const linkedinCheck = checks.find(c => c.check_name === 'linkedin_verified');
        if (linkedinCheck && linkedinCheck.status === 'passed') score += 2.0;

        // Background checks (20% of team score)
        const bgCheck = checks.find(c => c.check_name === 'background_check');
        if (bgCheck && bgCheck.status === 'passed') score += 2.0;

        // Team size (10% of team score)
        const sizeCheck = checks.find(c => c.check_name === 'team_size');
        if (sizeCheck && sizeCheck.details?.size >= 3) score += 1.0;

        // Technical leadership (10% of team score)
        const leadCheck = checks.find(c => c.check_name === 'technical_leadership');
        if (leadCheck && leadCheck.status === 'passed') score += 1.0;

        return Math.min(score, 10.0);
    }

    async calculateTechnicalScore(projectId) {
        let score = 0;

        const checksResult = await pool.query(
            `SELECT * FROM verification_checks 
       WHERE project_id = $1 AND check_type LIKE 'technical_%'`,
            [projectId]
        );

        const checks = checksResult.rows;

        // Smart contract audit (50% of technical score)
        const auditCheck = checks.find(c => c.check_name === 'smart_contract_audit');
        if (auditCheck && auditCheck.status === 'passed') {
            score += 5.0;
            // Bonus for reputable auditors
            if (auditCheck.details?.isReputableAuditor) score += 1.0;
        }

        // Code quality (20% of technical score)
        const codeCheck = checks.find(c => c.check_name === 'code_quality');
        if (codeCheck && codeCheck.score) score += (codeCheck.score / 5) * 2.0;

        // Documentation (15% of technical score)
        const docCheck = checks.find(c => c.check_name === 'documentation');
        if (docCheck && docCheck.status === 'passed') score += 1.5;

        // Security scan (15% of technical score)
        const securityCheck = checks.find(c => c.check_name === 'security_scan');
        if (securityCheck && securityCheck.score) score += (securityCheck.score / 10) * 1.5;

        return Math.min(score, 10.0);
    }

    async calculateFinancialScore(projectId) {
        let score = 0;

        const checksResult = await pool.query(
            `SELECT * FROM verification_checks 
       WHERE project_id = $1 AND check_type LIKE 'financial_%'`,
            [projectId]
        );

        const checks = checksResult.rows;

        // Financial audit (40% of financial score)
        const auditCheck = checks.find(c => c.check_name === 'financial_audit');
        if (auditCheck && auditCheck.status === 'passed') score += 4.0;

        // Liquidity lock (30% of financial score)
        const liquidityCheck = checks.find(c => c.check_name === 'liquidity_lock');
        if (liquidityCheck && liquidityCheck.status === 'passed') {
            const lockDuration = liquidityCheck.details?.duration || 0;
            if (lockDuration >= 12) score += 3.0;
            else if (lockDuration >= 6) score += 2.0;
            else score += 1.0;
        }

        // Funding transparency (30% of financial score)
        const fundingCheck = checks.find(c => c.check_name === 'funding_transparency');
        if (fundingCheck && fundingCheck.status === 'passed') score += 3.0;

        return Math.min(score, 10.0);
    }

    async calculateCommunityScore(projectId) {
        let score = 0;

        const checksResult = await pool.query(
            `SELECT * FROM verification_checks 
       WHERE project_id = $1 AND check_type LIKE 'community_%'`,
            [projectId]
        );

        const checks = checksResult.rows;

        // Social media presence (40% of community score)
        const socialCheck = checks.find(c => c.check_name === 'social_media');
        if (socialCheck && socialCheck.details?.platformsCount >= 3) {
            score += 2.0;
            if (socialCheck.details?.totalFollowers >= 10000) score += 2.0;
        }

        // Community engagement (30% of community score)
        const engagementCheck = checks.find(c => c.check_name === 'community_engagement');
        if (engagementCheck && engagementCheck.score) {
            score += (engagementCheck.score / 10) * 3.0;
        }

        // Community size (30% of community score)
        const sizeCheck = checks.find(c => c.check_name === 'community_size');
        if (sizeCheck && sizeCheck.details?.members >= 1000) {
            score += 3.0;
        } else if (sizeCheck && sizeCheck.details?.members >= 500) {
            score += 2.0;
        } else if (sizeCheck && sizeCheck.details?.members >= 100) {
            score += 1.0;
        }

        return Math.min(score, 10.0);
    }

    async applyRiskAdjustments(score, project) {
        let adjustedScore = score;

        // Get risk level
        const riskLevel = await this.assessRiskLevel(project.id);

        // Apply risk multipliers
        if (riskLevel === 'high') {
            adjustedScore *= 0.7; // Reduce score by 30%
        } else if (riskLevel === 'medium') {
            adjustedScore *= 0.85; // Reduce score by 15%
        }

        return Math.min(adjustedScore, 10.0);
    }

    async assessRiskLevel(projectId) {
        const checksResult = await pool.query(
            'SELECT * FROM verification_checks WHERE project_id = $1',
            [projectId]
        );

        let riskScore = 0;

        const checks = checksResult.rows;

        // Red flags (high risk)
        const doxxedCheck = checks.find(c => c.check_name === 'team_doxxed');
        if (!doxxedCheck || doxxedCheck.status !== 'passed') riskScore += 3;

        const auditCheck = checks.find(c => c.check_name === 'smart_contract_audit');
        if (!auditCheck || auditCheck.status !== 'passed') riskScore += 3;

        const liquidityCheck = checks.find(c => c.check_name === 'liquidity_lock');
        const liquidityDuration = liquidityCheck?.details?.duration || 0;
        if (liquidityDuration < 6) riskScore += 2;

        // Yellow flags (medium risk)
        const sizeCheck = checks.find(c => c.check_name === 'team_size');
        if (sizeCheck && sizeCheck.details?.size < 3) riskScore += 1;

        const socialCheck = checks.find(c => c.check_name === 'social_media');
        if (!socialCheck || socialCheck.details?.platformsCount === 0) riskScore += 1;

        // Map score to risk level
        if (riskScore >= 5) return 'high';
        if (riskScore >= 2) return 'medium';
        return 'low';
    }

    async determineVerificationTier(overallScore) {
        if (overallScore >= 8.5) return 'gold';
        if (overallScore >= 7.0) return 'silver';
        if (overallScore >= 5.0) return 'bronze';
        if (overallScore >= 3.0) return 'basic';
        return 'pending';
    }
}

module.exports = new VerificationEngine();
