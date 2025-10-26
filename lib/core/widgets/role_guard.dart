import 'package:flutter/material.dart';
import 'package:trustseal_app/core/services/auth_manager.dart';

class RoleGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final Widget? loadingWidget;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return fallback ?? const SizedBox.shrink();
        }

        final hasPermission = snapshot.data ?? false;

        if (hasPermission) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }

  Future<bool> _hasPermission() async {
    // Check if user is authenticated
    if (!await AuthManager.isAuthenticated()) {
      return false;
    }

    // Check if user has permission for any of the allowed roles
    for (final role in allowedRoles) {
      if (await AuthManager.hasPermission(role)) {
        return true;
      }
    }

    return false;
  }
}

class RoleBasedNavigation extends StatelessWidget {
  const RoleBasedNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthManager.getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final userType = snapshot.data!;

        return _buildNavigationForUserType(context, userType);
      },
    );
  }

  Widget _buildNavigationForUserType(BuildContext context, String userType) {
    switch (userType) {
      case AuthManager.admin:
        return _buildAdminNavigation(context);
      case AuthManager.business:
        return _buildBusinessNavigation(context);
      case AuthManager.user:
        return _buildUserNavigation(context);
      default:
        return _buildGuestNavigation(context);
    }
  }

  Widget _buildAdminNavigation(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<String>(
                  future: AuthManager.getUserDisplayName(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin'),
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Verification Queue'),
            onTap: () {
              // Navigate to verification queue
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              // Navigate to analytics
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthManager.clearUserData();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessNavigation(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.business, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Business Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<String>(
                  future: AuthManager.getUserDisplayName(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacementNamed(context, '/business'),
          ),
          ListTile(
            leading: const Icon(Icons.add_business),
            title: const Text('My Projects'),
            onTap: () {
              // Navigate to projects
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Applications'),
            onTap: () {
              // Navigate to applications
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              // Navigate to analytics
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthManager.clearUserData();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserNavigation(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'User Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<String>(
                  future: AuthManager.getUserDisplayName(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Browse Projects'),
            onTap: () {
              // Navigate to project browser
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              // Navigate to favorites
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              // Navigate to history
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthManager.clearUserData();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestNavigation(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B7280), Color(0xFF374151)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_outline, color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  'Guest User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Please log in to access features',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Sign Up'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
    );
  }
}
