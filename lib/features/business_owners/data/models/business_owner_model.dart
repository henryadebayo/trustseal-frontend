import '../../domain/entities/business_owner_entity/business_owner_entity.dart';

class BusinessOwnerModel {
  final String id;
  final String name;
  final String email;
  final String organizationName;
  final String walletAddress;
  final BusinessOwnerType type;
  final VerificationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BusinessOwnerProfileModel profile;

  const BusinessOwnerModel({
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

  factory BusinessOwnerModel.fromJson(Map<String, dynamic> json) {
    return BusinessOwnerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      organizationName: json['organizationName'],
      walletAddress: json['walletAddress'],
      type: BusinessOwnerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BusinessOwnerType.projectFounder,
      ),
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profile: BusinessOwnerProfileModel.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'organizationName': organizationName,
      'walletAddress': walletAddress,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profile': profile.toJson(),
    };
  }

  BusinessOwnerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? organizationName,
    String? walletAddress,
    BusinessOwnerType? type,
    VerificationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    BusinessOwnerProfileModel? profile,
  }) {
    return BusinessOwnerModel(
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

  BusinessOwner toEntity() {
    return BusinessOwner(
      id: id,
      name: name,
      email: email,
      organizationName: organizationName,
      walletAddress: walletAddress,
      type: type,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      profile: profile.toEntity(),
    );
  }

  factory BusinessOwnerModel.fromEntity(BusinessOwner entity) {
    return BusinessOwnerModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      organizationName: entity.organizationName,
      walletAddress: entity.walletAddress,
      type: entity.type,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      profile: BusinessOwnerProfileModel.fromEntity(entity.profile),
    );
  }
}

class BusinessOwnerProfileModel {
  final String? bio;
  final String? website;
  final String? twitter;
  final String? telegram;
  final String? linkedin;
  final String? logoUrl;
  final List<String> socialLinks;
  final Map<String, dynamic> metadata;

  const BusinessOwnerProfileModel({
    this.bio,
    this.website,
    this.twitter,
    this.telegram,
    this.linkedin,
    this.logoUrl,
    this.socialLinks = const [],
    this.metadata = const {},
  });

  factory BusinessOwnerProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessOwnerProfileModel(
      bio: json['bio'],
      website: json['website'],
      twitter: json['twitter'],
      telegram: json['telegram'],
      linkedin: json['linkedin'],
      logoUrl: json['logoUrl'],
      socialLinks: List<String>.from(json['socialLinks'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'website': website,
      'twitter': twitter,
      'telegram': telegram,
      'linkedin': linkedin,
      'logoUrl': logoUrl,
      'socialLinks': socialLinks,
      'metadata': metadata,
    };
  }

  BusinessOwnerProfileModel copyWith({
    String? bio,
    String? website,
    String? twitter,
    String? telegram,
    String? linkedin,
    String? logoUrl,
    List<String>? socialLinks,
    Map<String, dynamic>? metadata,
  }) {
    return BusinessOwnerProfileModel(
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

  BusinessOwnerProfile toEntity() {
    return BusinessOwnerProfile(
      bio: bio,
      website: website,
      twitter: twitter,
      telegram: telegram,
      linkedin: linkedin,
      logoUrl: logoUrl,
      socialLinks: socialLinks,
      metadata: metadata,
    );
  }

  factory BusinessOwnerProfileModel.fromEntity(BusinessOwnerProfile entity) {
    return BusinessOwnerProfileModel(
      bio: entity.bio,
      website: entity.website,
      twitter: entity.twitter,
      telegram: entity.telegram,
      linkedin: entity.linkedin,
      logoUrl: entity.logoUrl,
      socialLinks: entity.socialLinks,
      metadata: entity.metadata,
    );
  }
}
