import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_manager.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const String healthUrl = 'http://localhost:3000/health';

  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  ApiService._();

  String? _token;
  String? _refreshToken;

  // Initialize with stored tokens
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Save tokens to storage
  Future<void> _saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('refresh_token', refreshToken);
    _token = token;
    _refreshToken = refreshToken;
  }

  // Clear tokens from storage
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    _token = null;
    _refreshToken = null;
  }

  // Get headers with authentication
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Handle API response with role-based error handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);

      // Handle role-based access control errors
      if (response.statusCode == 403) {
        throw PermissionDeniedException();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ApiException(
          message: errorBody['message'] ?? 'An error occurred',
          statusCode: response.statusCode,
          error: errorBody['error'],
        );
      }
    }
  }

  // Make authenticated request
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = {
      ..._getHeaders(includeAuth: includeAuth),
      ...?headers,
    };

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: requestHeaders);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: requestHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: requestHeaders,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: requestHeaders);
        break;
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    return _handleResponse(response);
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(Uri.parse(healthUrl));
    return _handleResponse(response);
  }

  // Authentication methods
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
    final response = await _makeRequest(
      'POST',
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'userType': userType,
      },
      includeAuth: false,
    );

    // Save tokens if registration successful
    if (response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null && data['refreshToken'] != null) {
        await _saveTokens(data['token'], data['refreshToken']);

        // Store user data with AuthManager
        final userData = data['user'];
        if (userData != null) {
          await AuthManager.storeUserData(
            id: userData['id'],
            email: userData['email'],
            userType: userData['userType'],
            token: data['token'],
            firstName: userData['firstName'],
            lastName: userData['lastName'],
          );
        }
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
      includeAuth: false,
    );

    // Save tokens if login successful
    if (response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null && data['refreshToken'] != null) {
        await _saveTokens(data['token'], data['refreshToken']);

        // Store user data with AuthManager
        final userData = data['user'];
        if (userData != null) {
          await AuthManager.storeUserData(
            id: userData['id'],
            email: userData['email'],
            userType: userData['userType'],
            token: data['token'],
            firstName: userData['firstName'],
            lastName: userData['lastName'],
          );
        }
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> connectWallet({
    required String walletAddress,
    required String signature,
    required String message,
  }) async {
    return await _makeRequest(
      'POST',
      '/auth/wallet/connect',
      body: {
        'walletAddress': walletAddress,
        'signature': signature,
        'message': message,
      },
    );
  }

  Future<Map<String, dynamic>> googleSignIn({required String idToken}) async {
    final response = await _makeRequest(
      'POST',
      '/auth/google/signin',
      body: {'idToken': idToken},
      includeAuth: false,
    );

    // Save tokens if sign-in successful
    if (response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null && data['refreshToken'] != null) {
        await _saveTokens(data['token'], data['refreshToken']);
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return await _makeRequest('GET', '/auth/profile');
  }

  Future<Map<String, dynamic>> refreshToken() async {
    if (_refreshToken == null) {
      throw ApiException(message: 'No refresh token available');
    }

    final response = await _makeRequest(
      'POST',
      '/auth/refresh',
      body: {'refreshToken': _refreshToken},
      includeAuth: false,
    );

    // Update tokens
    if (response['data'] != null) {
      final data = response['data'];
      if (data['token'] != null && data['refreshToken'] != null) {
        await _saveTokens(data['token'], data['refreshToken']);
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await _makeRequest('POST', '/auth/logout');
    } finally {
      await clearTokens();
      await AuthManager.clearUserData(); // Clear user data from AuthManager
    }

    return {'status': 'success', 'message': 'Logged out successfully'};
  }

  // Business Owner APIs
  Future<Map<String, dynamic>> getBusinessOwnerProjects({
    String? status,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return await _makeRequest('GET', '/business/owner/projects$queryString');
  }

  Future<Map<String, dynamic>> createProject({
    required String name,
    required String description,
    required String website,
    required String contractAddress,
    required String tokenSymbol,
    required String tokenName,
    String network = 'blockdag',
    Map<String, dynamic>? teamInfo,
    Map<String, dynamic>? financialInfo,
    Map<String, dynamic>? communityInfo,
  }) async {
    return await _makeRequest(
      'POST',
      '/business/owner/projects',
      body: {
        'name': name,
        'description': description,
        'website': website,
        'contractAddress': contractAddress,
        'tokenSymbol': tokenSymbol,
        'tokenName': tokenName,
        'network': network,
        if (teamInfo != null) 'teamInfo': teamInfo,
        if (financialInfo != null) 'financialInfo': financialInfo,
        if (communityInfo != null) 'communityInfo': communityInfo,
      },
    );
  }

  Future<Map<String, dynamic>> getBusinessOwnerApplications({
    String? status,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return await _makeRequest(
      'GET',
      '/business/owner/applications$queryString',
    );
  }

  Future<Map<String, dynamic>> createApplication({
    required String projectId,
    required String applicationType,
    required Map<String, dynamic> submissionData,
  }) async {
    return await _makeRequest(
      'POST',
      '/business/owner/applications',
      body: {
        'projectId': projectId,
        'applicationType': applicationType,
        'submissionData': submissionData,
      },
    );
  }

  Future<Map<String, dynamic>> submitApplication({
    required String applicationId,
    required Map<String, dynamic> submissionData,
  }) async {
    return await _makeRequest(
      'PUT',
      '/business/owner/applications/$applicationId/submit',
      body: {'submissionData': submissionData},
    );
  }

  Future<Map<String, dynamic>> getApplicationDetails(
    String applicationId,
  ) async {
    return await _makeRequest(
      'GET',
      '/business/owner/applications/$applicationId',
    );
  }

  Future<Map<String, dynamic>> getBusinessOwnerAnalytics() async {
    return await _makeRequest('GET', '/business/owner/analytics');
  }

  // BlockDAG Integration APIs
  Future<Map<String, dynamic>> getBlockDAGNetworkHealth() async {
    return await _makeRequest(
      'GET',
      '/blockdag/network/health',
      includeAuth: false,
    );
  }

  Future<Map<String, dynamic>> verifyBlockDAGContract(String address) async {
    return await _makeRequest(
      'GET',
      '/blockdag/contracts/$address/verify',
      includeAuth: false,
    );
  }

  Future<Map<String, dynamic>> getBlockDAGContractFeatures(
    String address,
  ) async {
    return await _makeRequest(
      'GET',
      '/blockdag/contracts/$address/features',
      includeAuth: false,
    );
  }

  Future<Map<String, dynamic>> getBlockDAGTransactionHistory(
    String address, {
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return await _makeRequest(
      'GET',
      '/blockdag/transactions/$address/history$queryString',
      includeAuth: false,
    );
  }

  // File Upload APIs
  Future<Map<String, dynamic>> uploadFiles({
    required List<File> files,
    required String category,
    String? projectId,
    String? applicationId,
  }) async {
    final uri = Uri.parse('$baseUrl/files/upload');
    final request = http.MultipartRequest('POST', uri);

    // Add headers
    request.headers.addAll(_getHeaders());
    request.headers.remove('Content-Type'); // Let multipart handle this

    // Add files
    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    // Add form fields
    request.fields['category'] = category;
    if (projectId != null) request.fields['projectId'] = projectId;
    if (applicationId != null) request.fields['applicationId'] = applicationId;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getFileDetails(String fileId) async {
    return await _makeRequest('GET', '/files/$fileId');
  }

  Future<Map<String, dynamic>> deleteFile(String fileId) async {
    return await _makeRequest('DELETE', '/files/$fileId');
  }

  Future<Map<String, dynamic>> getProjectFiles(
    String projectId, {
    String? category,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return await _makeRequest('GET', '/files/project/$projectId$queryString');
  }

  Future<Map<String, dynamic>> getFileCategories() async {
    return await _makeRequest('GET', '/files/categories/list');
  }

  // Vault API methods
  Future<Map<String, dynamic>> vaultSetupReceiver({
    required String receiverId,
  }) async {
    return await _makeRequest(
      'POST',
      '/vault/receiver/setup',
      body: {'receiverId': receiverId},
    );
  }

  Future<Map<String, dynamic>> vaultGetReceiverPublicKey(
    String receiverId,
  ) async {
    return await _makeRequest(
      'GET',
      '/vault/receiver/$receiverId/public-key',
      includeAuth: false,
    );
  }

  Future<Map<String, dynamic>> vaultDownloadFromVault({
    required String transactionId,
  }) async {
    return await _makeRequest('POST', '/vault/download/$transactionId');
  }

  Future<Map<String, dynamic>> vaultGetReceiverTransactions(
    String receiverId,
  ) async {
    return await _makeRequest(
      'GET',
      '/vault/receiver/$receiverId/transactions',
    );
  }

  Future<Map<String, dynamic>> vaultGetSenderFiles() async {
    return await _makeRequest('GET', '/vault/files/sender');
  }

  Future<Map<String, dynamic>> vaultGetReceiverFiles() async {
    return await _makeRequest('GET', '/vault/files/receiver');
  }

  Future<Map<String, dynamic>> vaultGetStatus() async {
    return await _makeRequest('GET', '/vault/status', includeAuth: false);
  }

  // Check if user is authenticated
  bool get isAuthenticated => _token != null;

  // Get current token
  String? get token => _token;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;

  ApiException({required this.message, this.statusCode, this.error});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${error != null ? ' - $error' : ''}';
  }
}
