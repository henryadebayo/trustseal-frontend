import 'dart:io';
import 'package:trustseal_app/core/services/api_service.dart';

class BusinessOwnerService {
  final ApiService _api = ApiService.instance;

  // Get business owner projects
  Future<Map<String, dynamic>> getProjects({
    String? status,
    int? limit,
    int? offset,
  }) async {
    return await _api.getBusinessOwnerProjects(
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  // Create new project
  Future<Map<String, dynamic>> createProject({
    required String name,
    required String description,
    required String website,
    required String contractAddress,
    required String tokenSymbol,
    required String tokenName,
    String network = 'blockdag',
    Map<String, dynamic>? teamInfo,
    Map<String, dynamic>? financialInfo,
    Map<String, dynamic>? communityInfo,
  }) async {
    return await _api.createProject(
      name: name,
      description: description,
      website: website,
      contractAddress: contractAddress,
      tokenSymbol: tokenSymbol,
      tokenName: tokenName,
      network: network,
      teamInfo: teamInfo,
      financialInfo: financialInfo,
      communityInfo: communityInfo,
    );
  }

  // Get business owner applications
  Future<Map<String, dynamic>> getApplications({
    String? status,
    int? limit,
    int? offset,
  }) async {
    return await _api.getBusinessOwnerApplications(
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  // Create verification application
  Future<Map<String, dynamic>> createApplication({
    required String projectId,
    required String applicationType,
    required Map<String, dynamic> submissionData,
  }) async {
    return await _api.createApplication(
      projectId: projectId,
      applicationType: applicationType,
      submissionData: submissionData,
    );
  }

  // Submit application
  Future<Map<String, dynamic>> submitApplication({
    required String applicationId,
    required Map<String, dynamic> submissionData,
  }) async {
    return await _api.submitApplication(
      applicationId: applicationId,
      submissionData: submissionData,
    );
  }

  // Get application details
  Future<Map<String, dynamic>> getApplicationDetails(
    String applicationId,
  ) async {
    return await _api.getApplicationDetails(applicationId);
  }

  // Get business owner analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    return await _api.getBusinessOwnerAnalytics();
  }

  // File upload
  Future<Map<String, dynamic>> uploadFiles({
    required List<File> files,
    required String category,
    String? projectId,
    String? applicationId,
  }) async {
    return await _api.uploadFiles(
      files: files,
      category: category,
      projectId: projectId,
      applicationId: applicationId,
    );
  }

  // Get project files
  Future<Map<String, dynamic>> getProjectFiles(
    String projectId, {
    String? category,
    int? limit,
    int? offset,
  }) async {
    return await _api.getProjectFiles(
      projectId,
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  // Get file details
  Future<Map<String, dynamic>> getFileDetails(String fileId) async {
    return await _api.getFileDetails(fileId);
  }

  // Delete file
  Future<Map<String, dynamic>> deleteFile(String fileId) async {
    return await _api.deleteFile(fileId);
  }

  // Get file categories
  Future<Map<String, dynamic>> getFileCategories() async {
    return await _api.getFileCategories();
  }
}
