import 'package:google_sign_in/google_sign_in.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      _currentUser = account;
      return account;
    } catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (error) {
      print('Google Sign-Out Error: $error');
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      _currentUser = account;
      return account;
    } catch (error) {
      print('Google Silent Sign-In Error: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (_currentUser == null) return null;

    try {
      final GoogleSignInAuthentication auth =
          await _currentUser!.authentication;

      return {
        'id': _currentUser!.id,
        'email': _currentUser!.email,
        'name': _currentUser!.displayName,
        'photoUrl': _currentUser!.photoUrl,
        'idToken': auth.idToken,
        'accessToken': auth.accessToken,
      };
    } catch (error) {
      print('Get User Data Error: $error');
      return null;
    }
  }

  String generateWalletAddress(String email) {
    // Generate a deterministic wallet address from email
    // This is a simplified approach - in production, use proper key derivation
    final bytes = utf8.encode(email.toLowerCase());
    final digest = sha256.convert(bytes);
    return '0x${digest.toString().substring(0, 40)}';
  }

  Future<bool> revokeAccess() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
      return true;
    } catch (error) {
      print('Revoke Access Error: $error');
      return false;
    }
  }
}
