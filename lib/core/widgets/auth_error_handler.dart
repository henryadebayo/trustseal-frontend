import 'package:flutter/material.dart';
import 'package:trustseal_app/core/services/auth_manager.dart';

class AuthErrorHandler {
  static void handleAuthError(BuildContext context, dynamic error) {
    String title;
    String message;
    IconData icon;
    Color color;

    if (error is PermissionDeniedException) {
      title = 'Access Denied';
      message = 'You do not have permission to access this feature.';
      icon = Icons.lock_outline;
      color = Colors.red;
    } else if (error is UnauthorizedException) {
      title = 'Authentication Required';
      message = 'Please log in to access this feature.';
      icon = Icons.login;
      color = Colors.orange;
    } else {
      title = 'Authentication Error';
      message = error.toString();
      icon = Icons.error_outline;
      color = Colors.red;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: color, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          if (error is UnauthorizedException)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Go to Login'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showPermissionDeniedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('You do not have permission to access this feature'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void showUnauthorizedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.login, color: Colors.white),
            SizedBox(width: 8),
            Text('Please log in to access this feature'),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
    );
  }
}

class RoleBasedButton extends StatelessWidget {
  final Widget child;
  final List<String> requiredRoles;
  final VoidCallback? onPressed;
  final VoidCallback? onPermissionDenied;

  const RoleBasedButton({
    super.key,
    required this.child,
    required this.requiredRoles,
    this.onPressed,
    this.onPermissionDenied,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final hasPermission = snapshot.data ?? false;

        if (hasPermission) {
          return child;
        } else {
          return GestureDetector(
            onTap: () {
              if (onPermissionDenied != null) {
                onPermissionDenied!();
              } else {
                AuthErrorHandler.showPermissionDeniedSnackBar(context);
              }
            },
            child: Opacity(opacity: 0.5, child: child),
          );
        }
      },
    );
  }

  Future<bool> _hasPermission() async {
    for (final role in requiredRoles) {
      if (await AuthManager.hasPermission(role)) {
        return true;
      }
    }
    return false;
  }
}

class RoleBasedVisibility extends StatelessWidget {
  final Widget child;
  final List<String> requiredRoles;
  final Widget? fallbackWidget;

  const RoleBasedVisibility({
    super.key,
    required this.child,
    required this.requiredRoles,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final hasPermission = snapshot.data ?? false;

        if (hasPermission) {
          return child;
        } else {
          return fallbackWidget ?? const SizedBox.shrink();
        }
      },
    );
  }

  Future<bool> _hasPermission() async {
    for (final role in requiredRoles) {
      if (await AuthManager.hasPermission(role)) {
        return true;
      }
    }
    return false;
  }
}

class AuthStatusWidget extends StatelessWidget {
  const AuthStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthManager.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data == true) {
          return FutureBuilder<String?>(
            future: AuthManager.getUserType(),
            builder: (context, userTypeSnapshot) {
              if (userTypeSnapshot.hasData) {
                final userType = userTypeSnapshot.data!;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(userType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getUserTypeColor(userType).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getUserTypeIcon(userType),
                        size: 16,
                        color: _getUserTypeColor(userType),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getUserTypeLabel(userType),
                        style: TextStyle(
                          color: _getUserTypeColor(userType),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Guest',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case AuthManager.admin:
        return Colors.purple;
      case AuthManager.business:
        return Colors.blue;
      case AuthManager.user:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType) {
      case AuthManager.admin:
        return Icons.admin_panel_settings;
      case AuthManager.business:
        return Icons.business;
      case AuthManager.user:
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case AuthManager.admin:
        return 'Admin';
      case AuthManager.business:
        return 'Business';
      case AuthManager.user:
        return 'User';
      default:
        return 'Guest';
    }
  }
}
