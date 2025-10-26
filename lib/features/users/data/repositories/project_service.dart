import 'dart:math';
import '../../domain/entities/project_entity/project_entity.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  // Mock data for development
  final List<Project> _mockProjects = [
    Project(
      id: '1',
      name: 'BlockDAG Network',
      description:
          'Revolutionary blockchain technology combining DAG and blockchain for unprecedented scalability and security.',
      logoUrl: 'https://via.placeholder.com/48x48/1E3A8A/FFFFFF?text=BD',
      verificationStatus: VerificationStatus.verified,
      website: 'https://blockdag.network',
      twitter: 'https://twitter.com/blockdag',
      telegram: 'https://t.me/blockdag',
      metrics: ProjectMetrics(
        marketCap: 2500000000,
        liquidity: 45000000,
        holders: 125000,
        priceChange24h: 12.5,
        volume24h: 85000000,
        trustScore: 9.2,
      ),
      auditInfo: AuditInfo(
        teamVerified: true,
        smartContractAudited: true,
        liquidityLocked: true,
        tokenomicsVerified: true,
        auditReportUrl: 'https://audit.blockdag.network',
        auditDate: DateTime.now().subtract(const Duration(days: 30)),
        auditorName: 'CertiK',
      ),
      tokenomics: Tokenomics(
        totalSupply: 10000000000,
        circulatingSupply: 8500000000,
        distribution: {
          'Team': 15,
          'Investors': 25,
          'Community': 45,
          'Treasury': 15,
        },
        vestingSchedules: [
          VestingSchedule(
            category: 'Team',
            amount: 1500000000,
            startDate: DateTime.now().subtract(const Duration(days: 90)),
            endDate: DateTime.now().add(const Duration(days: 1095)),
            cliffPeriod: 365,
          ),
        ],
        contractAddress: '0x1234567890abcdef1234567890abcdef12345678',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Project(
      id: '2',
      name: 'DAGSwap',
      description:
          'Decentralized exchange built on BlockDAG technology, offering lightning-fast trades with minimal fees.',
      logoUrl: 'https://via.placeholder.com/48x48/3B82F6/FFFFFF?text=DS',
      verificationStatus: VerificationStatus.ongoing,
      website: 'https://dagswap.io',
      twitter: 'https://twitter.com/dagswap',
      telegram: 'https://t.me/dagswap',
      metrics: ProjectMetrics(
        marketCap: 850000000,
        liquidity: 25000000,
        holders: 45000,
        priceChange24h: -3.2,
        volume24h: 35000000,
        trustScore: 7.8,
      ),
      auditInfo: AuditInfo(
        teamVerified: true,
        smartContractAudited: false,
        liquidityLocked: true,
        tokenomicsVerified: true,
        auditReportUrl: '',
        auditDate: DateTime.now().subtract(const Duration(days: 15)),
        auditorName: 'In Progress',
      ),
      tokenomics: Tokenomics(
        totalSupply: 5000000000,
        circulatingSupply: 3200000000,
        distribution: {
          'Team': 20,
          'Investors': 30,
          'Community': 40,
          'Treasury': 10,
        },
        vestingSchedules: [],
        contractAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Project(
      id: '3',
      name: 'DAGFi Protocol',
      description:
          'DeFi protocol offering yield farming and staking opportunities on the BlockDAG network.',
      logoUrl: 'https://via.placeholder.com/48x48/10B981/FFFFFF?text=DF',
      verificationStatus: VerificationStatus.verified,
      website: 'https://dagfi.io',
      twitter: 'https://twitter.com/dagfi',
      telegram: 'https://t.me/dagfi',
      metrics: ProjectMetrics(
        marketCap: 1200000000,
        liquidity: 35000000,
        holders: 78000,
        priceChange24h: 8.7,
        volume24h: 55000000,
        trustScore: 8.9,
      ),
      auditInfo: AuditInfo(
        teamVerified: true,
        smartContractAudited: true,
        liquidityLocked: true,
        tokenomicsVerified: true,
        auditReportUrl: 'https://audit.dagfi.io',
        auditDate: DateTime.now().subtract(const Duration(days: 45)),
        auditorName: 'Hacken',
      ),
      tokenomics: Tokenomics(
        totalSupply: 2000000000,
        circulatingSupply: 1800000000,
        distribution: {
          'Team': 10,
          'Investors': 20,
          'Community': 60,
          'Treasury': 10,
        },
        vestingSchedules: [
          VestingSchedule(
            category: 'Team',
            amount: 200000000,
            startDate: DateTime.now().subtract(const Duration(days: 120)),
            endDate: DateTime.now().add(const Duration(days: 730)),
            cliffPeriod: 180,
          ),
        ],
        contractAddress: '0x9876543210fedcba9876543210fedcba98765432',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Project(
      id: '4',
      name: 'DAGGames',
      description:
          'Gaming platform leveraging BlockDAG for NFT trading and play-to-earn mechanics.',
      logoUrl: 'https://via.placeholder.com/48x48/F59E0B/FFFFFF?text=DG',
      verificationStatus: VerificationStatus.unverified,
      website: 'https://daggames.io',
      twitter: 'https://twitter.com/daggames',
      telegram: 'https://t.me/daggames',
      metrics: ProjectMetrics(
        marketCap: 150000000,
        liquidity: 5000000,
        holders: 12000,
        priceChange24h: -15.3,
        volume24h: 8000000,
        trustScore: 4.2,
      ),
      auditInfo: AuditInfo(
        teamVerified: false,
        smartContractAudited: false,
        liquidityLocked: false,
        tokenomicsVerified: false,
        auditReportUrl: '',
        auditDate: DateTime.now().subtract(const Duration(days: 5)),
        auditorName: 'Not Audited',
      ),
      tokenomics: Tokenomics(
        totalSupply: 10000000000,
        circulatingSupply: 5000000000,
        distribution: {
          'Team': 50,
          'Investors': 30,
          'Community': 15,
          'Treasury': 5,
        },
        vestingSchedules: [],
        contractAddress: '0xfedcba9876543210fedcba9876543210fedcba98',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  // Get all projects
  Future<List<Project>> getAllProjects() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockProjects);
  }

  // Get project by ID
  Future<Project?> getProjectById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockProjects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get projects by verification status
  Future<List<Project>> getProjectsByStatus(VerificationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProjects
        .where((project) => project.verificationStatus == status)
        .toList();
  }

  // Search projects
  Future<List<Project>> searchProjects(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _mockProjects;

    return _mockProjects.where((project) {
      return project.name.toLowerCase().contains(query.toLowerCase()) ||
          project.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get trending projects (mock implementation)
  Future<List<Project>> getTrendingProjects() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Sort by trust score and return top 3
    final sortedProjects = List<Project>.from(_mockProjects);
    sortedProjects.sort(
      (a, b) => b.metrics.trustScore.compareTo(a.metrics.trustScore),
    );
    return sortedProjects.take(3).toList();
  }

  // Get recently added projects
  Future<List<Project>> getRecentlyAddedProjects() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sortedProjects = List<Project>.from(_mockProjects);
    sortedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedProjects.take(5).toList();
  }

  // Get analytics data (mock implementation)
  Future<Map<String, dynamic>> getAnalyticsData() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final verifiedCount = _mockProjects
        .where((p) => p.verificationStatus == VerificationStatus.verified)
        .length;
    final ongoingCount = _mockProjects
        .where((p) => p.verificationStatus == VerificationStatus.ongoing)
        .length;
    final unverifiedCount = _mockProjects
        .where((p) => p.verificationStatus == VerificationStatus.unverified)
        .length;

    final totalMarketCap = _mockProjects.fold<int>(
      0,
      (sum, project) => sum + project.metrics.marketCap,
    );
    final totalLiquidity = _mockProjects.fold<int>(
      0,
      (sum, project) => sum + project.metrics.liquidity,
    );
    final totalHolders = _mockProjects.fold<int>(
      0,
      (sum, project) => sum + project.metrics.holders,
    );

    return {
      'totalProjects': _mockProjects.length,
      'verifiedProjects': verifiedCount,
      'ongoingProjects': ongoingCount,
      'unverifiedProjects': unverifiedCount,
      'totalMarketCap': totalMarketCap,
      'totalLiquidity': totalLiquidity,
      'totalHolders': totalHolders,
      'averageTrustScore':
          _mockProjects.fold<double>(
            0,
            (sum, project) => sum + project.metrics.trustScore,
          ) /
          _mockProjects.length,
    };
  }

  // Simulate real-time price updates
  Stream<Map<String, double>> getPriceUpdates() async* {
    final random = Random();

    while (true) {
      await Future.delayed(const Duration(seconds: 5));

      final updates = <String, double>{};
      for (final project in _mockProjects) {
        // Simulate price changes between -2% and +2%
        final change = (random.nextDouble() - 0.5) * 4.0;
        updates[project.id] = change;
      }

      yield updates;
    }
  }

  // Mock API error simulation
  Future<void> simulateError() async {
    await Future.delayed(const Duration(milliseconds: 200));
    throw Exception('Simulated API error');
  }
}
