import 'package:trustseal_app/core/services/api_service.dart';

class BlockDAGService {
  final ApiService _api = ApiService.instance;

  // Get BlockDAG network health
  Future<Map<String, dynamic>> getNetworkHealth() async {
    return await _api.getBlockDAGNetworkHealth();
  }

  // Verify BlockDAG contract
  Future<Map<String, dynamic>> verifyContract(String address) async {
    return await _api.verifyBlockDAGContract(address);
  }

  // Get contract features
  Future<Map<String, dynamic>> getContractFeatures(String address) async {
    return await _api.getBlockDAGContractFeatures(address);
  }

  // Get transaction history
  Future<Map<String, dynamic>> getTransactionHistory(
    String address, {
    int? limit,
    int? offset,
  }) async {
    return await _api.getBlockDAGTransactionHistory(
      address,
      limit: limit,
      offset: offset,
    );
  }

  // Helper method to check if contract is verified
  Future<bool> isContractVerified(String address) async {
    try {
      final response = await verifyContract(address);
      if (response['status'] == 'success' && response['data'] != null) {
        final contract = response['data']['contract'];
        return contract?['verified'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Helper method to get contract features summary
  Future<List<String>> getContractFeaturesSummary(String address) async {
    try {
      final response = await getContractFeatures(address);
      if (response['status'] == 'success' && response['data'] != null) {
        final features = response['data']['features'] as List?;
        return features?.map((f) => f['name'] as String).toList() ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Helper method to get network status
  Future<String> getNetworkStatus() async {
    try {
      final response = await getNetworkHealth();
      if (response['status'] == 'success' && response['data'] != null) {
        final health = response['data']['health'];
        return health?['status'] ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      return 'error';
    }
  }
}
