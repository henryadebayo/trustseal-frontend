import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Simplified smart contract service that delegates to backend
/// The backend handles blockchain interaction since Flutter web3 packages
/// have compatibility issues with BlockDAG network
class SmartContractService {
  // Backend API will handle blockchain interactions
  final String baseUrl;

  SmartContractService({required this.baseUrl});

  /// Get authentication headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Create a blockchain transaction for vault file upload
  /// This sends request to backend which interacts with BlockDAG smart contract
  Future<Map<String, dynamic>> createVaultTransaction({
    required String receiverAddress,
    required String ipfsHash,
    required String encryptedFileKey,
    List<int>? encryptionMetadata,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/vault/blockchain/create-transaction'),
        headers: headers,
        body: json.encode({
          'receiverAddress': receiverAddress,
          'ipfsHash': ipfsHash,
          'encryptedFileKey': encryptedFileKey,
          'encryptionMetadata': encryptionMetadata,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to create blockchain transaction: ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating blockchain transaction: $e');
      rethrow;
    }
  }

  /// Get receiver's public key from blockchain (via backend)
  Future<String> getReceiverPublicKey(String receiverAddress) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/v1/vault/blockchain/public-key?receiver=$receiverAddress',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['publicKey'] as String;
      } else {
        throw Exception('Failed to get public key: ${response.body}');
      }
    } catch (e) {
      print('Error getting public key: $e');
      rethrow;
    }
  }

  /// Get transaction details from blockchain (via backend)
  Future<Map<String, dynamic>> getTransactionDetails(String txHash) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/vault/blockchain/transaction/$txHash'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get transaction details: ${response.body}');
      }
    } catch (e) {
      print('Error getting transaction details: $e');
      rethrow;
    }
  }
}
