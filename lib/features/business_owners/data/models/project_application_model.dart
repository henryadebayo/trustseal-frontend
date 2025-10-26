import '../../domain/entities/project_application_entity/project_application_entity.dart';

class ProjectApplicationModel {
  final String id;
  final String businessOwnerId;
  final String projectName;
  final String projectDescription;
  final String website;
  final String contractAddress;
  final String tokenSymbol;
  final String tokenName;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final ProjectApplicationDataModel applicationData;
  final List<ApplicationDocumentModel> documents;
  final VerificationChecklistModel checklist;

  const ProjectApplicationModel({
    required this.id,
    required this.businessOwnerId,
    required this.projectName,
    required this.projectDescription,
    required this.website,
    required this.contractAddress,
    required this.tokenSymbol,
    required this.tokenName,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
    required this.applicationData,
    this.documents = const [],
    required this.checklist,
  });

  factory ProjectApplicationModel.fromJson(Map<String, dynamic> json) {
    return ProjectApplicationModel(
      id: json['id'],
      businessOwnerId: json['businessOwnerId'],
      projectName: json['projectName'],
      projectDescription: json['projectDescription'],
      website: json['website'],
      contractAddress: json['contractAddress'],
      tokenSymbol: json['tokenSymbol'],
      tokenName: json['tokenName'],
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.draft,
      ),
      submittedAt: DateTime.parse(json['submittedAt']),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewNotes: json['reviewNotes'],
      applicationData: ProjectApplicationDataModel.fromJson(
        json['applicationData'],
      ),
      documents:
          (json['documents'] as List?)
              ?.map((doc) => ApplicationDocumentModel.fromJson(doc))
              .toList() ??
          [],
      checklist: VerificationChecklistModel.fromJson(json['checklist']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessOwnerId': businessOwnerId,
      'projectName': projectName,
      'projectDescription': projectDescription,
      'website': website,
      'contractAddress': contractAddress,
      'tokenSymbol': tokenSymbol,
      'tokenName': tokenName,
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
      'applicationData': applicationData.toJson(),
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'checklist': checklist.toJson(),
    };
  }

  ProjectApplicationModel copyWith({
    String? id,
    String? businessOwnerId,
    String? projectName,
    String? projectDescription,
    String? website,
    String? contractAddress,
    String? tokenSymbol,
    String? tokenName,
    ApplicationStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewNotes,
    ProjectApplicationDataModel? applicationData,
    List<ApplicationDocumentModel>? documents,
    VerificationChecklistModel? checklist,
  }) {
    return ProjectApplicationModel(
      id: id ?? this.id,
      businessOwnerId: businessOwnerId ?? this.businessOwnerId,
      projectName: projectName ?? this.projectName,
      projectDescription: projectDescription ?? this.projectDescription,
      website: website ?? this.website,
      contractAddress: contractAddress ?? this.contractAddress,
      tokenSymbol: tokenSymbol ?? this.tokenSymbol,
      tokenName: tokenName ?? this.tokenName,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      applicationData: applicationData ?? this.applicationData,
      documents: documents ?? this.documents,
      checklist: checklist ?? this.checklist,
    );
  }

  ProjectApplication toEntity() {
    return ProjectApplication(
      id: id,
      businessOwnerId: businessOwnerId,
      projectName: projectName,
      projectDescription: projectDescription,
      website: website,
      contractAddress: contractAddress,
      tokenSymbol: tokenSymbol,
      tokenName: tokenName,
      status: status,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt,
      reviewNotes: reviewNotes,
      applicationData: applicationData.toEntity(),
      documents: documents.map((doc) => doc.toEntity()).toList(),
      checklist: checklist.toEntity(),
    );
  }

  factory ProjectApplicationModel.fromEntity(ProjectApplication entity) {
    return ProjectApplicationModel(
      id: entity.id,
      businessOwnerId: entity.businessOwnerId,
      projectName: entity.projectName,
      projectDescription: entity.projectDescription,
      website: entity.website,
      contractAddress: entity.contractAddress,
      tokenSymbol: entity.tokenSymbol,
      tokenName: entity.tokenName,
      status: entity.status,
      submittedAt: entity.submittedAt,
      reviewedAt: entity.reviewedAt,
      reviewNotes: entity.reviewNotes,
      applicationData: ProjectApplicationDataModel.fromEntity(
        entity.applicationData,
      ),
      documents: entity.documents
          .map((doc) => ApplicationDocumentModel.fromEntity(doc))
          .toList(),
      checklist: VerificationChecklistModel.fromEntity(entity.checklist),
    );
  }
}

