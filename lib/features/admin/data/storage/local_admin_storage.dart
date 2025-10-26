import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/admin_model.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/admin_entity.dart';
import '../../../business_owners/data/services/business_owners_service.dart';
import '../../../business_owners/data/models/project_application_model.dart';
import '../../../business_owners/domain/entities/project_application_entity/project_application_entity.dart';

class LocalAdminStorage implements AdminRepository {
  static const String _adminsBoxName = 'admins';
  static const String _reviewsBoxName = 'application_reviews';
  static const String _auditLogsBoxName = 'audit_logs';

  late Box<Map> _adminsBox;
  late Box<Map> _reviewsBox;
  late Box<Map> _auditLogsBox;
  final Uuid _uuid = const Uuid();
  final BusinessOwnersService _businessOwnersService;

  LocalAdminStorage(this._businessOwnersService);

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();

    _adminsBox = await Hive.openBox<Map>(_adminsBoxName);
    _reviewsBox = await Hive.openBox<Map>(_reviewsBoxName);
    _auditLogsBox = await Hive.openBox<Map>(_auditLogsBoxName);

    // Add sample admin data if empty
    await _addSampleDataIfEmpty();
  }

  Future<void> _addSampleDataIfEmpty() async {
    if (_adminsBox.isEmpty) {
      final sampleAdmin = AdminModel(
        id: 'admin_1',
        name: 'Admin User',
        email: 'admin@trustseal.com',
        role: AdminRole.superAdmin,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
        isActive: true,
      );

      await _adminsBox.put(sampleAdmin.id, sampleAdmin.toJson());
    }
  }

  // Admin management
  @override
  Future<List<Admin>> getAllAdmins() async {
    final admins = <Admin>[];

    for (final entry in _adminsBox.values) {
      try {
        final admin = AdminModel.fromJson(Map<String, dynamic>.from(entry));
        admins.add(admin.toEntity());
      } catch (e) {
        continue;
      }
    }

    return admins;
  }

  @override
  Future<Admin?> getAdminById(String id) async {
    final data = _adminsBox.get(id);
    if (data == null) return null;

    try {
      final admin = AdminModel.fromJson(Map<String, dynamic>.from(data));
      return admin.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> createAdmin(Admin admin) async {
    final id = admin.id.isEmpty ? _uuid.v4() : admin.id;
    final adminModel = AdminModel.fromEntity(admin).copyWith(id: id);

    await _adminsBox.put(id, adminModel.toJson());
    return id;
  }

  @override
  Future<void> updateAdmin(Admin admin) async {
    final adminModel = AdminModel.fromEntity(admin);
    await _adminsBox.put(admin.id, adminModel.toJson());
  }

  @override
  Future<void> deleteAdmin(String id) async {
    await _adminsBox.delete(id);
  }

  // Application reviews
  @override
  Future<List<ApplicationReview>> getAllReviews() async {
    final reviews = <ApplicationReview>[];

    for (final entry in _reviewsBox.values) {
      try {
        final review = ApplicationReviewModel.fromJson(
          Map<String, dynamic>.from(entry),
        );
        reviews.add(review.toEntity());
      } catch (e) {
        continue;
      }
    }

    return reviews;
  }

  @override
  Future<ApplicationReview?> getReviewById(String id) async {
    final data = _reviewsBox.get(id);
    if (data == null) return null;

    try {
      final review = ApplicationReviewModel.fromJson(
        Map<String, dynamic>.from(data),
      );
      return review.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ApplicationReview>> getReviewsByApplicationId(
    String applicationId,
  ) async {
    final allReviews = await getAllReviews();
    return allReviews
        .where((review) => review.applicationId == applicationId)
        .toList();
  }

  @override
  Future<List<ApplicationReview>> getReviewsByAdminId(String adminId) async {
    final allReviews = await getAllReviews();
    return allReviews.where((review) => review.adminId == adminId).toList();
  }

  @override
  Future<String> createReview(ApplicationReview review) async {
    final id = review.id.isEmpty ? _uuid.v4() : review.id;
    final reviewModel = ApplicationReviewModel.fromEntity(
      review,
    ).copyWith(id: id);

    await _reviewsBox.put(id, reviewModel.toJson());
    return id;
  }

  @override
  Future<void> updateReview(ApplicationReview review) async {
    final reviewModel = ApplicationReviewModel.fromEntity(review);
    await _reviewsBox.put(review.id, reviewModel.toJson());
  }

  // Dashboard statistics
  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    final applications = await _businessOwnersService.getAllApplications();
    final reviews = await getAllReviews();

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final approvedThisWeek = reviews
        .where(
          (r) =>
              r.status == ReviewStatus.approved &&
              r.reviewedAt.isAfter(weekAgo),
        )
        .length;

    final rejectedThisWeek = reviews
        .where(
          (r) =>
              r.status == ReviewStatus.rejected &&
              r.reviewedAt.isAfter(weekAgo),
        )
        .length;

    final applicationsByStatus = <String, int>{};
    for (final app in applications) {
      applicationsByStatus[app.status.name] =
          (applicationsByStatus[app.status.name] ?? 0) + 1;
    }

    final reviewsByAdmin = <String, int>{};
    for (final review in reviews) {
      reviewsByAdmin[review.adminId] =
          (reviewsByAdmin[review.adminId] ?? 0) + 1;
    }

    return AdminDashboardStats(
      totalApplications: applications.length,
      pendingReviews: applications
          .where((app) => app.status == ApplicationStatus.submitted)
          .length,
      approvedThisWeek: approvedThisWeek,
      rejectedThisWeek: rejectedThisWeek,
      averageReviewTime: 2, // Mock data
      applicationsByStatus: applicationsByStatus,
      reviewsByAdmin: reviewsByAdmin,
    );
  }

  @override
  Future<List<ProjectApplicationModel>> getApplicationsForReview() async {
    final applications = await _businessOwnersService.getAllApplications();
    return applications
        .where(
          (app) =>
              app.status == ApplicationStatus.submitted ||
              app.status == ApplicationStatus.underReview,
        )
        .toList();
  }

  @override
  Future<List<ProjectApplicationModel>> getApplicationsByStatus(
    ApplicationStatus status,
  ) async {
    return await _businessOwnersService.getApplicationsByStatus(status);
  }

  // Audit logging
  @override
  Future<void> logAuditEvent(AuditLogEntry entry) async {
    final id = entry.id.isEmpty ? _uuid.v4() : entry.id;
    final auditModel = AuditLogEntryModel.fromEntity(entry).copyWith(id: id);

    await _auditLogsBox.put(id, auditModel.toJson());
  }

  @override
  Future<List<AuditLogEntry>> getAuditLogs({
    String? adminId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final logs = <AuditLogEntry>[];

    for (final entry in _auditLogsBox.values) {
      try {
        final log = AuditLogEntryModel.fromJson(
          Map<String, dynamic>.from(entry),
        );
        final entity = log.toEntity();

        // Apply filters
        if (adminId != null && entity.adminId != adminId) continue;
        if (action != null && entity.action != action) continue;
        if (startDate != null && entity.timestamp.isBefore(startDate)) continue;
        if (endDate != null && entity.timestamp.isAfter(endDate)) continue;

        logs.add(entity);
      } catch (e) {
        continue;
      }
    }

    // Sort by timestamp (newest first)
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  Future<void> close() async {
    await _adminsBox.close();
    await _reviewsBox.close();
    await _auditLogsBox.close();
  }
}
