class BusinessOwner {
  final String id;
  final String name;
  final String email;
  final String organizationName;
  final String walletAddress;
  final BusinessOwnerType type;
  final VerificationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BusinessOwnerProfile profile;

  const BusinessOwner({
    required this.id,
    required this.name,
    required this.email,
    required this.organizationName,
    required this.walletAddress,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
  });

  BusinessOwner copyWith({
    String? id,
    String? name,
    String? email,
    String? organizationName,
    String? walletAddress,
    BusinessOwnerType? type,
    VerificationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    BusinessOwnerProfile? profile,
  }) {
    return BusinessOwner(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      organizationName: organizationName ?? this.organizationName,
      walletAddress: walletAddress ?? this.walletAddress,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
    );
  }
}

class BusinessOwnerProfile {
  final String? bio;
  final String? website;
  final String? twitter;
  final String? telegram;
  final String? linkedin;
  final String? logoUrl;
  final List<String> socialLinks;
  final Map<String, dynamic> metadata;

  const BusinessOwnerProfile({
    this.bio,
    this.website,
    this.twitter,
    this.telegram,
    this.linkedin,
    this.logoUrl,
    this.socialLinks = const [],
    this.metadata = const {},
  });

  BusinessOwnerProfile copyWith({
    String? bio,
    String? website,
    String? twitter,
    String? telegram,
    String? linkedin,
    String? logoUrl,
    List<String>? socialLinks,
    Map<String, dynamic>? metadata,
  }) {
    return BusinessOwnerProfile(
      bio: bio ?? this.bio,
      website: website ?? this.website,
      twitter: twitter ?? this.twitter,
      telegram: telegram ?? this.telegram,
      linkedin: linkedin ?? this.linkedin,
      logoUrl: logoUrl ?? this.logoUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum BusinessOwnerType {
  projectFounder,
  contentCreator,
  organization,
  enterprise;

  String get displayName {
    switch (this) {
      case BusinessOwnerType.projectFounder:
        return 'Project Founder';
      case BusinessOwnerType.contentCreator:
        return 'Content Creator';
      case BusinessOwnerType.organization:
        return 'Organization';
      case BusinessOwnerType.enterprise:
        return 'Enterprise';
    }
  }

  String get description {
    switch (this) {
      case BusinessOwnerType.projectFounder:
        return 'Individual or team launching a blockchain project';
      case BusinessOwnerType.contentCreator:
        return 'Content creator, influencer, or educator';
      case BusinessOwnerType.organization:
        return 'Company or organization in the blockchain space';
      case BusinessOwnerType.enterprise:
        return 'Large enterprise with blockchain initiatives';
    }
  }
}

enum VerificationStatus {
  pending,
  underReview,
  verified,
  rejected,
  suspended;

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.underReview:
        return 'Under Review';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.suspended:
        return 'Suspended';
    }
  }

  String get description {
    switch (this) {
      case VerificationStatus.pending:
        return 'Application submitted, awaiting review';
      case VerificationStatus.underReview:
        return 'Application is being reviewed by our team';
      case VerificationStatus.verified:
        return 'Successfully verified and approved';
      case VerificationStatus.rejected:
        return 'Application was rejected due to policy violations';
      case VerificationStatus.suspended:
        return 'Account temporarily suspended';
    }
  }
}
