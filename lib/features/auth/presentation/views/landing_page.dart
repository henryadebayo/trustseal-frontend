import 'package:flutter/material.dart';
import 'package:trustseal_app/core/constants/app_constants.dart';
import 'package:trustseal_app/features/auth/data/services/wallet_connection_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _cardsFadeAnimation;
  late Animation<Offset> _cardsSlideAnimation;

  @override
  void initState() {
    super.initState();

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
    Future.delayed(const Duration(milliseconds: 500), () {
      _cardsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.8),
              AppConstants.primaryColor.withOpacity(0.6),
              AppConstants.backgroundColor,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(),
                const SizedBox(height: 80),
                _buildUserTypesSection(),
                const SizedBox(height: 80),
                _buildFeaturesSection(),
                const SizedBox(height: 80),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _heroFadeAnimation,
      child: SlideTransition(
        position: _heroSlideAnimation,
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildLogoSection(),
              const SizedBox(height: 40),
              _buildHeroContent(),
              const SizedBox(height: 60),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.verified_user,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'TrustSeal',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Blockchain Verification Platform',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify • Trust • Secure',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent() {
    return Column(
      children: [
        Text(
          'Welcome to the Future of',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Blockchain Verification',
          style: TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            'Join thousands of projects and users building trust in the decentralized ecosystem',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildQuickActionButton(
          icon: Icons.search,
          label: 'Browse Projects',
          onTap: () => _showComingSoon('Browse Projects'),
        ),
        const SizedBox(width: 20),
        _buildQuickActionButton(
          icon: Icons.info_outline,
          label: 'Learn More',
          onTap: () => _showComingSoon('Learn More'),
        ),
        const SizedBox(width: 20),
        _buildQuickActionButton(
          icon: Icons.account_balance_wallet,
          label: 'Connect Wallet',
          onTap: () => _navigateToWalletConnect(),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypesSection() {
    return FadeTransition(
      opacity: _cardsFadeAnimation,
      child: SlideTransition(
        position: _cardsSlideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                'Choose Your Role',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select how you want to access TrustSeal',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 60),
              _buildUserTypeCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCards() {
    return Column(
      children: [
        // Admin Card
        _buildUserTypeCard(
          title: 'Admin',
          subtitle: 'Platform Management',
          description:
              'Manage applications, reviews, and platform settings with comprehensive admin tools',
          icon: Icons.admin_panel_settings,
          color: Colors.red,
          gradientColors: [Colors.red.shade400, Colors.red.shade600],
          onLogin: () => _navigateToLogin(UserType.admin),
          onSignup: () => _navigateToSignup(UserType.admin),
        ),
        const SizedBox(height: 30),

        // Business Owner Card
        _buildUserTypeCard(
          title: 'Business Owner',
          subtitle: 'Project Verification',
          description:
              'Submit and manage your project applications for blockchain verification',
          icon: Icons.business,
          color: Colors.blue,
          gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
          onLogin: () => _navigateToLogin(UserType.business),
          onSignup: () => _navigateToSignup(UserType.business),
          showWalletOption: true,
        ),
        const SizedBox(height: 30),

        // User Card
        _buildUserTypeCard(
          title: 'User',
          subtitle: 'Browse & Verify',
          description:
              'Explore verified projects and contribute to the blockchain ecosystem',
          icon: Icons.person,
          color: Colors.green,
          gradientColors: [Colors.green.shade400, Colors.green.shade600],
          onLogin: () => _navigateToLogin(UserType.user),
          onSignup: () => _navigateToSignup(UserType.user),
          showWalletOption: true,
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
    required VoidCallback onLogin,
    required VoidCallback onSignup,
    bool showWalletOption = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Login',
                  color: color,
                  gradientColors: gradientColors,
                  onTap: onLogin,
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  label: 'Sign Up',
                  color: color,
                  gradientColors: gradientColors,
                  onTap: onSignup,
                  isOutlined: false,
                ),
              ),
            ],
          ),
          if (showWalletOption) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                label: 'Connect Wallet',
                color: color,
                gradientColors: gradientColors,
                onTap: () => _navigateToWalletConnect(),
                isOutlined: true,
                icon: Icons.account_balance_wallet,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required bool isOutlined,
    IconData? icon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isOutlined ? null : LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        border: isOutlined ? Border.all(color: color, width: 2) : null,
        boxShadow: isOutlined
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isOutlined ? color : Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isOutlined ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            'Why Choose TrustSeal?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Experience the power of blockchain verification',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.security,
                  title: 'Secure',
                  description:
                      'Advanced security protocols ensure your data is protected',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.speed,
                  title: 'Fast',
                  description:
                      'Lightning-fast verification process saves you time',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.verified,
                  title: 'Reliable',
                  description: 'Trusted by thousands of projects worldwide',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'TrustSeal © 2025',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Building trust in the blockchain ecosystem',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Built with ❤️ by team Velox',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin(UserType userType) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(userType: userType)),
    );
  }

  void _navigateToSignup(UserType userType) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen(userType: userType)),
    );
  }

  void _navigateToWalletConnect() {
    showDialog(
      context: context,
      builder: (context) => WalletConnectionDialog(
        onWalletSelected: (walletType) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Wallet connected! Please choose your role to continue.',
              ),
              backgroundColor: Colors.blue,
            ),
          );
        },
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }
}

enum UserType { admin, business, user }
