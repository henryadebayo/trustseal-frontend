import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trustseal_app/core/constants/app_constants.dart';
import 'package:trustseal_app/core/services/auth_service.dart';
import 'package:trustseal_app/features/auth/data/services/wallet_connection_service.dart';
import 'package:trustseal_app/features/auth/data/services/google_auth_service.dart';
import 'landing_page.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final UserType userType;

  const SignupScreen({super.key, required this.userType});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _organizationController = TextEditingController();
  final _walletAddressController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isGoogleLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationController.dispose();
    _walletAddressController.dispose();
    _animationController.dispose();
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
              _getUserTypeColor().withOpacity(0.1),
              _getUserTypeColor().withOpacity(0.05),
              AppConstants.backgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeader(),
                  ),
                ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildSignupForm(),
                  ),
                ),
                const SizedBox(height: 30),
                if (widget.userType != UserType.admin)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildWalletConnectOption(),
                    ),
                  ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildFooter(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getUserTypeColor().withOpacity(0.1),
                _getUserTypeColor().withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _getUserTypeColor().withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: _getUserTypeColor().withOpacity(0.1),
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
                  color: _getUserTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getUserTypeColor().withOpacity(0.3),
                  ),
                ),
                child: SvgPicture.asset(
                  _getUserTypeIcon(),
                  width: 60,
                  height: 60,
                  colorFilter: ColorFilter.mode(
                    _getUserTypeColor(),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Join TrustSeal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getUserTypeColor(),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getUserTypeTitle(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create your account and start your journey',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: _getUserTypeColor().withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_add,
                    color: _getUserTypeColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getUserTypeColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildNameField(),
            const SizedBox(height: 24),
            _buildEmailField(),
            const SizedBox(height: 24),
            _buildPasswordField(),
            const SizedBox(height: 24),
            _buildConfirmPasswordField(),
            if (_shouldShowOrganizationField()) ...[
              const SizedBox(height: 24),
              _buildOrganizationField(),
            ],
            if (_shouldShowWalletField()) ...[
              const SizedBox(height: 24),
              _buildWalletAddressField(),
            ],
            const SizedBox(height: 24),
            _buildTermsCheckbox(),
            const SizedBox(height: 32),
            _buildSignupButton(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildSocialSignup(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getNameFieldLabel(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: _getNameFieldHint(),
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getUserTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outlined,
                  color: _getUserTypeColor(),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _getUserTypeColor(), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your ${_getNameFieldLabel().toLowerCase()}';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getUserTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: _getUserTypeColor(),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _getUserTypeColor(), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getUserTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outlined,
                  color: _getUserTypeColor(),
                  size: 20,
                ),
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _getUserTypeColor(), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Password must contain uppercase, lowercase, and number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Re-enter your password',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getUserTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outlined,
                  color: _getUserTypeColor(),
                  size: 20,
                ),
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _getUserTypeColor(), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organization Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: _organizationController,
            decoration: InputDecoration(
              hintText: 'Enter your organization name',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getUserTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: _getUserTypeColor(),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _getUserTypeColor(), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your organization name';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWalletAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BlockDAG Wallet Address (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextFormField(
            controller: _walletAddressController,
            decoration: InputDecoration(
              hintText: '0x...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getUserTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: _getUserTypeColor(),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _getUserTypeColor(), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              helperText:
                  'You can add this later or connect your BlockDAG wallet',
              helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(value)) {
                  return 'Please enter a valid BlockDAG wallet address';
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: _getUserTypeColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _agreeToTerms = !_agreeToTerms;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: _getUserTypeColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: _getUserTypeColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getUserTypeColor(), _getUserTypeColor().withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getUserTypeColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading || !_agreeToTerms ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'OR',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSignup() {
    return Column(
      children: [
        _buildSocialButton(
          icon: 'assets/icons/google.svg',
          label: 'Continue with Google',
          color: const Color(0xFF4285F4),
          isLoading: _isGoogleLoading,
          onTap: _handleGoogleSignup,
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          icon: 'assets/icons/metamask.svg',
          label: 'Connect MetaMask (BlockDAG)',
          color: const Color(0xFFF6851B),
          onTap: _handleWalletConnect,
        ),
        const SizedBox(height: 16),
        _buildSocialButton(
          icon: 'assets/icons/ethereum.svg',
          label: 'Connect BlockDAG Wallet',
          color: const Color(0xFF627EEA),
          onTap: _handleWalletConnect,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required Color color,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletConnectOption() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getUserTypeColor().withOpacity(0.1),
            _getUserTypeColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getUserTypeColor().withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _getUserTypeColor().withOpacity(0.1),
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
              color: _getUserTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: _getUserTypeColor(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connect Your BlockDAG Wallet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getUserTypeColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your blockchain wallet for seamless access and verification on BlockDAG network',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getUserTypeColor(),
                  _getUserTypeColor().withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getUserTypeColor().withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _handleWalletConnect,
              icon: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
              ),
              label: const Text(
                'Connect BlockDAG Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Text(
                "Already have an account?",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getUserTypeColor()),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginScreen(userType: widget.userType),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: _getUserTypeColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingPage()),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.grey[600]),
          label: Text(
            'Back to Home',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Color _getUserTypeColor() {
    switch (widget.userType) {
      case UserType.admin:
        return Colors.red;
      case UserType.business:
        return Colors.blue;
      case UserType.user:
        return Colors.green;
    }
  }

  String _getUserTypeIcon() {
    switch (widget.userType) {
      case UserType.admin:
        return 'assets/icons/shield-check.svg';
      case UserType.business:
        return 'assets/icons/blockchain.svg';
      case UserType.user:
        return 'assets/icons/verified.svg';
    }
  }

  String _getUserTypeTitle() {
    switch (widget.userType) {
      case UserType.admin:
        return 'Platform Administrator';
      case UserType.business:
        return 'Business Owner';
      case UserType.user:
        return 'Community Member';
    }
  }

  String _getUserTypeString() {
    switch (widget.userType) {
      case UserType.admin:
        return 'admin';
      case UserType.business:
        return 'business';
      case UserType.user:
        return 'user';
    }
  }

  String _getNameFieldLabel() {
    switch (widget.userType) {
      case UserType.admin:
        return 'Full Name';
      case UserType.business:
        return 'Business Owner Name';
      case UserType.user:
        return 'Full Name';
    }
  }

  String _getNameFieldHint() {
    switch (widget.userType) {
      case UserType.admin:
        return 'Enter your full name';
      case UserType.business:
        return 'Enter your name as business owner';
      case UserType.user:
        return 'Enter your full name';
    }
  }

  bool _shouldShowOrganizationField() {
    return widget.userType == UserType.business;
  }

  bool _shouldShowWalletField() {
    return widget.userType != UserType.admin;
  }

  void _handleGoogleSignup() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleAuthService googleAuth = GoogleAuthService();
      final account = await googleAuth.signIn();

      if (account != null) {
        final userData = await googleAuth.getUserData();

        if (userData != null) {
          // Auto-fill form with Google data
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _emailController.text = userData['email'] ?? '';

            // Generate wallet address for Web3 users
            if (_shouldShowWalletField()) {
              _walletAddressController.text = googleAuth.generateWalletAddress(
                userData['email'],
              );
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Google account connected! Please complete the remaining fields.',
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google sign-in failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Split name into first and last name
        final nameParts = _nameController.text.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';

        // Call real backend API
        final response = await _authService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: firstName,
          lastName: lastName,
          userType: _getUserTypeString(),
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account created successfully for ${_getUserTypeTitle()}!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to appropriate dashboard
          _navigateToDashboard();
        } else {
          throw Exception(response['message'] ?? 'Signup failed');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleWalletConnect() {
    showDialog(
      context: context,
      builder: (context) => WalletConnectionDialog(
        onWalletSelected: (walletType) {
          // Handle successful wallet connection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'BlockDAG wallet connected! You can now complete your ${_getUserTypeTitle()} registration.',
              ),
              backgroundColor: _getUserTypeColor(),
            ),
          );
          // TODO: Auto-fill wallet address in form
          setState(() {
            _walletAddressController.text =
                WalletConnectionService().connectedWalletAddress ?? '';
          });
        },
      ),
    );
  }

  void _navigateToDashboard() {
    // Navigate to appropriate dashboard based on user type
    switch (widget.userType) {
      case UserType.admin:
        // Navigate to Admin Dashboard
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case UserType.business:
        // Navigate to Business Owners Dashboard
        Navigator.pushReplacementNamed(context, '/business');
        break;
      case UserType.user:
        // Navigate to Users Home Screen
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }
}
