import '../entities/admin_entity.dart';
import '../../../business_owners/data/models/project_application_model.dart';
import '../../../business_owners/domain/entities/project_application_entity/project_application_entity.dart';

/// Abstract repository interface for Admin data
abstract class AdminRepository {
  // Admin management
  Future<List<Admin>> getAllAdmins();
  Future<Admin?> getAdminById(String id);
  Future<String> createAdmin(Admin admin);
  Future<void> updateAdmin(Admin admin);
  Future<void> deleteAdmin(String id);

  // Application reviews
  Future<List<ApplicationReview>> getAllReviews();
  Future<ApplicationReview?> getReviewById(String id);
  Future<List<ApplicationReview>> getReviewsByApplicationId(
    String applicationId,
  );
  Future<List<ApplicationReview>> getReviewsByAdminId(String adminId);
  Future<String> createReview(ApplicationReview review);
  Future<void> updateReview(ApplicationReview review);

  // Dashboard statistics
  Future<AdminDashboardStats> getDashboardStats();
  Future<List<ProjectApplicationModel>> getApplicationsForReview();
  Future<List<ProjectApplicationModel>> getApplicationsByStatus(
    ApplicationStatus status,
  );

  // Audit logging
  Future<void> logAuditEvent(AuditLogEntry entry);
  Future<List<AuditLogEntry>> getAuditLogs({
    String? adminId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Utility methods
  Future<void> initialize();
}
