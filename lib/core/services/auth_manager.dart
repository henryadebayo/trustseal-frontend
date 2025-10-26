import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';

  // User types from backend
  static const String admin = 'admin';
  static const String business = 'business';
  static const String user = 'user';

  // Access control mapping
  static const Map<String, List<String>> accessLevels = {
    admin: ['admin'],
    business: ['business'],
    user: ['public'],
  };

  // Store user data after successful authentication
  static Future<void> storeUserData({
    required String id,
    required String email,
    required String userType,
    required String token,
    String? firstName,
    String? lastName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = {
      'id': id,
      'email': email,
      'userType': userType,
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'loginTime': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_userKey, userData.toString());
    await prefs.setString(_tokenKey, token);
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);

    if (userDataString == null) return null;

    try {
      // Parse the stored user data
      // Note: In a real app, you'd use proper JSON serialization
      final userData = <String, dynamic>{};
      final parts = userDataString
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(', ');

      for (final part in parts) {
        final keyValue = part.split(': ');
        if (keyValue.length == 2) {
          userData[keyValue[0]] = keyValue[1];
        }
      }

      return userData;
    } catch (e) {
      return null;
    }
  }

  // Get current token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user type
  static Future<String?> getUserType() async {
    final userData = await getUserData();
    return userData?['userType'];
  }

  // Check if user has permission for a specific role
  static Future<bool> hasPermission(String requiredRole) async {
    final userType = await getUserType();
    if (userType == null) return false;

    final allowedRoles = accessLevels[userType] ?? [];
    return allowedRoles.contains(requiredRole);
  }

  // Check if user is admin
  static Future<bool> isAdmin() async {
    final userType = await getUserType();
    return userType == admin;
  }

  // Check if user is business owner
  static Future<bool> isBusinessOwner() async {
    final userType = await getUserType();
    return userType == business;
  }

  // Check if user is regular user
  static Future<bool> isRegularUser() async {
    final userType = await getUserType();
    return userType == user;
  }

  // Clear user data (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  // Get user display name
  static Future<String> getUserDisplayName() async {
    final userData = await getUserData();
    if (userData == null) return 'Guest';

    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else {
      return userData['email'] ?? 'User';
    }
  }

  // Get user type display name
  static Future<String> getUserTypeDisplayName() async {
    final userType = await getUserType();

    switch (userType) {
      case admin:
        return 'Platform Administrator';
      case business:
        return 'Business Owner';
      case user:
        return 'Community Member';
      default:
        return 'Guest';
    }
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, [this.statusCode]);

  @override
  String toString() {
    return 'AuthException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class PermissionDeniedException extends AuthException {
  PermissionDeniedException() : super('Insufficient permissions', 403);
}

class UnauthorizedException extends AuthException {
  UnauthorizedException() : super('Authentication required', 401);
}
