import 'package:trustseal_app/core/services/api_service.dart';

class AuthService {
  final ApiService _api = ApiService.instance;

  // User registration
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
    return await _api.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      userType: userType,
    );
  }

  // User login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _api.login(email: email, password: password);
  }

  // Wallet connection
  Future<Map<String, dynamic>> connectWallet({
    required String walletAddress,
    required String signature,
    required String message,
  }) async {
    return await _api.connectWallet(
      walletAddress: walletAddress,
      signature: signature,
      message: message,
    );
  }

  // Google OAuth sign-in
  Future<Map<String, dynamic>> googleSignIn({required String idToken}) async {
    return await _api.googleSignIn(idToken: idToken);
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _api.getUserProfile();
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    return await _api.refreshToken();
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    return await _api.logout();
  }

  // Check authentication status
  bool get isAuthenticated => _api.isAuthenticated;

  // Get current token
  String? get token => _api.token;
}
