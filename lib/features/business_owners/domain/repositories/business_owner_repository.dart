import '../entities/business_owner_entity/business_owner_entity.dart';
import '../entities/project_application_entity/project_application_entity.dart';

abstract class BusinessOwnerRepository {
  Future<BusinessOwner> createBusinessOwner(BusinessOwner businessOwner);
  Future<BusinessOwner> getBusinessOwnerById(String id);
  Future<BusinessOwner> getBusinessOwnerByWalletAddress(String walletAddress);
  Future<List<BusinessOwner>> getAllBusinessOwners();
  Future<BusinessOwner> updateBusinessOwner(BusinessOwner businessOwner);
  Future<void> deleteBusinessOwner(String id);
  Future<List<BusinessOwner>> getBusinessOwnersByType(BusinessOwnerType type);
  Future<List<BusinessOwner>> getBusinessOwnersByStatus(
    VerificationStatus status,
  );
}

abstract class ProjectApplicationRepository {
  Future<ProjectApplication> createApplication(ProjectApplication application);
  Future<ProjectApplication> getApplicationById(String id);
  Future<List<ProjectApplication>> getApplicationsByBusinessOwner(
    String businessOwnerId,
  );
  Future<List<ProjectApplication>> getAllApplications();
  Future<ProjectApplication> updateApplication(ProjectApplication application);
  Future<void> deleteApplication(String id);
  Future<List<ProjectApplication>> getApplicationsByStatus(
    ApplicationStatus status,
  );
  Future<List<ProjectApplication>> getPendingApplications();
  Future<List<ProjectApplication>> getApplicationsRequiringReview();
}

abstract class VerificationRepository {
  Future<bool> verifyTeamIdentity(
    String businessOwnerId,
    List<String> documents,
  );
  Future<bool> verifySmartContract(String contractAddress);
  Future<bool> verifyLiquidityLock(String contractAddress, int requiredMonths);
  Future<bool> verifyTokenomics(ProjectApplicationData applicationData);
  Future<VerificationChecklist> performFullVerification(String applicationId);
  Future<void> updateVerificationStatus(
    String applicationId,
    ApplicationStatus status,
    String? notes,
  );
}
