import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/project_entity/project_entity.dart';
import 'verification_badge.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final bool showMetrics;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.showMetrics = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: AppConstants.paddingM),
              _buildDescription(),
              SizedBox(height: AppConstants.paddingM),
              if (showMetrics) ...[
                _buildMetrics(),
                SizedBox(height: AppConstants.paddingM),
              ],
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppConstants.surfaceColor,
          backgroundImage: project.logoUrl.isNotEmpty
              ? NetworkImage(project.logoUrl)
              : null,
          child: project.logoUrl.isEmpty
              ? Icon(Icons.business, color: AppConstants.textSecondaryColor)
              : null,
        ),
        SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: AppTextStyles.heading3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppConstants.paddingXS),
              VerificationBadge(
                status: project.verificationStatus,
                showDescription: true,
              ),
            ],
          ),
        ),
        _buildTrustScore(),
      ],
    );
  }

  Widget _buildTrustScore() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingS,
        vertical: AppConstants.paddingXS,
      ),
      decoration: BoxDecoration(
        color: _getTrustScoreColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: _getTrustScoreColor(), width: 1.0),
      ),
      child: Text(
        '${project.metrics.trustScore.toStringAsFixed(1)}/10',
        style: AppTextStyles.bodySmall.copyWith(
          color: _getTrustScoreColor(),
          fontWeight: FontWeight.w600,
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

  Widget _buildDescription() {
    return Text(
      project.description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppConstants.textSecondaryColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetrics() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Market Cap',
                  _formatCurrency(project.metrics.marketCap),
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Liquidity',
                  _formatCurrency(project.metrics.liquidity),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingS),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Holders',
                  _formatNumber(project.metrics.holders),
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  '24h Change',
                  '${project.metrics.priceChange24h >= 0 ? '+' : ''}${project.metrics.priceChange24h.toStringAsFixed(2)}%',
                  color: project.metrics.priceChange24h >= 0
                      ? AppConstants.successColor
                      : AppConstants.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        SizedBox(height: AppConstants.paddingXS),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (project.website.isNotEmpty)
          _buildSocialButton(
            icon: Icons.language,
            onTap: () => _launchUrl(project.website),
          ),
        if (project.twitter.isNotEmpty) ...[
          SizedBox(width: AppConstants.paddingS),
          _buildSocialButton(
            icon: Icons.alternate_email,
            onTap: () => _launchUrl(project.twitter),
          ),
        ],
        if (project.telegram.isNotEmpty) ...[
          SizedBox(width: AppConstants.paddingS),
          _buildSocialButton(
            icon: Icons.telegram,
            onTap: () => _launchUrl(project.telegram),
          ),
        ],
        const Spacer(),
        Text(
          'Updated ${_formatDate(project.updatedAt)}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: EdgeInsets.all(AppConstants.paddingS),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Icon(
          icon,
          size: AppConstants.iconSizeS,
          color: AppConstants.textSecondaryColor,
        ),
      ),
    );
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  void _launchUrl(String url) {
    // TODO: Implement URL launching
    print('Launching URL: $url');
  }
}

class ProjectCardCompact extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCardCompact({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppConstants.surfaceColor,
                backgroundImage: project.logoUrl.isNotEmpty
                    ? NetworkImage(project.logoUrl)
                    : null,
                child: project.logoUrl.isEmpty
                    ? Icon(
                        Icons.business,
                        color: AppConstants.textSecondaryColor,
                        size: AppConstants.iconSizeM,
                      )
                    : null,
              ),
              SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppConstants.paddingXS),
                    VerificationBadge(status: project.verificationStatus),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${(project.metrics.marketCap / 1000000).toStringAsFixed(1)}M',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppConstants.paddingXS),
                  Text(
                    '${project.metrics.trustScore.toStringAsFixed(1)}/10',
                    style: AppTextStyles.caption.copyWith(
                      color: _getTrustScoreColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
}
