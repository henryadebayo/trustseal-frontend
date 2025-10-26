import '../business_owner_entity/business_owner_entity.dart';

class ProjectApplication {
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
  final ProjectApplicationData applicationData;
  final List<ApplicationDocument> documents;
  final VerificationChecklist checklist;

  const ProjectApplication({
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

  ProjectApplication copyWith({
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
    ProjectApplicationData? applicationData,
    List<ApplicationDocument>? documents,
    VerificationChecklist? checklist,
  }) {
    return ProjectApplication(
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
}

class ProjectApplicationData {
  final TokenomicsData tokenomics;
  final TeamData team;
  final FinancialData financial;
  final TechnicalData technical;
  final MarketingData marketing;

  const ProjectApplicationData({
    required this.tokenomics,
    required this.team,
    required this.financial,
    required this.technical,
    required this.marketing,
  });

  ProjectApplicationData copyWith({
    TokenomicsData? tokenomics,
    TeamData? team,
    FinancialData? financial,
    TechnicalData? technical,
    MarketingData? marketing,
  }) {
    return ProjectApplicationData(
      tokenomics: tokenomics ?? this.tokenomics,
      team: team ?? this.team,
      financial: financial ?? this.financial,
      technical: technical ?? this.technical,
      marketing: marketing ?? this.marketing,
    );
  }
}

class TokenomicsData {
  final int totalSupply;
  final int circulatingSupply;
  final Map<String, int> distribution;
  final List<VestingSchedule> vestingSchedules;
  final String contractAddress;
  final bool liquidityLocked;
  final int liquidityLockDuration; // in months
  final String liquidityLockProvider;

  const TokenomicsData({
    required this.totalSupply,
    required this.circulatingSupply,
    required this.distribution,
    required this.vestingSchedules,
    required this.contractAddress,
    required this.liquidityLocked,
    required this.liquidityLockDuration,
    required this.liquidityLockProvider,
  });
}

class TeamData {
  final List<TeamMember> members;
  final bool teamDoxxed;
  final String? teamBackground;
  final List<String> credentials;
  final String? linkedinProfile;

  const TeamData({
    required this.members,
    required this.teamDoxxed,
    this.teamBackground,
    this.credentials = const [],
    this.linkedinProfile,
  });
}

class TeamMember {
  final String name;
  final String role;
  final String? linkedin;
  final String? twitter;
  final String? bio;
  final bool isPublic;

  const TeamMember({
    required this.name,
    required this.role,
    this.linkedin,
    this.twitter,
    this.bio,
    this.isPublic = true,
  });
}

class FinancialData {
  final int fundingRaised;
  final List<String> investors;
  final String? treasuryAddress;
  final Map<String, int> budgetAllocation;
  final bool hasAudit;
  final String? auditReportUrl;

  const FinancialData({
    required this.fundingRaised,
    this.investors = const [],
    this.treasuryAddress,
    this.budgetAllocation = const {},
    required this.hasAudit,
    this.auditReportUrl,
  });
}

class TechnicalData {
  final String? githubRepository;
  final String? whitepaperUrl;
  final String? technicalDocumentation;
  final bool hasSmartContractAudit;
  final String? auditProvider;
  final String? auditReportUrl;
  final List<String> features;

  const TechnicalData({
    this.githubRepository,
    this.whitepaperUrl,
    this.technicalDocumentation,
    required this.hasSmartContractAudit,
    this.auditProvider,
    this.auditReportUrl,
    this.features = const [],
  });
}

class MarketingData {
  final String? twitterHandle;
  final String? telegramGroup;
  final String? discordServer;
  final String? website;
  final List<String> socialMediaLinks;
  final String? marketingStrategy;
  final int promotionPoolPercentage; // 2-5% of token supply
  final String? contentCreatorProgram;

  const MarketingData({
    this.twitterHandle,
    this.telegramGroup,
    this.discordServer,
    this.website,
    this.socialMediaLinks = const [],
    this.marketingStrategy,
    required this.promotionPoolPercentage,
    this.contentCreatorProgram,
  });
}

class ApplicationDocument {
  final String id;
  final String name;
  final String type;
  final String url;
  final DateTime uploadedAt;
  final String? description;

  const ApplicationDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedAt,
    this.description,
  });
}

class VerificationChecklist {
  final bool teamVerificationComplete;
  final bool smartContractAuditComplete;
  final bool liquidityLockVerified;
  final bool tokenomicsVerified;
  final bool financialAuditComplete;
  final bool technicalReviewComplete;
  final bool marketingPlanApproved;
  final bool communityGuidelinesAccepted;

  const VerificationChecklist({
    required this.teamVerificationComplete,
    required this.smartContractAuditComplete,
    required this.liquidityLockVerified,
    required this.tokenomicsVerified,
    required this.financialAuditComplete,
    required this.technicalReviewComplete,
    required this.marketingPlanApproved,
    required this.communityGuidelinesAccepted,
  });

  bool get isComplete {
    return teamVerificationComplete &&
        smartContractAuditComplete &&
        liquidityLockVerified &&
        tokenomicsVerified &&
        financialAuditComplete &&
        technicalReviewComplete &&
        marketingPlanApproved &&
        communityGuidelinesAccepted;
  }

  int get completionPercentage {
    final total = 8;
    final completed = [
      teamVerificationComplete,
      smartContractAuditComplete,
      liquidityLockVerified,
      tokenomicsVerified,
      financialAuditComplete,
      technicalReviewComplete,
      marketingPlanApproved,
      communityGuidelinesAccepted,
    ].where((item) => item).length;

    return ((completed / total) * 100).round();
  }
}

enum ApplicationStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  requiresChanges;

  String get displayName {
    switch (this) {
      case ApplicationStatus.draft:
        return 'Draft';
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.requiresChanges:
        return 'Requires Changes';
    }
  }
}

class VestingSchedule {
  final String category;
  final int amount;
  final DateTime startDate;
  final DateTime endDate;
  final int cliffPeriod; // in days

  const VestingSchedule({
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.cliffPeriod,
  });
}