class ProjectApplicationDataModel {
  final TokenomicsDataModel tokenomics;
  final TeamDataModel team;
  final FinancialDataModel financial;
  final TechnicalDataModel technical;
  final MarketingDataModel marketing;

  const ProjectApplicationDataModel({
    required this.tokenomics,
    required this.team,
    required this.financial,
    required this.technical,
    required this.marketing,
  });

  factory ProjectApplicationDataModel.fromJson(Map<String, dynamic> json) {
    return ProjectApplicationDataModel(
      tokenomics: TokenomicsDataModel.fromJson(json['tokenomics']),
      team: TeamDataModel.fromJson(json['team']),
      financial: FinancialDataModel.fromJson(json['financial']),
      technical: TechnicalDataModel.fromJson(json['technical']),
      marketing: MarketingDataModel.fromJson(json['marketing']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenomics': tokenomics.toJson(),
      'team': team.toJson(),
      'financial': financial.toJson(),
      'technical': technical.toJson(),
      'marketing': marketing.toJson(),
    };
  }

  ProjectApplicationData toEntity() {
    return ProjectApplicationData(
      tokenomics: tokenomics.toEntity(),
      team: team.toEntity(),
      financial: financial.toEntity(),
      technical: technical.toEntity(),
      marketing: marketing.toEntity(),
    );
  }

  factory ProjectApplicationDataModel.fromEntity(
    ProjectApplicationData entity,
  ) {
    return ProjectApplicationDataModel(
      tokenomics: TokenomicsDataModel.fromEntity(entity.tokenomics),
      team: TeamDataModel.fromEntity(entity.team),
      financial: FinancialDataModel.fromEntity(entity.financial),
      technical: TechnicalDataModel.fromEntity(entity.technical),
      marketing: MarketingDataModel.fromEntity(entity.marketing),
    );
  }
}

class TokenomicsDataModel {
  final int totalSupply;
  final int circulatingSupply;
  final Map<String, int> distribution;
  final List<VestingScheduleModel> vestingSchedules;
  final String contractAddress;
  final bool liquidityLocked;
  final int liquidityLockDuration;
  final String liquidityLockProvider;

  const TokenomicsDataModel({
    required this.totalSupply,
    required this.circulatingSupply,
    required this.distribution,
    required this.vestingSchedules,
    required this.contractAddress,
    required this.liquidityLocked,
    required this.liquidityLockDuration,
    required this.liquidityLockProvider,
  });

  factory TokenomicsDataModel.fromJson(Map<String, dynamic> json) {
    return TokenomicsDataModel(
      totalSupply: json['totalSupply'],
      circulatingSupply: json['circulatingSupply'],
      distribution: Map<String, int>.from(json['distribution']),
      vestingSchedules: (json['vestingSchedules'] as List)
          .map((v) => VestingScheduleModel.fromJson(v))
          .toList(),
      contractAddress: json['contractAddress'],
      liquidityLocked: json['liquidityLocked'],
      liquidityLockDuration: json['liquidityLockDuration'],
      liquidityLockProvider: json['liquidityLockProvider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSupply': totalSupply,
      'circulatingSupply': circulatingSupply,
      'distribution': distribution,
      'vestingSchedules': vestingSchedules.map((v) => v.toJson()).toList(),
      'contractAddress': contractAddress,
      'liquidityLocked': liquidityLocked,
      'liquidityLockDuration': liquidityLockDuration,
      'liquidityLockProvider': liquidityLockProvider,
    };
  }

  TokenomicsData toEntity() {
    return TokenomicsData(
      totalSupply: totalSupply,
      circulatingSupply: circulatingSupply,
      distribution: distribution,
      vestingSchedules: vestingSchedules.map((v) => v.toEntity()).toList(),
      contractAddress: contractAddress,
      liquidityLocked: liquidityLocked,
      liquidityLockDuration: liquidityLockDuration,
      liquidityLockProvider: liquidityLockProvider,
    );
  }

  factory TokenomicsDataModel.fromEntity(TokenomicsData entity) {
    return TokenomicsDataModel(
      totalSupply: entity.totalSupply,
      circulatingSupply: entity.circulatingSupply,
      distribution: entity.distribution,
      vestingSchedules: entity.vestingSchedules
          .map((v) => VestingScheduleModel.fromEntity(v))
          .toList(),
      contractAddress: entity.contractAddress,
      liquidityLocked: entity.liquidityLocked,
      liquidityLockDuration: entity.liquidityLockDuration,
      liquidityLockProvider: entity.liquidityLockProvider,
    );
  }
}

class TeamDataModel {
  final List<TeamMemberModel> members;
  final bool teamDoxxed;
  final String? teamBackground;
  final List<String> credentials;
  final String? linkedinProfile;

