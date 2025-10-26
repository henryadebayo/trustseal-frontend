class Project {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final VerificationStatus verificationStatus;
  final String website;
  final String twitter;
  final String telegram;
  final ProjectMetrics metrics;
  final AuditInfo auditInfo;
  final Tokenomics tokenomics;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.verificationStatus,
    required this.website,
    required this.twitter,
    required this.telegram,
    required this.metrics,
    required this.auditInfo,
    required this.tokenomics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      verificationStatus: VerificationStatus.fromString(
        json['verificationStatus'],
      ),
      website: json['website'],
      twitter: json['twitter'],
      telegram: json['telegram'],
      metrics: ProjectMetrics.fromJson(json['metrics']),
      auditInfo: AuditInfo.fromJson(json['auditInfo']),
      tokenomics: Tokenomics.fromJson(json['tokenomics']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'verificationStatus': verificationStatus.toString(),
      'website': website,
      'twitter': twitter,
      'telegram': telegram,
      'metrics': metrics.toJson(),
      'auditInfo': auditInfo.toJson(),
      'tokenomics': tokenomics.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum VerificationStatus {
  verified,
  ongoing,
  unverified;

  static VerificationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'ongoing':
        return VerificationStatus.ongoing;
      case 'unverified':
        return VerificationStatus.unverified;
      default:
        return VerificationStatus.unverified;
    }
  }

  @override
  String toString() {
    switch (this) {
      case VerificationStatus.verified:
        return 'verified';
      case VerificationStatus.ongoing:
        return 'ongoing';
      case VerificationStatus.unverified:
        return 'unverified';
    }
  }

  String get displayName {
    switch (this) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.ongoing:
        return 'Under Review';
      case VerificationStatus.unverified:
        return 'Unverified';
    }
  }

  String get description {
    switch (this) {
      case VerificationStatus.verified:
        return 'Passed all audit checks, liquidity locked 6+ months';
      case VerificationStatus.ongoing:
        return 'Initial application approved, 30-day monitoring period';
      case VerificationStatus.unverified:
        return 'Failed audit requirements, high risk indicators';
    }
  }
}

class ProjectMetrics {
  final int marketCap;
  final int liquidity;
  final int holders;
  final double priceChange24h;
  final int volume24h;
  final double trustScore;

  ProjectMetrics({
    required this.marketCap,
    required this.liquidity,
    required this.holders,
    required this.priceChange24h,
    required this.volume24h,
    required this.trustScore,
  });

  factory ProjectMetrics.fromJson(Map<String, dynamic> json) {
    return ProjectMetrics(
      marketCap: json['marketCap'],
      liquidity: json['liquidity'],
      holders: json['holders'],
      priceChange24h: json['priceChange24h'].toDouble(),
      volume24h: json['volume24h'],
      trustScore: json['trustScore'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marketCap': marketCap,
      'liquidity': liquidity,
      'holders': holders,
      'priceChange24h': priceChange24h,
      'volume24h': volume24h,
      'trustScore': trustScore,
    };
  }
}

class AuditInfo {
  final bool teamVerified;
  final bool smartContractAudited;
  final bool liquidityLocked;
  final bool tokenomicsVerified;
  final String auditReportUrl;
  final DateTime auditDate;
  final String auditorName;

  AuditInfo({
    required this.teamVerified,
    required this.smartContractAudited,
    required this.liquidityLocked,
    required this.tokenomicsVerified,
    required this.auditReportUrl,
    required this.auditDate,
    required this.auditorName,
  });

  factory AuditInfo.fromJson(Map<String, dynamic> json) {
    return AuditInfo(
      teamVerified: json['teamVerified'],
      smartContractAudited: json['smartContractAudited'],
      liquidityLocked: json['liquidityLocked'],
      tokenomicsVerified: json['tokenomicsVerified'],
      auditReportUrl: json['auditReportUrl'],
      auditDate: DateTime.parse(json['auditDate']),
      auditorName: json['auditorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamVerified': teamVerified,
      'smartContractAudited': smartContractAudited,
      'liquidityLocked': liquidityLocked,
      'tokenomicsVerified': tokenomicsVerified,
      'auditReportUrl': auditReportUrl,
      'auditDate': auditDate.toIso8601String(),
      'auditorName': auditorName,
    };
  }
}

class Tokenomics {
  final int totalSupply;
  final int circulatingSupply;
  final Map<String, int> distribution;
  final List<VestingSchedule> vestingSchedules;
  final String contractAddress;

  Tokenomics({
    required this.totalSupply,
    required this.circulatingSupply,
    required this.distribution,
    required this.vestingSchedules,
    required this.contractAddress,
  });

  factory Tokenomics.fromJson(Map<String, dynamic> json) {
    return Tokenomics(
      totalSupply: json['totalSupply'],
      circulatingSupply: json['circulatingSupply'],
      distribution: Map<String, int>.from(json['distribution']),
      vestingSchedules: (json['vestingSchedules'] as List)
          .map((v) => VestingSchedule.fromJson(v))
          .toList(),
      contractAddress: json['contractAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSupply': totalSupply,
      'circulatingSupply': circulatingSupply,
      'distribution': distribution,
      'vestingSchedules': vestingSchedules.map((v) => v.toJson()).toList(),
      'contractAddress': contractAddress,
    };
  }
}

class VestingSchedule {
  final String category;
  final int amount;
  final DateTime startDate;
  final DateTime endDate;
  final int cliffPeriod;

  VestingSchedule({
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.cliffPeriod,
  });

  factory VestingSchedule.fromJson(Map<String, dynamic> json) {
    return VestingSchedule(
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
}
