import '../../domain/entities/admin_entity.dart';

/// Admin data model
class AdminModel {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: AdminRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => AdminRole.reviewer,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Admin toEntity() {
    return Admin(
      id: id,
      name: name,
      email: email,
      role: role,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      isActive: isActive,
    );
  }

  factory AdminModel.fromEntity(Admin entity) {
    return AdminModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      isActive: entity.isActive,
    );
  }

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    AdminRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Application review data model
class ApplicationReviewModel {
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

  const ApplicationReviewModel({
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

  factory ApplicationReviewModel.fromJson(Map<String, dynamic> json) {
    return ApplicationReviewModel(
      id: json['id'],
      applicationId: json['applicationId'],
      adminId: json['adminId'],
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReviewStatus.pending,
      ),
      reviewedAt: DateTime.parse(json['reviewedAt']),
      reviewNotes: json['reviewNotes'],
      checklistResults: Map<String, bool>.from(json['checklistResults'] ?? {}),
      requiredChanges: List<String>.from(json['requiredChanges'] ?? []),
      verificationScore: json['verificationScore'] ?? 0,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'adminId': adminId,
      'status': status.name,
      'reviewedAt': reviewedAt.toIso8601String(),
      'reviewNotes': reviewNotes,
      'checklistResults': checklistResults,
      'requiredChanges': requiredChanges,
      'verificationScore': verificationScore,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
    };
  }

  ApplicationReview toEntity() {
    return ApplicationReview(
      id: id,
      applicationId: applicationId,
      adminId: adminId,
      status: status,
      reviewedAt: reviewedAt,
      reviewNotes: reviewNotes,
      checklistResults: checklistResults,
      requiredChanges: requiredChanges,
      verificationScore: verificationScore,
      nextReviewDate: nextReviewDate,
    );
  }

  factory ApplicationReviewModel.fromEntity(ApplicationReview entity) {
    return ApplicationReviewModel(
      id: entity.id,
      applicationId: entity.applicationId,
      adminId: entity.adminId,
      status: entity.status,
      reviewedAt: entity.reviewedAt,
      reviewNotes: entity.reviewNotes,
      checklistResults: entity.checklistResults,
      requiredChanges: entity.requiredChanges,
      verificationScore: entity.verificationScore,
      nextReviewDate: entity.nextReviewDate,
    );
  }

  ApplicationReviewModel copyWith({
    String? id,
    String? applicationId,
    String? adminId,
    ReviewStatus? status,
    DateTime? reviewedAt,
    String? reviewNotes,
    Map<String, bool>? checklistResults,
    List<String>? requiredChanges,
    int? verificationScore,
    DateTime? nextReviewDate,
  }) {
    return ApplicationReviewModel(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      adminId: adminId ?? this.adminId,
      status: status ?? this.status,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      checklistResults: checklistResults ?? this.checklistResults,
      requiredChanges: requiredChanges ?? this.requiredChanges,
      verificationScore: verificationScore ?? this.verificationScore,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }
}

/// Admin dashboard stats data model
class AdminDashboardStatsModel {
  final int totalApplications;
  final int pendingReviews;
  final int approvedThisWeek;
  final int rejectedThisWeek;
  final int averageReviewTime;
  final Map<String, int> applicationsByStatus;
  final Map<String, int> reviewsByAdmin;

  const AdminDashboardStatsModel({
    required this.totalApplications,
    required this.pendingReviews,
    required this.approvedThisWeek,
    required this.rejectedThisWeek,
    required this.averageReviewTime,
    required this.applicationsByStatus,
    required this.reviewsByAdmin,
  });

  factory AdminDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStatsModel(
      totalApplications: json['totalApplications'] ?? 0,
      pendingReviews: json['pendingReviews'] ?? 0,
      approvedThisWeek: json['approvedThisWeek'] ?? 0,
      rejectedThisWeek: json['rejectedThisWeek'] ?? 0,
      averageReviewTime: json['averageReviewTime'] ?? 0,
      applicationsByStatus: Map<String, int>.from(
        json['applicationsByStatus'] ?? {},
      ),
      reviewsByAdmin: Map<String, int>.from(json['reviewsByAdmin'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalApplications': totalApplications,
      'pendingReviews': pendingReviews,
      'approvedThisWeek': approvedThisWeek,
      'rejectedThisWeek': rejectedThisWeek,
      'averageReviewTime': averageReviewTime,
      'applicationsByStatus': applicationsByStatus,
      'reviewsByAdmin': reviewsByAdmin,
    };
  }

  AdminDashboardStats toEntity() {
    return AdminDashboardStats(
      totalApplications: totalApplications,
      pendingReviews: pendingReviews,
      approvedThisWeek: approvedThisWeek,
      rejectedThisWeek: rejectedThisWeek,
      averageReviewTime: averageReviewTime,
      applicationsByStatus: applicationsByStatus,
      reviewsByAdmin: reviewsByAdmin,
    );
  }

  factory AdminDashboardStatsModel.fromEntity(AdminDashboardStats entity) {
    return AdminDashboardStatsModel(
      totalApplications: entity.totalApplications,
      pendingReviews: entity.pendingReviews,
      approvedThisWeek: entity.approvedThisWeek,
      rejectedThisWeek: entity.rejectedThisWeek,
      averageReviewTime: entity.averageReviewTime,
      applicationsByStatus: entity.applicationsByStatus,
      reviewsByAdmin: entity.reviewsByAdmin,
    );
  }
}

/// Audit log entry data model
class AuditLogEntryModel {
  final String id;
  final String adminId;
  final String action;
  final String targetType;
  final String targetId;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String ipAddress;

  const AuditLogEntryModel({
    required this.id,
    required this.adminId,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.metadata,
    required this.timestamp,
    required this.ipAddress,
  });

  factory AuditLogEntryModel.fromJson(Map<String, dynamic> json) {
    return AuditLogEntryModel(
      id: json['id'],
      adminId: json['adminId'],
      action: json['action'],
      targetType: json['targetType'],
      targetId: json['targetId'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      timestamp: DateTime.parse(json['timestamp']),
      ipAddress: json['ipAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
    };
  }

  AuditLogEntry toEntity() {
    return AuditLogEntry(
      id: id,
      adminId: adminId,
      action: action,
      targetType: targetType,
      targetId: targetId,
      metadata: metadata,
      timestamp: timestamp,
      ipAddress: ipAddress,
    );
  }

  factory AuditLogEntryModel.fromEntity(AuditLogEntry entity) {
    return AuditLogEntryModel(
      id: entity.id,
      adminId: entity.adminId,
      action: entity.action,
      targetType: entity.targetType,
      targetId: entity.targetId,
      metadata: entity.metadata,
      timestamp: entity.timestamp,
      ipAddress: entity.ipAddress,
    );
  }

  AuditLogEntryModel copyWith({
    String? id,
    String? adminId,
    String? action,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? ipAddress,
  }) {
    return AuditLogEntryModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      action: action ?? this.action,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }
}
