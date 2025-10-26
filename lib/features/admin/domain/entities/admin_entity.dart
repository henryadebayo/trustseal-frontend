// Admin domain entities

/// Admin user entity
class Admin {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;

  const Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
  });
}

/// Admin roles enum
enum AdminRole { superAdmin, reviewer, auditor, support }

/// Application review entity
class ApplicationReview {
  final String id;
  final String applicationId;
  final String adminId;
  final ReviewStatus status;
  final DateTime reviewedAt;
  final String? reviewNotes;
  final Map<String, bool> checklistResults;
  final List<String> requiredChanges;
  final int verificationScore;
  final DateTime? nextReviewDate;

  const ApplicationReview({
    required this.id,
    required this.applicationId,
    required this.adminId,
    required this.status,
    required this.reviewedAt,
    this.reviewNotes,
    required this.checklistResults,
    required this.requiredChanges,
    required this.verificationScore,
    this.nextReviewDate,
  });
}

/// Review status enum
enum ReviewStatus {
  pending,
  inProgress,
  approved,
  rejected,
  requiresChanges,
  needsMoreInfo,
}

/// Verification checklist result
class VerificationChecklistResult {
  final String category;
  final bool isComplete;
  final String? notes;
  final DateTime checkedAt;
  final String checkedBy;

  const VerificationChecklistResult({
    required this.category,
    required this.isComplete,
    this.notes,
    required this.checkedAt,
    required this.checkedBy,
  });
}

/// Admin dashboard statistics
class AdminDashboardStats {
  final int totalApplications;
  final int pendingReviews;
  final int approvedThisWeek;
  final int rejectedThisWeek;
  final int averageReviewTime;
  final Map<String, int> applicationsByStatus;
  final Map<String, int> reviewsByAdmin;

  const AdminDashboardStats({
    required this.totalApplications,
    required this.pendingReviews,
    required this.approvedThisWeek,
    required this.rejectedThisWeek,
    required this.averageReviewTime,
    required this.applicationsByStatus,
    required this.reviewsByAdmin,
  });
}

/// Audit log entry
class AuditLogEntry {
  final String id;
  final String adminId;
  final String action;
  final String targetType;
  final String targetId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String ipAddress;

  const AuditLogEntry({
    required this.id,
    required this.adminId,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.metadata,
    required this.timestamp,
    required this.ipAddress,
  });
}
