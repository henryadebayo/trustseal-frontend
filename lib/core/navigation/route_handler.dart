import 'package:flutter/material.dart';
import 'package:trustseal_app/core/services/auth_manager.dart';
import 'package:trustseal_app/features/auth/presentation/views/landing_page.dart';

class TrustSealRouteHandler {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const AuthAwareLandingPage(),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (context) => settings.arguments as Widget,
        );
      case '/admin':
        return MaterialPageRoute(
          builder: (context) => settings.arguments as Widget,
        );
      case '/business':
        return MaterialPageRoute(
          builder: (context) => settings.arguments as Widget,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const AuthAwareLandingPage(),
        );
    }
  }
}

class AuthAwareLandingPage extends StatelessWidget {
  const AuthAwareLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthManager.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // User is authenticated, redirect to appropriate dashboard
          return FutureBuilder<String?>(
            future: AuthManager.getUserType(),
            builder: (context, userTypeSnapshot) {
              if (userTypeSnapshot.hasData) {
                final userType = userTypeSnapshot.data!;

                // Navigate to appropriate dashboard without allowing back navigation
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(
                    context,
                    _getDashboardRoute(userType),
                  );
                });

                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              return const LandingPage();
            },
          );
        }

        // User is not authenticated, show landing page
        return const LandingPage();
      },
    );
  }

  String _getDashboardRoute(String userType) {
    switch (userType) {
      case AuthManager.admin:
        return '/admin';
      case AuthManager.business:
        return '/business';
      case AuthManager.user:
        return '/home';
      default:
        return '/';
    }
  }
}

class BackNavigationHandler extends StatelessWidget {
  final Widget child;
  final String? fallbackRoute;

  const BackNavigationHandler({
    super.key,
    required this.child,
    this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Handle back navigation
          await _handleBackNavigation(context);
        }
      },
      child: child,
    );
  }

  Future<void> _handleBackNavigation(BuildContext context) async {
    final isAuthenticated = await AuthManager.isAuthenticated();

    if (isAuthenticated) {
      // User is authenticated, show confirmation dialog
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.exit_to_app, color: Colors.orange, size: 48),
          title: const Text('Exit App'),
          content: const Text(
            'Are you sure you want to exit the app? You will need to log in again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Exit'),
            ),
          ],
        ),
      );

      if (shouldExit == true) {
        // Clear authentication and exit
        await AuthManager.clearUserData();
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } else {
      // User is not authenticated, allow normal back navigation
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

class DashboardWrapper extends StatelessWidget {
  final Widget child;
  final String userType;

  const DashboardWrapper({
    super.key,
    required this.child,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return BackNavigationHandler(child: child);
  }
}
