import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trustseal_app/features/business_owners/data/models/project_application_model.dart';
import 'package:trustseal_app/features/business_owners/data/services/business_owners_service.dart';
import 'package:trustseal_app/features/business_owners/domain/entities/project_application_entity/project_application_entity.dart';

import '../../business_owners.dart';

class BusinessOwnersDashboardScreen extends StatefulWidget {
  final BusinessOwnersService service;

  const BusinessOwnersDashboardScreen({super.key, required this.service});

  @override
  State<BusinessOwnersDashboardScreen> createState() =>
      _BusinessOwnersDashboardScreenState();
}

class _BusinessOwnersDashboardScreenState
    extends State<BusinessOwnersDashboardScreen>
    with TickerProviderStateMixin {
  List<ProjectApplicationModel> _applications = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;

  late AnimationController _heroAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _cardsFadeAnimation;
  late Animation<Offset> _cardsSlideAnimation;

  @override
  void initState() {
    super.initState();
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

    _heroAnimationController.forward();
    _heroAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cardsAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final applications = await widget.service.getAllApplications();
      final stats = await widget.service.getApplicationStats();

      setState(() {
        _applications = applications;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ...List.generate(15, (index) => _buildFloatingParticle(index)),
          // Main Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingScreen()
                : RefreshIndicator(
                    onRefresh: _refreshData,
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
                              child: _buildStatsSection(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeTransition(
                            opacity: _cardsFadeAnimation,
                            child: SlideTransition(
                              position: _cardsSlideAnimation,
                              child: _buildApplicationsSection(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeTransition(
                            opacity: _cardsFadeAnimation,
                            child: SlideTransition(
                              position: _cardsSlideAnimation,
                              child: _buildActivitySection(),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return Positioned(
      left: (index * 47.0) % MediaQuery.of(context).size.width,
      top: (index * 83.0) % MediaQuery.of(context).size.height,
      child: AnimatedBuilder(
        animation: _heroAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -60 * _heroAnimationController.value),
            child: Opacity(
              opacity: (1.0 - _heroAnimationController.value) * 0.7,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 3,
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Business Dashboard...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
                colors: [Colors.blue.withOpacity(0.8), Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/icons/blockchain.svg',
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
            'Business Command Center',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
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
            'Manage your blockchain project applications',
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
              _buildStatusIndicator('Active', Colors.green),
              const SizedBox(width: 20),
              _buildStatusIndicator('Verified', Colors.cyan),
              const SizedBox(width: 20),
              _buildStatusIndicator('Growing', Colors.blue),
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

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Analytics',
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
                child: _buildSpectacularStatCard(
                  title: 'Total Applications',
                  value: '${_stats['total'] ?? 0}',
                  icon: 'assets/icons/blockchain.svg',
                  color: const Color(0xFF00D4FF),
                  gradient: [const Color(0xFF00D4FF), const Color(0xFF0099CC)],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSpectacularStatCard(
                  title: 'Under Review',
                  value: '${_stats['underReview'] ?? 0}',
                  icon: 'assets/icons/verified.svg',
                  color: const Color(0xFFFFB800),
                  gradient: [const Color(0xFFFFB800), const Color(0xFFFF8C00)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildSpectacularStatCard(
                  title: 'Approved',
                  value: '${_stats['approved'] ?? 0}',
                  icon: 'assets/icons/shield-check.svg',
                  color: const Color(0xFF00FF88),
                  gradient: [const Color(0xFF00FF88), const Color(0xFF00CC66)],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSpectacularStatCard(
                  title: 'Draft',
                  value: '${_stats['draft'] ?? 0}',
                  icon: 'assets/icons/ethereum.svg',
                  color: const Color(0xFF8B5CF6),
                  gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpectacularStatCard({
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

  Widget _buildApplicationsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Applications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.8), Colors.cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Viewing all applications...'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: const Text(
                    'View All',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_applications.isEmpty)
            _buildEmptyState()
          else
            ..._applications
                .take(3)
                .map(
                  (application) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _buildSpectacularApplicationCard(application),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
                colors: [Colors.blue.withOpacity(0.8), Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
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
            'No Applications Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by creating your first project application',
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

  Widget _buildSpectacularApplicationCard(ProjectApplicationModel application) {
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProjectApplicationDetailScreen(application: application),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.withOpacity(0.8), Colors.cyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
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
                        application.projectName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.projectDescription,
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
                _buildStatusChip(application.status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status) {
    Color color;
    String label;

    switch (status) {
      case ApplicationStatus.approved:
        color = const Color(0xFF00FF88);
        label = 'Approved';
        break;
      case ApplicationStatus.underReview:
        color = const Color(0xFFFFB800);
        label = 'Reviewing';
        break;
      case ApplicationStatus.rejected:
        color = const Color(0xFFFF4757);
        label = 'Rejected';
        break;
      case ApplicationStatus.draft:
        color = const Color(0xFF8B5CF6);
        label = 'Draft';
        break;
      case ApplicationStatus.submitted:
        color = const Color(0xFF3B82F6);
        label = 'Submitted';
        break;
      case ApplicationStatus.requiresChanges:
        color = const Color(0xFFF59E0B);
        label = 'Changes Required';
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

  Widget _buildActivitySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Activity Feed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
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
                _buildSpectacularActivityItem(
                  icon: 'assets/icons/shield-check.svg',
                  title: 'New Application Created',
                  subtitle: 'DeFi Protocol Alpha',
                  time: '2 hours ago',
                  color: const Color(0xFF00FF88),
                  gradient: [const Color(0xFF00FF88), const Color(0xFF00CC66)],
                ),
                const SizedBox(height: 15),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildSpectacularActivityItem(
                  icon: 'assets/icons/verified.svg',
                  title: 'Application Updated',
                  subtitle: 'Tokenomics information added',
                  time: '1 day ago',
                  color: const Color(0xFF00D4FF),
                  gradient: [const Color(0xFF00D4FF), const Color(0xFF0099CC)],
                ),
                const SizedBox(height: 15),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildSpectacularActivityItem(
                  icon: 'assets/icons/blockchain.svg',
                  title: 'Review Started',
                  subtitle: 'Team verification in progress',
                  time: '3 days ago',
                  color: const Color(0xFFFFB800),
                  gradient: [const Color(0xFFFFB800), const Color(0xFFFF8C00)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectacularActivityItem({
    required String icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required List<Color> gradient,
  }) {
    return Row(
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
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            time,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
