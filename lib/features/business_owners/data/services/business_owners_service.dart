import '../storage/business_owners_storage.dart';
import '../models/project_application_model.dart';
import '../models/business_owner_model.dart';
import '../../domain/entities/project_application_entity/project_application_entity.dart';

class BusinessOwnersService {
  final BusinessOwnersStorage _storage;

  BusinessOwnersService(this._storage);

  // Project Applications
  Future<List<ProjectApplicationModel>> getAllApplications() async {
    return await _storage.getAllApplications();
  }

  Future<ProjectApplicationModel?> getApplicationById(String id) async {
    return await _storage.getApplicationById(id);
  }

  Future<String> createApplication(ProjectApplicationModel application) async {
    return await _storage.saveApplication(application);
  }

  Future<void> updateApplication(ProjectApplicationModel application) async {
    await _storage.updateApplication(application);
  }

  Future<void> deleteApplication(String id) async {
    await _storage.deleteApplication(id);
  }

  Future<List<ProjectApplicationModel>> getApplicationsByBusinessOwnerId(
    String businessOwnerId,
  ) async {
    return await _storage.getApplicationsByBusinessOwnerId(businessOwnerId);
  }

  Future<List<ProjectApplicationModel>> getApplicationsByStatus(
    ApplicationStatus status,
  ) async {
    return await _storage.getApplicationsByStatus(status);
  }

  // Business Owners
  Future<List<BusinessOwnerModel>> getAllBusinessOwners() async {
    return await _storage.getAllBusinessOwners();
  }

  Future<BusinessOwnerModel?> getBusinessOwnerById(String id) async {
    return await _storage.getBusinessOwnerById(id);
  }

  Future<String> createBusinessOwner(BusinessOwnerModel businessOwner) async {
    return await _storage.saveBusinessOwner(businessOwner);
  }

  Future<void> updateBusinessOwner(BusinessOwnerModel businessOwner) async {
    await _storage.updateBusinessOwner(businessOwner);
  }

  Future<void> deleteBusinessOwner(String id) async {
    await _storage.deleteBusinessOwner(id);
  }

  // Analytics and Statistics
  Future<Map<String, int>> getApplicationStats() async {
    final applications = await getAllApplications();

    final stats = <String, int>{
      'total': applications.length,
      'draft': applications
          .where((app) => app.status == ApplicationStatus.draft)
          .length,
      'submitted': applications
          .where((app) => app.status == ApplicationStatus.submitted)
          .length,
      'underReview': applications
          .where((app) => app.status == ApplicationStatus.underReview)
          .length,
      'approved': applications
          .where((app) => app.status == ApplicationStatus.approved)
          .length,
      'rejected': applications
          .where((app) => app.status == ApplicationStatus.rejected)
          .length,
      'requiresChanges': applications
          .where((app) => app.status == ApplicationStatus.requiresChanges)
          .length,
    };

    return stats;
  }

  Future<List<ProjectApplicationModel>> getRecentApplications({
    int limit = 5,
  }) async {
    final applications = await getAllApplications();
    return applications.take(limit).toList();
  }

  Future<List<ProjectApplicationModel>> searchApplications(String query) async {
    final applications = await getAllApplications();

    if (query.isEmpty) return applications;

    final lowercaseQuery = query.toLowerCase();
    return applications.where((app) {
      return app.projectName.toLowerCase().contains(lowercaseQuery) ||
          app.projectDescription.toLowerCase().contains(lowercaseQuery) ||
          app.tokenSymbol.toLowerCase().contains(lowercaseQuery) ||
          app.tokenName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Utility methods
  Future<void> initialize() async {
    await _storage.initialize();
  }

  Future<void> clearAllData() async {
    await _storage.clearAllData();
  }
}
