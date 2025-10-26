import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../business_owners/data/models/project_application_model.dart';
import '../../../business_owners/domain/entities/project_application_entity/project_application_entity.dart';

class AdminService {
  final AdminRepository _repository;

  AdminService(this._repository);

  // Admin management
  Future<List<Admin>> getAllAdmins() async {
    return await _repository.getAllAdmins();
  }

  Future<Admin?> getAdminById(String id) async {
    return await _repository.getAdminById(id);
  }

  Future<String> createAdmin({
    required String name,
    required String email,
    required AdminRole role,
  }) async {
    final admin = Admin(
      id: '',
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
    );

    return await _repository.createAdmin(admin);
  }

  Future<void> updateAdmin(Admin admin) async {
    await _repository.updateAdmin(admin);
  }

  Future<void> deactivateAdmin(String adminId) async {
    final admin = await _repository.getAdminById(adminId);
    if (admin != null) {
      final updatedAdmin = Admin(
        id: admin.id,
        name: admin.name,
        email: admin.email,
        role: admin.role,
        createdAt: admin.createdAt,
        lastLoginAt: admin.lastLoginAt,
        isActive: false,
      );
      await _repository.updateAdmin(updatedAdmin);
    }
  }

  // Application reviews
  Future<String> createReview({
    required String applicationId,
    required String adminId,
    required ReviewStatus status,
    String? reviewNotes,
    Map<String, bool>? checklistResults,
    List<String>? requiredChanges,
    int? verificationScore,
  }) async {
    final review = ApplicationReview(
      id: '',
      applicationId: applicationId,
      adminId: adminId,
      status: status,
      reviewedAt: DateTime.now(),
      reviewNotes: reviewNotes,
      checklistResults: checklistResults ?? {},
      requiredChanges: requiredChanges ?? [],
      verificationScore: verificationScore ?? 0,
    );

    return await _repository.createReview(review);
  }

  Future<void> updateReview(ApplicationReview review) async {
    await _repository.updateReview(review);
  }

  Future<List<ApplicationReview>> getReviewsForApplication(
    String applicationId,
  ) async {
    return await _repository.getReviewsByApplicationId(applicationId);
  }

  Future<List<ApplicationReview>> getReviewsByAdmin(String adminId) async {
    return await _repository.getReviewsByAdminId(adminId);
  }

  // Dashboard operations
  Future<AdminDashboardStats> getDashboardStats() async {
    return await _repository.getDashboardStats();
  }

  Future<List<ProjectApplicationModel>> getPendingApplications() async {
    return await _repository.getApplicationsByStatus(
      ApplicationStatus.submitted,
    );
  }

  Future<List<ProjectApplicationModel>> getUnderReviewApplications() async {
    return await _repository.getApplicationsByStatus(
      ApplicationStatus.underReview,
    );
  }

  Future<List<ProjectApplicationModel>> getApplicationsForReview() async {
    return await _repository.getApplicationsForReview();
  }

  // Audit logging
  Future<void> logAdminAction({
    required String adminId,
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? metadata,
    String? ipAddress,
  }) async {
    final auditEntry = AuditLogEntry(
      id: '',
      adminId: adminId,
      action: action,
      targetType: targetType,
      targetId: targetId,
      metadata: metadata,
      timestamp: DateTime.now(),
      ipAddress: ipAddress ?? 'unknown',
    );

    await _repository.logAuditEvent(auditEntry);
  }

  Future<List<AuditLogEntry>> getAuditLogs({
    String? adminId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getAuditLogs(
      adminId: adminId,
      action: action,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Utility methods
  Future<void> initialize() async {
    await _repository.initialize();
  }
}