  const TeamDataModel({
    required this.members,
    required this.teamDoxxed,
    this.teamBackground,
    this.credentials = const [],
    this.linkedinProfile,
  });

  factory TeamDataModel.fromJson(Map<String, dynamic> json) {
    return TeamDataModel(
      members: (json['members'] as List)
          .map((member) => TeamMemberModel.fromJson(member))
          .toList(),
      teamDoxxed: json['teamDoxxed'],
      teamBackground: json['teamBackground'],
      credentials: List<String>.from(json['credentials'] ?? []),
      linkedinProfile: json['linkedinProfile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'members': members.map((member) => member.toJson()).toList(),
      'teamDoxxed': teamDoxxed,
      'teamBackground': teamBackground,
      'credentials': credentials,
      'linkedinProfile': linkedinProfile,
    };
  }

  TeamData toEntity() {
    return TeamData(
      members: members.map((member) => member.toEntity()).toList(),
      teamDoxxed: teamDoxxed,
      teamBackground: teamBackground,
      credentials: credentials,
      linkedinProfile: linkedinProfile,
    );
  }

  factory TeamDataModel.fromEntity(TeamData entity) {
    return TeamDataModel(
      members: entity.members
          .map((member) => TeamMemberModel.fromEntity(member))
          .toList(),
      teamDoxxed: entity.teamDoxxed,
      teamBackground: entity.teamBackground,
      credentials: entity.credentials,
      linkedinProfile: entity.linkedinProfile,
    );
  }
}

class TeamMemberModel {
  final String name;
  final String role;
  final String? linkedin;
  final String? twitter;
  final String? bio;
  final bool isPublic;

