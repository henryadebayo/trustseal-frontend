import 'package:flutter/material.dart';
import 'package:trustseal_app/core/services/auth_manager.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final Widget? unauthorizedWidget;
  final Widget? loadingWidget;

  const ProtectedRoute({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.unauthorizedWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error.toString());
        }

        if (snapshot.data == true) {
          return child;
        } else {
          return unauthorizedWidget ?? _buildUnauthorizedWidget(context);
        }
      },
    );
  }

  Future<bool> _checkPermission() async {
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

  Widget _buildUnauthorizedWidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You do not have permission to access this page.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Authentication Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleBasedWidget extends StatelessWidget {
  final Widget adminWidget;
  final Widget businessWidget;
  final Widget userWidget;
  final Widget? loadingWidget;

  const RoleBasedWidget({
    super.key,
    required this.adminWidget,
    required this.businessWidget,
    required this.userWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthManager.getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Error loading user data'));
        }

        final userType = snapshot.data!;

        switch (userType) {
          case AuthManager.admin:
            return adminWidget;
          case AuthManager.business:
            return businessWidget;
          case AuthManager.user:
            return userWidget;
          default:
            return const Center(child: Text('Unknown user type'));
        }
      },
    );
  }
}

class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthManager.getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Text('Error loading user info');
        }

        final userData = snapshot.data!;
        final displayName =
            userData['firstName'] != null && userData['lastName'] != null
            ? '${userData['firstName']} ${userData['lastName']}'
            : userData['email'] ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              userData['email'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            FutureBuilder<String>(
              future: AuthManager.getUserTypeDisplayName(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }
}
