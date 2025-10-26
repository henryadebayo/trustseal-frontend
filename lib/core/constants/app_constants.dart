import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'TrustSeal';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'The Verification Layer for BlockDAG';

  // Colors
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF3B82F6);
  static const Color accentColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);

  // Verification Status Colors
  static const Color verifiedColor = Color(0xFF10B981);
  static const Color ongoingColor = Color(0xFFF59E0B);
  static const Color unverifiedColor = Color(0xFFEF4444);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1E293B);
  static const Color textSecondaryColor = Color(0xFF64748B);
  static const Color textTertiaryColor = Color(0xFF94A3B8);

  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  // Font Sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;

  // Icon Sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;

  // Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // API Endpoints
  static const String baseUrl = 'https://api.trustseal.io';
  static const String projectsEndpoint = '/projects';
  static const String analyticsEndpoint = '/analytics';
  static const String verificationEndpoint = '/verification';

  // Social Media Links
  static const String twitterUrl = 'https://twitter.com/trustseal';
  static const String telegramUrl = 'https://t.me/trustseal';
  static const String discordUrl = 'https://discord.gg/trustseal';
  static const String githubUrl = 'https://github.com/trustseal';

  // Verification Requirements
  static const int minLiquidityLockMonths = 6;
  static const double minTrustScore = 7.0;
  static const int maxTeamAllocation = 20; // percentage

  // Content Creator Requirements
  static const int minFollowersForCreator = 1000;
  static const double minEngagementRate = 2.0; // percentage
  static const int minContentQualityScore = 70;

  // Promotion Pool
  static const double minPromotionPoolPercentage = 2.0;
  static const double maxPromotionPoolPercentage = 5.0;

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String walletNotConnectedMessage =
      'Please connect your wallet to continue.';
  static const String insufficientFundsMessage =
      'Insufficient funds for this transaction.';

  // Success Messages
  static const String walletConnectedMessage = 'Wallet connected successfully!';
  static const String transactionSuccessMessage =
      'Transaction completed successfully!';
  static const String projectVerifiedMessage =
      'Project verification completed!';

  // Verification Status Icons
  static const String verifiedIcon = '✅';
  static const String ongoingIcon = '🟡';
  static const String unverifiedIcon = '⚠️';

  // Feature Flags
  static const bool enableWalletConnection = true;
  static const bool enableAnalytics = true;
  static const bool enableContentCreatorMode = true;
  static const bool enableProjectSubmission = false; // Coming soon
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: AppConstants.fontSizeXXXL,
    fontWeight: FontWeight.bold,
    color: AppConstants.textPrimaryColor,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: AppConstants.fontSizeXXL,
    fontWeight: FontWeight.bold,
    color: AppConstants.textPrimaryColor,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: AppConstants.fontSizeXL,
    fontWeight: FontWeight.w600,
    color: AppConstants.textPrimaryColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppConstants.fontSizeL,
    fontWeight: FontWeight.normal,
    color: AppConstants.textPrimaryColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppConstants.fontSizeM,
    fontWeight: FontWeight.normal,
    color: AppConstants.textPrimaryColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: AppConstants.fontSizeS,
    fontWeight: FontWeight.normal,
    color: AppConstants.textSecondaryColor,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppConstants.fontSizeXS,
    fontWeight: FontWeight.normal,
    color: AppConstants.textTertiaryColor,
  );

  static const TextStyle button = TextStyle(
    fontSize: AppConstants.fontSizeM,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle link = TextStyle(
    fontSize: AppConstants.fontSizeM,
    fontWeight: FontWeight.w500,
    color: AppConstants.primaryColor,
    decoration: TextDecoration.underline,
  );
}
