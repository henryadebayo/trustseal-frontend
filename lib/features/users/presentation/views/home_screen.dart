import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trustseal_app/core/widgets/role_guard.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/project_entity/project_entity.dart';
import '../../data/repositories/project_service.dart';
import '../widgets/project_card.dart';
import 'project_detail_screen.dart';
import '../../../business_owners/data/services/business_owners_service.dart';
import '../../../admin/presentation/views/admin_navigation_screen.dart';
import '../../../admin/data/services/admin_service.dart';
import '../../../auth/presentation/views/landing_page.dart';

class HomeScreen extends StatefulWidget {
  final BusinessOwnersService businessService;
  final AdminService adminService;

  const HomeScreen({
    super.key,
    required this.businessService,
    required this.adminService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ProjectService _projectService = ProjectService();
  final TextEditingController _searchController = TextEditingController();

  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  Map<String, dynamic> _analytics = {};

  bool _isLoading = true;
  VerificationStatus? _selectedFilter;

  late TabController _tabController;
  late AnimationController _heroAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _particlesAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _cardsFadeAnimation;
  late Animation<Offset> _cardsSlideAnimation;
  late Animation<double> _particlesAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particlesAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _heroSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _heroAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _cardsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardsAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _cardsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cardsAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _particlesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particlesAnimationController,
        curve: Curves.linear,
      ),
    );