  const TeamMemberModel({
    required this.name,
    required this.role,
    this.linkedin,
    this.twitter,
    this.bio,
    this.isPublic = true,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      name: json['name'],
      role: json['role'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      bio: json['bio'],
      isPublic: json['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'linkedin': linkedin,
      'twitter': twitter,
      'bio': bio,
      'isPublic': isPublic,
    };
  }

  TeamMember toEntity() {
    return TeamMember(
      name: name,
      role: role,
      linkedin: linkedin,
      twitter: twitter,
      bio: bio,
      isPublic: isPublic,
    );
  }

  factory TeamMemberModel.fromEntity(TeamMember entity) {
    return TeamMemberModel(
      name: entity.name,
      role: entity.role,
      linkedin: entity.linkedin,
      twitter: entity.twitter,
      bio: entity.bio,
      isPublic: entity.isPublic,
    );
  }
}

class FinancialDataModel {
  final int fundingRaised;
  final List<String> investors;
  final String? treasuryAddress;
  final Map<String, int> budgetAllocation;
  final bool hasAudit;
  final String? auditReportUrl;

  const FinancialDataModel({
    required this.fundingRaised,
    this.investors = const [],
    this.treasuryAddress,
    this.budgetAllocation = const {},
    required this.hasAudit,
    this.auditReportUrl,
  });

  factory FinancialDataModel.fromJson(Map<String, dynamic> json) {
    return FinancialDataModel(
      fundingRaised: json['fundingRaised'],
      investors: List<String>.from(json['investors'] ?? []),
      treasuryAddress: json['treasuryAddress'],
      budgetAllocation: Map<String, int>.from(json['budgetAllocation'] ?? {}),
      hasAudit: json['hasAudit'],
      auditReportUrl: json['auditReportUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fundingRaised': fundingRaised,
      'investors': investors,
      'treasuryAddress': treasuryAddress,
      'budgetAllocation': budgetAllocation,
      'hasAudit': hasAudit,
      'auditReportUrl': auditReportUrl,
    };
  }

  FinancialData toEntity() {
    return FinancialData(
      fundingRaised: fundingRaised,
      investors: investors,
      treasuryAddress: treasuryAddress,
      budgetAllocation: budgetAllocation,
      hasAudit: hasAudit,
      auditReportUrl: auditReportUrl,
    );
  }

  factory FinancialDataModel.fromEntity(FinancialData entity) {
    return FinancialDataModel(
      fundingRaised: entity.fundingRaised,
      investors: entity.investors,
      treasuryAddress: entity.treasuryAddress,
      budgetAllocation: entity.budgetAllocation,
      hasAudit: entity.hasAudit,
      auditReportUrl: entity.auditReportUrl,
    );
  }
}

class TechnicalDataModel {
  final String? githubRepository;
  final String? whitepaperUrl;
  final String? technicalDocumentation;
  final bool hasSmartContractAudit;
  final String? auditProvider;
  final String? auditReportUrl;
  final List<String> features;

  const TechnicalDataModel({
    this.githubRepository,
    this.whitepaperUrl,
    this.technicalDocumentation,
    required this.hasSmartContractAudit,
    this.auditProvider,
    this.auditReportUrl,
    this.features = const [],
  });

  factory TechnicalDataModel.fromJson(Map<String, dynamic> json) {
    return TechnicalDataModel(
      githubRepository: json['githubRepository'],
      whitepaperUrl: json['whitepaperUrl'],
      technicalDocumentation: json['technicalDocumentation'],
      hasSmartContractAudit: json['hasSmartContractAudit'],
      auditProvider: json['auditProvider'],
      auditReportUrl: json['auditReportUrl'],
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'githubRepository': githubRepository,
      'whitepaperUrl': whitepaperUrl,
      'technicalDocumentation': technicalDocumentation,
      'hasSmartContractAudit': hasSmartContractAudit,
      'auditProvider': auditProvider,
      'auditReportUrl': auditReportUrl,
      'features': features,
    };
  }

  TechnicalData toEntity() {
    return TechnicalData(
      githubRepository: githubRepository,
      whitepaperUrl: whitepaperUrl,
      technicalDocumentation: technicalDocumentation,
      hasSmartContractAudit: hasSmartContractAudit,
      auditProvider: auditProvider,
      auditReportUrl: auditReportUrl,
      features: features,
    );
  }

  factory TechnicalDataModel.fromEntity(TechnicalData entity) {
    return TechnicalDataModel(
      githubRepository: entity.githubRepository,
      whitepaperUrl: entity.whitepaperUrl,
      technicalDocumentation: entity.technicalDocumentation,
      hasSmartContractAudit: entity.hasSmartContractAudit,
      auditProvider: entity.auditProvider,
      auditReportUrl: entity.auditReportUrl,
      features: entity.features,
    );
  }
}

class MarketingDataModel {
  final String? twitterHandle;
  final String? telegramGroup;
  final String? discordServer;
  final String? website;
  final List<String> socialMediaLinks;
  final String? marketingStrategy;
  final int promotionPoolPercentage;
  final String? contentCreatorProgram;

  const MarketingDataModel({
    this.twitterHandle,
    this.telegramGroup,
    this.discordServer,
    this.website,
    this.socialMediaLinks = const [],
    this.marketingStrategy,
    required this.promotionPoolPercentage,
    this.contentCreatorProgram,
  });

  factory MarketingDataModel.fromJson(Map<String, dynamic> json) {
    return MarketingDataModel(
      twitterHandle: json['twitterHandle'],
      telegramGroup: json['telegramGroup'],
      discordServer: json['discordServer'],
      website: json['website'],
      socialMediaLinks: List<String>.from(json['socialMediaLinks'] ?? []),
      marketingStrategy: json['marketingStrategy'],
      promotionPoolPercentage: json['promotionPoolPercentage'],
      contentCreatorProgram: json['contentCreatorProgram'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'twitterHandle': twitterHandle,
      'telegramGroup': telegramGroup,
      'discordServer': discordServer,
      'website': website,
      'socialMediaLinks': socialMediaLinks,
      'marketingStrategy': marketingStrategy,
      'promotionPoolPercentage': promotionPoolPercentage,
      'contentCreatorProgram': contentCreatorProgram,
    };
  }

  MarketingData toEntity() {
    return MarketingData(
      twitterHandle: twitterHandle,
      telegramGroup: telegramGroup,
      discordServer: discordServer,
      website: website,
      socialMediaLinks: socialMediaLinks,
      marketingStrategy: marketingStrategy,
      promotionPoolPercentage: promotionPoolPercentage,
      contentCreatorProgram: contentCreatorProgram,
    );
  }

  factory MarketingDataModel.fromEntity(MarketingData entity) {
    return MarketingDataModel(
      twitterHandle: entity.twitterHandle,
      telegramGroup: entity.telegramGroup,
      discordServer: entity.discordServer,
      website: entity.website,
      socialMediaLinks: entity.socialMediaLinks,
      marketingStrategy: entity.marketingStrategy,
      promotionPoolPercentage: entity.promotionPoolPercentage,
      contentCreatorProgram: entity.contentCreatorProgram,
    );
  }
}

class ApplicationDocumentModel {
  final String id;
  final String name;
  final String type;
  final String url;
  final DateTime uploadedAt;
  final String? description;

  const ApplicationDocumentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedAt,
    this.description,
  });

  factory ApplicationDocumentModel.fromJson(Map<String, dynamic> json) {
    return ApplicationDocumentModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      url: json['url'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
      'description': description,
    };
  }

  ApplicationDocument toEntity() {
    return ApplicationDocument(
      id: id,
      name: name,
      type: type,
      url: url,
      uploadedAt: uploadedAt,
      description: description,
    );
  }

  factory ApplicationDocumentModel.fromEntity(ApplicationDocument entity) {
    return ApplicationDocumentModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      url: entity.url,
      uploadedAt: entity.uploadedAt,
      description: entity.description,
    );
  }
}

class VerificationChecklistModel {
  final bool teamVerificationComplete;
  final bool smartContractAuditComplete;
  final bool liquidityLockVerified;
  final bool tokenomicsVerified;
  final bool financialAuditComplete;
  final bool technicalReviewComplete;
  final bool marketingPlanApproved;
  final bool communityGuidelinesAccepted;

