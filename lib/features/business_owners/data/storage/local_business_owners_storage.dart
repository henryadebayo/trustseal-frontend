import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'business_owners_storage.dart';
import '../models/project_application_model.dart';
import '../models/business_owner_model.dart';
import '../../domain/entities/project_application_entity/project_application_entity.dart';
import '../../domain/entities/business_owner_entity/business_owner_entity.dart';

class LocalBusinessOwnersStorage implements BusinessOwnersStorage {
  static const String _applicationsBoxName = 'project_applications';
  static const String _businessOwnersBoxName = 'business_owners';

  late Box<Map> _applicationsBox;
  late Box<Map> _businessOwnersBox;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters if needed
    // Hive.registerAdapter(ProjectApplicationModelAdapter());
    // Hive.registerAdapter(BusinessOwnerModelAdapter());

    _applicationsBox = await Hive.openBox<Map>(_applicationsBoxName);
    _businessOwnersBox = await Hive.openBox<Map>(_businessOwnersBoxName);

    // Add some sample data if boxes are empty
    await _addSampleDataIfEmpty();
  }

  Future<void> _addSampleDataIfEmpty() async {
    if (_applicationsBox.isEmpty) {
      final sampleApplication = ProjectApplicationModel(
        id: _uuid.v4(),
        businessOwnerId: 'sample_owner_1',
        projectName: 'DeFi Protocol Alpha',
        projectDescription:
            'A revolutionary DeFi protocol for yield farming with advanced features',
        website: 'https://defialpha.com',
        contractAddress: '0x1234567890abcdef1234567890abcdef12345678',
        tokenSymbol: 'DFA',
        tokenName: 'DeFi Alpha',
        status: ApplicationStatus.underReview,
        submittedAt: DateTime.now().subtract(const Duration(days: 5)),
        reviewedAt: null,
        reviewNotes: null,
        applicationData: ProjectApplicationDataModel(
          tokenomics: TokenomicsDataModel(
            totalSupply: 1000000000,
            circulatingSupply: 200000000,
            distribution: {'Team': 20, 'Investors': 30, 'Community': 50},
            vestingSchedules: [
              VestingScheduleModel(
                category: 'Team',
                amount: 200000000,
                startDate: DateTime.now().add(const Duration(days: 30)),
                endDate: DateTime.now().add(
                  const Duration(days: 1095),
                ), // 3 years
                cliffPeriod: 365, // 1 year cliff
              ),
            ],
            contractAddress: '0x1234567890abcdef1234567890abcdef12345678',
            liquidityLocked: true,
            liquidityLockDuration: 12,
            liquidityLockProvider: 'Uniswap',
          ),
          team: TeamDataModel(
            members: [
              TeamMemberModel(
                name: 'John Doe',
                role: 'CEO & Founder',
                linkedin: 'https://linkedin.com/in/johndoe',
                twitter: '@johndoe',
                bio: 'Blockchain expert with 10+ years experience',
                isPublic: true,
              ),
              TeamMemberModel(
                name: 'Jane Smith',
                role: 'CTO',
                linkedin: 'https://linkedin.com/in/janesmith',
                twitter: '@janesmith',
                bio: 'Smart contract developer and security expert',
                isPublic: true,
              ),
            ],
            teamDoxxed: true,
            teamBackground:
                'Experienced blockchain developers from top tech companies',
            credentials: ['MIT', 'Stanford', 'Google', 'Microsoft'],
            linkedinProfile: 'https://linkedin.com/company/defialpha',
          ),
          financial: FinancialDataModel(
            fundingRaised: 5000000,
            investors: ['VC Fund A', 'Angel Investor B', 'Crypto Fund C'],
            treasuryAddress: '0x9876543210fedcba9876543210fedcba98765432',
            budgetAllocation: {
              'Development': 40,
              'Marketing': 30,
              'Operations': 30,
            },
            hasAudit: true,
            auditReportUrl: 'https://audit.com/report/defialpha',
          ),
          technical: TechnicalDataModel(
            githubRepository: 'https://github.com/defialpha/core',
            whitepaperUrl: 'https://defialpha.com/whitepaper.pdf',
            technicalDocumentation: 'https://docs.defialpha.com',
            hasSmartContractAudit: true,
            auditProvider: 'CertiK',
            auditReportUrl: 'https://certik.com/audit/defialpha',
            features: [
              'Yield Farming',
              'Liquidity Mining',
              'Governance',
              'Staking',
            ],
          ),
          marketing: MarketingDataModel(
            twitterHandle: '@DeFiAlpha',
            telegramGroup: 'https://t.me/defialpha',
            discordServer: 'https://discord.gg/defialpha',
            website: 'https://defialpha.com',
            socialMediaLinks: [
              'https://twitter.com/defialpha',
              'https://medium.com/@defialpha',
              'https://youtube.com/c/defialpha',
            ],
            marketingStrategy:
                'Community-driven growth with educational content',
            promotionPoolPercentage: 3,
            contentCreatorProgram:
                'Active creator rewards program with performance-based payouts',
          ),
        ),
        documents: [],
        checklist: VerificationChecklistModel(
          teamVerificationComplete: true,
          smartContractAuditComplete: true,
          liquidityLockVerified: true,
          tokenomicsVerified: false,
          financialAuditComplete: true,
          technicalReviewComplete: false,
          marketingPlanApproved: false,
          communityGuidelinesAccepted: true,
        ),
      );

      await saveApplication(sampleApplication);
    }

    if (_businessOwnersBox.isEmpty) {
      final sampleBusinessOwner = BusinessOwnerModel(
        id: 'sample_owner_1',
        name: 'John Doe',
        email: 'john@defialpha.com',
        organizationName: 'DeFi Alpha Labs',
        walletAddress: '0x1234567890abcdef1234567890abcdef12345678',
        type: BusinessOwnerType.projectFounder,
        status: VerificationStatus.verified,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        profile: BusinessOwnerProfileModel(
          bio: 'Blockchain entrepreneur focused on DeFi innovation',
          website: 'https://defialpha.com',
          twitter: '@johndoe',
          telegram: '@johndoe',
          linkedin: 'https://linkedin.com/in/johndoe',
          logoUrl: 'https://via.placeholder.com/100x100/1E3A8A/FFFFFF?text=DFA',
          socialLinks: [
            'https://twitter.com/johndoe',
            'https://linkedin.com/in/johndoe',
          ],
          metadata: {
            'experience_years': 10,
            'previous_companies': ['Google', 'Microsoft'],
            'education': 'MIT Computer Science',
          },
        ),
      );

      await saveBusinessOwner(sampleBusinessOwner);
    }
  }

  // Project Applications CRUD
  @override
  Future<List<ProjectApplicationModel>> getAllApplications() async {
    final applications = <ProjectApplicationModel>[];

    for (final entry in _applicationsBox.values) {
      try {
        final application = ProjectApplicationModel.fromJson(
          Map<String, dynamic>.from(entry),
        );
        applications.add(application);
      } catch (e) {
        // Skip corrupted entries
        continue;
      }
    }

    // Sort by submitted date (newest first)
    applications.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return applications;
  }

  @override
  Future<ProjectApplicationModel?> getApplicationById(String id) async {
    final data = _applicationsBox.get(id);
    if (data == null) return null;

    try {
      return ProjectApplicationModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> saveApplication(ProjectApplicationModel application) async {
    final id = application.id.isEmpty ? _uuid.v4() : application.id;
    final applicationWithId = application.copyWith(id: id);

    await _applicationsBox.put(id, applicationWithId.toJson());
    return id;
  }

  @override
  Future<void> updateApplication(ProjectApplicationModel application) async {
    await _applicationsBox.put(application.id, application.toJson());
  }

  @override
  Future<void> deleteApplication(String id) async {
    await _applicationsBox.delete(id);
  }

  @override
  Future<List<ProjectApplicationModel>> getApplicationsByBusinessOwnerId(
    String businessOwnerId,
  ) async {
    final allApplications = await getAllApplications();
    return allApplications
        .where((app) => app.businessOwnerId == businessOwnerId)
        .toList();
  }

  @override
  Future<List<ProjectApplicationModel>> getApplicationsByStatus(
    ApplicationStatus status,
  ) async {
    final allApplications = await getAllApplications();
    return allApplications.where((app) => app.status == status).toList();
  }

  // Business Owners CRUD
  @override
  Future<List<BusinessOwnerModel>> getAllBusinessOwners() async {
    final businessOwners = <BusinessOwnerModel>[];

    for (final entry in _businessOwnersBox.values) {
      try {
        final businessOwner = BusinessOwnerModel.fromJson(
          Map<String, dynamic>.from(entry),
        );
        businessOwners.add(businessOwner);
      } catch (e) {
        // Skip corrupted entries
        continue;
      }
    }

    // Sort by created date (newest first)
    businessOwners.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return businessOwners;
  }

  @override
  Future<BusinessOwnerModel?> getBusinessOwnerById(String id) async {
    final data = _businessOwnersBox.get(id);
    if (data == null) return null;

    try {
      return BusinessOwnerModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> saveBusinessOwner(BusinessOwnerModel businessOwner) async {
    final id = businessOwner.id.isEmpty ? _uuid.v4() : businessOwner.id;
    final businessOwnerWithId = businessOwner.copyWith(id: id);

    await _businessOwnersBox.put(id, businessOwnerWithId.toJson());
    return id;
  }

  @override
  Future<void> updateBusinessOwner(BusinessOwnerModel businessOwner) async {
    await _businessOwnersBox.put(businessOwner.id, businessOwner.toJson());
  }

  @override
  Future<void> deleteBusinessOwner(String id) async {
    await _businessOwnersBox.delete(id);
  }

  // Utility methods
  @override
  Future<void> clearAllData() async {
    await _applicationsBox.clear();
    await _businessOwnersBox.clear();
  }

  Future<void> close() async {
    await _applicationsBox.close();
    await _businessOwnersBox.close();
  }
}