    _heroAnimationController.forward();
    _heroAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cardsAnimationController.forward();
      }
    });

    _particlesAnimationController.repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _heroAnimationController.dispose();
    _cardsAnimationController.dispose();
    _particlesAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _projectService.getAllProjects(),
        _projectService.getAnalyticsData(),
      ]);

      setState(() {
        _allProjects = results[0] as List<Project>;
        _filteredProjects = _allProjects;
        _analytics = results[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load projects: $e');
    }
  }

  void _filterProjects() {
    setState(() {
      _filteredProjects = _allProjects.where((project) {
        final matchesSearch =
            _searchController.text.isEmpty ||
            project.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            project.description.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        final matchesFilter =
            _selectedFilter == null ||
            project.verificationStatus == _selectedFilter;

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const RoleBasedNavigation(),
      appBar: AppBar(
        title: const Text('TrustSeal'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Animated Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF334155),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Floating Particles Effect
          ...List.generate(20, (index) => _buildFloatingParticle(index)),
          // Main Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingScreen()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: Colors.white,
                    backgroundColor: const Color(0xFF0F172A),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _heroFadeAnimation,
                            child: SlideTransition(
                              position: _heroSlideAnimation,
                              child: _buildHeroSection(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeTransition(
                            opacity: _cardsFadeAnimation,
                            child: SlideTransition(
                              position: _cardsSlideAnimation,
                              child: _buildSearchAndFilters(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _cardsFadeAnimation,
                            child: SlideTransition(
                              position: _cardsSlideAnimation,
                              child: _buildAnalyticsCards(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _cardsFadeAnimation,
                            child: SlideTransition(
                              position: _cardsSlideAnimation,
                              child: _buildProjectList(),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
          ),
          // Floating Action Button
          Positioned(bottom: 30, right: 30, child: _buildSpectacularFAB()),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return Positioned(
      left: (index * 37.0) % MediaQuery.of(context).size.width,
      top: (index * 67.0) % MediaQuery.of(context).size.height,
      child: AnimatedBuilder(
        animation: _particlesAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -80 * _particlesAnimation.value + (index * 10)),
            child: Opacity(
              opacity: (1.0 - _particlesAnimation.value) * 0.8,
              child: Container(
                width: 4 + (index % 3),
                height: 4 + (index % 3),
                decoration: BoxDecoration(
                  color: [
                    Colors.cyan,
                    Colors.blue,
                    Colors.purple,
                    Colors.green,
                  ][index % 4].withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: [
                        Colors.cyan,
                        Colors.blue,
                        Colors.purple,
                        Colors.green,
                      ][index % 4].withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan, Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Loading Blockchain Projects...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Discovering verified Web3 projects',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.withOpacity(0.8), Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/icons/verified.svg',
              width: 60,
              height: 60,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'TrustSeal Explorer',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Discover verified blockchain projects',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIndicator('Verified', Colors.green),
              const SizedBox(width: 20),
              _buildStatusIndicator('Secure', Colors.cyan),
              const SizedBox(width: 20),
              _buildStatusIndicator('Trusted', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search blockchain projects...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _filterProjects();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              onChanged: (value) => _filterProjects(),
            ),
          ),
          const SizedBox(height: 20),
          // Filter Tabs
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              indicatorColor: Colors.cyan,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              onTap: (index) {
                setState(() {
                  switch (index) {
                    case 0:
                      _selectedFilter = null;
                      break;
                    case 1:
                      _selectedFilter = VerificationStatus.verified;
                      break;
                    case 2:
                      _selectedFilter = VerificationStatus.ongoing;
                      break;
                    case 3:
                      _selectedFilter = VerificationStatus.unverified;
                      break;
                  }
                  _filterProjects();
                });
              },
              tabs: const [
                Tab(text: 'All Projects'),
                Tab(text: 'Verified'),
                Tab(text: 'Under Review'),
                Tab(text: 'Unverified'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards() {
    if (_analytics.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blockchain Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSpectacularAnalyticsCard(
                  title: 'Total Projects',
                  value: _analytics['totalProjects'].toString(),
                  icon: 'assets/icons/blockchain.svg',
                  color: const Color(0xFF00D4FF),
                  gradient: [const Color(0xFF00D4FF), const Color(0xFF0099CC)],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSpectacularAnalyticsCard(
                  title: 'Verified',
                  value: _analytics['verifiedProjects'].toString(),
                  icon: 'assets/icons/verified.svg',
                  color: const Color(0xFF00FF88),
                  gradient: [const Color(0xFF00FF88), const Color(0xFF00CC66)],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSpectacularAnalyticsCard(
                  title: 'Trust Score',
                  value: _analytics['averageTrustScore'].toStringAsFixed(1),
                  icon: 'assets/icons/shield-check.svg',
                  color: const Color(0xFFFFB800),
                  gradient: [const Color(0xFFFFB800), const Color(0xFFFF8C00)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpectacularAnalyticsCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  shadows: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    if (_filteredProjects.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verified Projects',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          ..._filteredProjects
              .take(5)
              .map(
                (project) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildSpectacularProjectCard(project),
                ),
              ),
          if (_filteredProjects.length > 5)
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Viewing all projects...'),
                        backgroundColor: Colors.cyan,
                      ),
                    );
                  },
                  child: Text(
                    'View All ${_filteredProjects.length} Projects',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpectacularProjectCard(Project project) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProjectDetail(project),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan.withOpacity(0.8), Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/blockchain.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildVerificationStatusChip(project.verificationStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStatusChip(VerificationStatus status) {
    Color color;
    String label;

    switch (status) {
      case VerificationStatus.verified:
        color = const Color(0xFF00FF88);
        label = 'Verified';
        break;
      case VerificationStatus.ongoing:
        color = const Color(0xFFFFB800);
        label = 'Reviewing';
        break;
      case VerificationStatus.unverified:
        color = const Color(0xFFFF4757);
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.withOpacity(0.8), Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/icons/blockchain.svg',
              width: 40,
              height: 40,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Projects Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectacularFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToBusinessPortal,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: SvgPicture.asset(
          'assets/icons/blockchain.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        label: const Text(
          'Business Portal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _navigateToProjectDetail(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );
  }

  void _navigateToBusinessPortal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
    );
  }

  void _navigateToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminNavigationScreen(service: widget.adminService),
      ),
    );
  }
}