  const VerificationChecklistModel({
    required this.teamVerificationComplete,
    required this.smartContractAuditComplete,
    required this.liquidityLockVerified,
    required this.tokenomicsVerified,
    required this.financialAuditComplete,
    required this.technicalReviewComplete,
    required this.marketingPlanApproved,
    required this.communityGuidelinesAccepted,
  });

  factory VerificationChecklistModel.fromJson(Map<String, dynamic> json) {
    return VerificationChecklistModel(
      teamVerificationComplete: json['teamVerificationComplete'],
      smartContractAuditComplete: json['smartContractAuditComplete'],
      liquidityLockVerified: json['liquidityLockVerified'],
      tokenomicsVerified: json['tokenomicsVerified'],
      financialAuditComplete: json['financialAuditComplete'],
      technicalReviewComplete: json['technicalReviewComplete'],
      marketingPlanApproved: json['marketingPlanApproved'],
      communityGuidelinesAccepted: json['communityGuidelinesAccepted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamVerificationComplete': teamVerificationComplete,
      'smartContractAuditComplete': smartContractAuditComplete,
      'liquidityLockVerified': liquidityLockVerified,
      'tokenomicsVerified': tokenomicsVerified,
      'financialAuditComplete': financialAuditComplete,
      'technicalReviewComplete': technicalReviewComplete,
      'marketingPlanApproved': marketingPlanApproved,
      'communityGuidelinesAccepted': communityGuidelinesAccepted,
    };
  }

  VerificationChecklist toEntity() {
    return VerificationChecklist(
      teamVerificationComplete: teamVerificationComplete,
      smartContractAuditComplete: smartContractAuditComplete,
      liquidityLockVerified: liquidityLockVerified,
      tokenomicsVerified: tokenomicsVerified,
      financialAuditComplete: financialAuditComplete,
      technicalReviewComplete: technicalReviewComplete,
      marketingPlanApproved: marketingPlanApproved,
      communityGuidelinesAccepted: communityGuidelinesAccepted,
    );
  }

  factory VerificationChecklistModel.fromEntity(VerificationChecklist entity) {
    return VerificationChecklistModel(
      teamVerificationComplete: entity.teamVerificationComplete,
      smartContractAuditComplete: entity.smartContractAuditComplete,
      liquidityLockVerified: entity.liquidityLockVerified,
      tokenomicsVerified: entity.tokenomicsVerified,
      financialAuditComplete: entity.financialAuditComplete,
      technicalReviewComplete: entity.technicalReviewComplete,
      marketingPlanApproved: entity.marketingPlanApproved,
      communityGuidelinesAccepted: entity.communityGuidelinesAccepted,
    );
  }
}

class VestingScheduleModel {
  final String category;
  final int amount;
  final DateTime startDate;
  final DateTime endDate;
  final int cliffPeriod;

  const VestingScheduleModel({
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.cliffPeriod,
  });

  factory VestingScheduleModel.fromJson(Map<String, dynamic> json) {
    return VestingScheduleModel(
      category: json['category'],
      amount: json['amount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      cliffPeriod: json['cliffPeriod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'cliffPeriod': cliffPeriod,
    };
  }

  VestingSchedule toEntity() {
    return VestingSchedule(
      category: category,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
      cliffPeriod: cliffPeriod,
    );
  }

  factory VestingScheduleModel.fromEntity(VestingSchedule entity) {
    return VestingScheduleModel(
      category: entity.category,
      amount: entity.amount,
      startDate: entity.startDate,
      endDate: entity.endDate,
      cliffPeriod: entity.cliffPeriod,
    );
  }
}
