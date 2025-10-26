import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trustseal_app/core/services/api_service.dart';

class VaultService {
  static const String _baseUrl = 'http://localhost:3000/api/v1/vault';

  // Setup receiver (Admin only)
  Future<Map<String, dynamic>> setupReceiver({
    required String receiverId,
  }) async {
    return await ApiService.instance.vaultSetupReceiver(receiverId: receiverId);
  }

  // Get receiver's public key
  Future<Map<String, dynamic>> getReceiverPublicKey(String receiverId) async {
    return await ApiService.instance.vaultGetReceiverPublicKey(receiverId);
  }

  // Upload file to vault (Business users)
  Future<Map<String, dynamic>> uploadToVault({
    required dynamic file, // Changed from File to dynamic for web compatibility
    required String receiverId,
    String? description,
  }) async {
    final uri = Uri.parse('$_baseUrl/upload');
    final request = http.MultipartRequest('POST', uri);

    // Add authentication header
    final token = await ApiService.instance.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add file - handle both File (mobile) and _MockFile (web)
    String fileName;
    if (file is File) {
      // Mobile: use file path
      fileName = file.path.split('/').last;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    } else {
      // Web: use file bytes
      final bytes = await file.readAsBytes();
      fileName = file.path.split('/').last;
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );
    }

    // Add form fields - according to backend, payload should have: file, receiverId, fileName
    request.fields['receiverId'] = receiverId;
    request.fields['fileName'] = fileName;
    if (description != null) {
      request.fields['description'] = description;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📤 Upload Response Status: ${response.statusCode}');
    print('📤 Upload Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);
      print('❌ Upload Error: ${errorBody}');
      throw Exception(errorBody['message'] ?? 'Upload failed');
    }
  }

  // Download and decrypt file (Admin)
  Future<Map<String, dynamic>> downloadFromVault({
    required String transactionId,
  }) async {
    return await ApiService.instance.vaultDownloadFromVault(
      transactionId: transactionId,
    );
  }

  // Get receiver's transactions (Admin)
  Future<Map<String, dynamic>> getReceiverTransactions(
    String receiverId,
  ) async {
    return await ApiService.instance.vaultGetReceiverTransactions(receiverId);
  }

  // Get files uploaded by sender (Business)
  Future<Map<String, dynamic>> getSenderFiles() async {
    return await ApiService.instance.vaultGetSenderFiles();
  }

  // Get files for receiver (Admin)
  Future<Map<String, dynamic>> getReceiverFiles() async {
    return await ApiService.instance.vaultGetReceiverFiles();
  }

  // Get vault system status
  Future<Map<String, dynamic>> getVaultStatus() async {
    return await ApiService.instance.vaultGetStatus();
  }

  // Get available receivers for file upload
  Future<List<Map<String, dynamic>>> getAvailableReceivers() async {
    try {
      // For now, return mock data since we don't have a dedicated endpoint
      return [
        {
          'id': 'admin-uuid',
          'name': 'Admin Auditor',
          'email': 'admin@trustseal.com',
          'publicKey': 'available',
        },
        {
          'id': 'auditor-1',
          'name': 'Senior Auditor',
          'email': 'auditor1@trustseal.com',
          'publicKey': 'available',
        },
      ];
    } catch (e) {
      // Return mock data for testing
      return [
        {
          'id': 'admin-uuid',
          'name': 'Admin Auditor',
          'email': 'admin@trustseal.com',
          'publicKey': 'available',
        },
        {
          'id': 'auditor-1',
          'name': 'Senior Auditor',
          'email': 'auditor1@trustseal.com',
          'publicKey': 'available',
        },
      ];
    }
  }
}
