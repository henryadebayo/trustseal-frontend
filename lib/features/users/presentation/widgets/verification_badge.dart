import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/project_entity/project_entity.dart';

class VerificationBadge extends StatelessWidget {
  final VerificationStatus status;
  final bool showDescription;
  final double size;
  final VoidCallback? onTap;

  const VerificationBadge({
    super.key,
    required this.status,
    this.showDescription = false,
    this.size = 24.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingS,
          vertical: AppConstants.paddingXS,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: _getBorderColor(), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getIcon(), size: size, color: _getIconColor()),
            if (showDescription) ...[
              SizedBox(width: AppConstants.paddingXS),
              Text(
                status.displayName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _getTextColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppConstants.verifiedColor.withOpacity(0.1);
      case VerificationStatus.ongoing:
        return AppConstants.ongoingColor.withOpacity(0.1);
      case VerificationStatus.unverified:
        return AppConstants.unverifiedColor.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppConstants.verifiedColor;
      case VerificationStatus.ongoing:
        return AppConstants.ongoingColor;
      case VerificationStatus.unverified:
        return AppConstants.unverifiedColor;
    }
  }

  Color _getIconColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppConstants.verifiedColor;
      case VerificationStatus.ongoing:
        return AppConstants.ongoingColor;
      case VerificationStatus.unverified:
        return AppConstants.unverifiedColor;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppConstants.verifiedColor;
      case VerificationStatus.ongoing:
        return AppConstants.ongoingColor;
      case VerificationStatus.unverified:
        return AppConstants.unverifiedColor;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case VerificationStatus.verified:
        return Icons.verified;
      case VerificationStatus.ongoing:
        return Icons.hourglass_empty;
      case VerificationStatus.unverified:
        return Icons.warning;
    }
  }
}

class VerificationStatusCard extends StatelessWidget {
  final VerificationStatus status;
  final String? customDescription;

  const VerificationStatusCard({
    super.key,
    required this.status,
    this.customDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: _getBorderColor(), width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIcon(),
                size: AppConstants.iconSizeL,
                color: _getIconColor(),
              ),
              SizedBox(width: AppConstants.paddingS),
              Text(
                status.displayName,
                style: AppTextStyles.heading3.copyWith(color: _getTextColor()),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingS),
          Text(
            customDescription ?? status.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: _getTextColor().withOpacity(0.8),
            ),
          ),
          if (status == VerificationStatus.verified) ...[
            SizedBox(height: AppConstants.paddingM),
            _buildVerifiedFeatures(),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifiedFeatures() {
    final features = [
      'Passed all audit checks',
      'Liquidity locked for 6+ months',
      'Team fully doxxed',
      'Regular progress updates',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppConstants.paddingXS),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: AppConstants.iconSizeS,
                color: AppConstants.verifiedColor,
              ),
              SizedBox(width: AppConstants.paddingXS),
              Expanded(
                child: Text(
                  feature,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getTextColor().withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppConstants.verifiedColor.withOpacity(0.05);
      case VerificationStatus.ongoing:
        return AppConstants.ongoingColor.withOpacity(0.05);
      case VerificationStatus.unverified:
        return AppConstants.unverifiedColor.withOpacity(0.05);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppConstants.verifiedColor;
      case VerificationStatus.ongoing:
        return AppConstants.ongoingColor;
      case VerificationStatus.unverified:
        return AppConstants.unverifiedColor;
    }
  }

  Color _getIconColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppConstants.verifiedColor;
      case VerificationStatus.ongoing:
        return AppConstants.ongoingColor;
      case VerificationStatus.unverified:
        return AppConstants.unverifiedColor;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppConstants.verifiedColor;
      case VerificationStatus.ongoing:
        return AppConstants.ongoingColor;
      case VerificationStatus.unverified:
        return AppConstants.unverifiedColor;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case VerificationStatus.verified:
        return Icons.verified;
      case VerificationStatus.ongoing:
        return Icons.hourglass_empty;
      case VerificationStatus.unverified:
        return Icons.warning;
    }
  }
}
