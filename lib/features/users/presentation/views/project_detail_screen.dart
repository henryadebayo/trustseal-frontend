import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/project_entity/project_entity.dart';
import '../widgets/verification_badge.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProjectHeader(),
            _buildVerificationStatus(),
            _buildProjectMetrics(),
            _buildAuditInformation(),
            _buildTokenomics(),
            _buildSocialLinks(),
            SizedBox(height: AppConstants.paddingXL),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        project.name,
        style: AppTextStyles.heading3.copyWith(color: Colors.white),
      ),
      backgroundColor: AppConstants.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareProject(context),
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.white),
          onPressed: () => _bookmarkProject(context),
        ),
      ],
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingL),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppConstants.surfaceColor,
                backgroundImage: project.logoUrl.isNotEmpty
                    ? NetworkImage(project.logoUrl)
                    : null,
                child: project.logoUrl.isEmpty
                    ? Icon(
                        Icons.business,
                        color: AppConstants.textSecondaryColor,
                        size: AppConstants.iconSizeXL,
                      )
                    : null,
              ),
              SizedBox(width: AppConstants.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name, style: AppTextStyles.heading1),
                    SizedBox(height: AppConstants.paddingS),
                    Text(
                      project.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: AppConstants.paddingM),
                    VerificationBadge(
                      status: project.verificationStatus,
                      showDescription: true,
                      size: AppConstants.iconSizeM,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingL),
          _buildTrustScoreCard(),
        ],
      ),
    );
  }

  Widget _buildTrustScoreCard() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTrustScoreColor().withOpacity(0.1),
            _getTrustScoreColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: _getTrustScoreColor().withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trust Score',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              SizedBox(height: AppConstants.paddingXS),
              Text(
                '${project.metrics.trustScore.toStringAsFixed(1)}/10',
                style: AppTextStyles.heading2.copyWith(
                  color: _getTrustScoreColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _buildTrustScoreIndicator(),
        ],
      ),
    );
  }

  Widget _buildTrustScoreIndicator() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: project.metrics.trustScore / 10,
            strokeWidth: 8,
            backgroundColor: AppConstants.surfaceColor,
            valueColor: AlwaysStoppedAnimation<Color>(_getTrustScoreColor()),
          ),
          Center(
            child: Icon(
              _getTrustScoreIcon(),
              size: AppConstants.iconSizeL,
              color: _getTrustScoreColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus() {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingM),
      child: VerificationStatusCard(status: project.verificationStatus),
    );
  }

  Widget _buildProjectMetrics() {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingM),
      padding: EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Project Metrics', style: AppTextStyles.heading3),
          SizedBox(height: AppConstants.paddingL),
          _buildMetricsGrid(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Market Cap',
                _formatCurrency(project.metrics.marketCap),
                Icons.trending_up,
                AppConstants.primaryColor,
              ),
            ),
            SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: _buildMetricItem(
                'Liquidity',
                _formatCurrency(project.metrics.liquidity),
                Icons.water_drop,
                AppConstants.secondaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Holders',
                _formatNumber(project.metrics.holders),
                Icons.people,
                AppConstants.accentColor,
              ),
            ),
            SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: _buildMetricItem(
                '24h Change',
                '${project.metrics.priceChange24h >= 0 ? '+' : ''}${project.metrics.priceChange24h.toStringAsFixed(2)}%',
                project.metrics.priceChange24h >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                project.metrics.priceChange24h >= 0
                    ? AppConstants.successColor
                    : AppConstants.errorColor,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                'Volume 24h',
                _formatCurrency(project.metrics.volume24h),
                Icons.bar_chart,
                AppConstants.warningColor,
              ),
            ),
            SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: _buildMetricItem(
                'Created',
                _formatDate(project.createdAt),
                Icons.calendar_today,
                AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: color.withOpacity(0.2), width: 1.0),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppConstants.iconSizeM),
          SizedBox(height: AppConstants.paddingS),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: AppConstants.paddingXS),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuditInformation() {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingM),
      padding: EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Audit Information', style: AppTextStyles.heading3),
          SizedBox(height: AppConstants.paddingL),
          _buildAuditItem(
            'Team Verification',
            project.auditInfo.teamVerified,
            'Team members have been verified and doxxed',
          ),
          _buildAuditItem(
            'Smart Contract Audit',
            project.auditInfo.smartContractAudited,
            'Code has been audited for security vulnerabilities',
          ),
          _buildAuditItem(
            'Liquidity Locked',
            project.auditInfo.liquidityLocked,
            'Liquidity is locked for at least 6 months',
          ),
          _buildAuditItem(
            'Tokenomics Verified',
            project.auditInfo.tokenomicsVerified,
            'Token distribution and vesting schedules verified',
          ),
          if (project.auditInfo.auditReportUrl.isNotEmpty) ...[
            SizedBox(height: AppConstants.paddingM),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openAuditReport(),
                icon: const Icon(Icons.description),
                label: const Text('View Audit Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditItem(String title, bool isVerified, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.cancel,
            color: isVerified
                ? AppConstants.successColor
                : AppConstants.errorColor,
            size: AppConstants.iconSizeM,
          ),
          SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenomics() {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingM),
      padding: EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tokenomics', style: AppTextStyles.heading3),
          SizedBox(height: AppConstants.paddingL),
          _buildTokenomicsItem(
            'Total Supply',
            _formatNumber(project.tokenomics.totalSupply),
          ),
          _buildTokenomicsItem(
            'Circulating Supply',
            _formatNumber(project.tokenomics.circulatingSupply),
          ),
          _buildTokenomicsItem(
            'Contract Address',
            '${project.tokenomics.contractAddress.substring(0, 6)}...${project.tokenomics.contractAddress.substring(project.tokenomics.contractAddress.length - 4)}',
          ),
          SizedBox(height: AppConstants.paddingM),
          Text(
            'Token Distribution',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppConstants.paddingS),
          ...project.tokenomics.distribution.entries.map(
            (entry) => _buildDistributionItem(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenomicsItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionItem(String category, int percentage) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: AppTextStyles.bodyMedium),
              Text(
                '$percentage%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingXS),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppConstants.surfaceColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Container(
      margin: EdgeInsets.all(AppConstants.paddingM),
      padding: EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Social Links', style: AppTextStyles.heading3),
          SizedBox(height: AppConstants.paddingL),
          Row(
            children: [
              if (project.website.isNotEmpty)
                _buildSocialButton(
                  'Website',
                  Icons.language,
                  AppConstants.primaryColor,
                  () => _openUrl(project.website),
                ),
              if (project.twitter.isNotEmpty) ...[
                SizedBox(width: AppConstants.paddingM),
                _buildSocialButton(
                  'Twitter',
                  Icons.alternate_email,
                  const Color(0xFF1DA1F2),
                  () => _openUrl(project.twitter),
                ),
              ],
              if (project.telegram.isNotEmpty) ...[
                SizedBox(width: AppConstants.paddingM),
                _buildSocialButton(
                  'Telegram',
                  Icons.telegram,
                  const Color(0xFF0088CC),
                  () => _openUrl(project.telegram),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: AppConstants.paddingM),
        ),
      ),
    );
  }

  Color _getTrustScoreColor() {
    if (project.metrics.trustScore >= 8.0) {
      return AppConstants.verifiedColor;
    } else if (project.metrics.trustScore >= 6.0) {
      return AppConstants.ongoingColor;
    } else {
      return AppConstants.unverifiedColor;
    }
  }

  IconData _getTrustScoreIcon() {
    if (project.metrics.trustScore >= 8.0) {
      return Icons.verified;
    } else if (project.metrics.trustScore >= 6.0) {
      return Icons.hourglass_empty;
    } else {
      return Icons.warning;
    }
  }

  String _formatCurrency(int value) {
    if (value >= 1000000000) {
      return '\$${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$$value';
    }
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toString();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareProject(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _bookmarkProject(BuildContext context) {
    // TODO: Implement bookmarking functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark functionality coming soon!')),
    );
  }

  void _openAuditReport() {
    // TODO: Implement opening audit report
    print('Opening audit report: ${project.auditInfo.auditReportUrl}');
  }

  void _openUrl(String url) {
    // TODO: Implement opening URLs
    print('Opening URL: $url');
  }
}
