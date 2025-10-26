import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trustseal_app/core/constants/app_constants.dart';
import '../../domain/entities/admin_entity.dart';
import '../../data/services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminService service;

  const AdminDashboardScreen({super.key, required this.service});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  AdminDashboardStats? _stats;
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
      final stats = await widget.service.getDashboardStats();
      setState(() {
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
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
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
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF0F3460),
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
                    backgroundColor: const Color(0xFF1A1A2E),
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
                              child: _buildQuickActionsSection(),
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
      left: (index * 37.0) % MediaQuery.of(context).size.width,
      top: (index * 73.0) % MediaQuery.of(context).size.height,
      child: AnimatedBuilder(
        animation: _heroAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -50 * _heroAnimationController.value),
            child: Opacity(
              opacity: (1.0 - _heroAnimationController.value) * 0.6,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.5),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.3),
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
            'Loading Admin Dashboard...',
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
              'assets/icons/shield-check.svg',
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
            'Admin Command Center',
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
            'Manage the blockchain verification ecosystem',
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
              _buildStatusIndicator('Online', Colors.green),
              const SizedBox(width: 20),
              _buildStatusIndicator('Secure', Colors.cyan),
              const SizedBox(width: 20),
              _buildStatusIndicator('Active', Colors.blue),
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
    if (_stats == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Analytics',
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
                  value: '${_stats!.totalApplications}',
                  icon: 'assets/icons/blockchain.svg',
                  color: const Color(0xFF00D4FF),
                  gradient: [const Color(0xFF00D4FF), const Color(0xFF0099CC)],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSpectacularStatCard(
                  title: 'Pending Reviews',
                  value: '${_stats!.pendingReviews}',
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
                  title: 'Approved This Week',
                  value: '${_stats!.approvedThisWeek}',
                  icon: 'assets/icons/shield-check.svg',
                  color: const Color(0xFF00FF88),
                  gradient: [const Color(0xFF00FF88), const Color(0xFF00CC66)],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSpectacularStatCard(
                  title: 'Rejected This Week',
                  value: '${_stats!.rejectedThisWeek}',
                  icon: 'assets/icons/ethereum.svg',
                  color: const Color(0xFFFF4757),
                  gradient: [const Color(0xFFFF4757), const Color(0xFFCC3745)],
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

  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Command Center',
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
                child: _buildSpectacularActionCard(
                  title: 'Review Applications',
                  subtitle: 'Process pending verifications',
                  icon: 'assets/icons/verified.svg',
                  color: const Color(0xFF00D4FF),
                  gradient: [const Color(0xFF00D4FF), const Color(0xFF0099CC)],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navigating to Application Reviews...'),
                        backgroundColor: Colors.cyan,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildSpectacularActionCard(
                  title: 'Manage Admins',
                  subtitle: 'Control admin access',
                  icon: 'assets/icons/shield-check.svg',
                  color: const Color(0xFF8B5CF6),
                  gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navigating to Admin Management...'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpectacularActionCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
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
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
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
                  title: 'Application Approved',
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
                  title: 'Review Started',
                  subtitle: 'NFT Marketplace Beta',
                  time: '4 hours ago',
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
                  icon: 'assets/icons/ethereum.svg',
                  title: 'Application Rejected',
                  subtitle: 'Scam Token Project',
                  time: '1 day ago',
                  color: const Color(0xFFFF4757),
                  gradient: [const Color(0xFFFF4757), const Color(0xFFCC3745)],
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
