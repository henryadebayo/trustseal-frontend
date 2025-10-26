import '../models/project_application_model.dart';
import '../models/business_owner_model.dart';
import '../../domain/entities/project_application_entity/project_application_entity.dart';

/// Abstract storage interface for Business Owners data
/// This allows us to easily swap between local storage and Firebase
abstract class BusinessOwnersStorage {
  // Project Applications
  Future<List<ProjectApplicationModel>> getAllApplications();
  Future<ProjectApplicationModel?> getApplicationById(String id);
  Future<String> saveApplication(ProjectApplicationModel application);
  Future<void> updateApplication(ProjectApplicationModel application);
  Future<void> deleteApplication(String id);
  Future<List<ProjectApplicationModel>> getApplicationsByBusinessOwnerId(
    String businessOwnerId,
  );
  Future<List<ProjectApplicationModel>> getApplicationsByStatus(
    ApplicationStatus status,
  );

  // Business Owners
  Future<List<BusinessOwnerModel>> getAllBusinessOwners();
  Future<BusinessOwnerModel?> getBusinessOwnerById(String id);
  Future<String> saveBusinessOwner(BusinessOwnerModel businessOwner);
  Future<void> updateBusinessOwner(BusinessOwnerModel businessOwner);
  Future<void> deleteBusinessOwner(String id);

  // Utility methods
  Future<void> clearAllData();
  Future<void> initialize();
}
