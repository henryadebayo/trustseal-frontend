import 'package:flutter/material.dart';

/// BlockDAG-native wallet connection service for blockchain wallet integration
/// This service handles wallet connections specifically for BlockDAG network
class WalletConnectionService {
  static final WalletConnectionService _instance =
      WalletConnectionService._internal();
  factory WalletConnectionService() => _instance;
  WalletConnectionService._internal();

  String? _connectedWalletAddress;
  String? _connectedWalletType;
  int _currentNetworkId = 1; // BlockDAG Mainnet

  /// BlockDAG Network Configuration
  static const Map<String, Map<String, dynamic>> blockDAGNetworks = {
    'mainnet': {
      'chainId': 1,
      'chainName': 'BlockDAG Mainnet',
      'rpcUrl': 'https://eth.llamarpc.com',
      'explorerUrl': 'https://explorer.blockdag.network',
      'nativeCurrency': {'name': 'BlockDAG', 'symbol': 'BDAG', 'decimals': 18},
    },
    'testnet': {
      'chainId': 2,
      'chainName': 'BlockDAG Testnet',
      'rpcUrl': 'https://testnet.blockdag.network',
      'explorerUrl': 'https://testnet-explorer.blockdag.network',
      'nativeCurrency': {
        'name': 'BlockDAG Testnet',
        'symbol': 'tBDAG',
        'decimals': 18,
      },
    },
  };

  /// Get the currently connected wallet address
  String? get connectedWalletAddress => _connectedWalletAddress;

  /// Get the currently connected wallet type (MetaMask, WalletConnect, etc.)
  String? get connectedWalletType => _connectedWalletType;

  /// Check if a wallet is currently connected
  bool get isWalletConnected => _connectedWalletAddress != null;

  /// Get current network ID
  int get currentNetworkId => _currentNetworkId;

  /// Get current network name
  String get currentNetworkName =>
      _currentNetworkId == 1 ? 'BlockDAG Mainnet' : 'BlockDAG Testnet';

  /// Connect to MetaMask wallet on BlockDAG network
  Future<bool> connectMetaMask() async {
    try {
      // TODO: Implement MetaMask connection for BlockDAG
      // This would typically involve:
      // 1. Checking if MetaMask is installed
      // 2. Requesting account access
      // 3. Switching to BlockDAG network if needed
      // 4. Getting the wallet address
      // 5. Setting up event listeners for account changes

      // Simulate connection for now
      await Future.delayed(const Duration(seconds: 2));

      _connectedWalletAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
      _connectedWalletType = 'MetaMask (BlockDAG)';

      return true;
    } catch (e) {
      debugPrint('MetaMask BlockDAG connection error: $e');
      return false;
    }
  }

  /// Connect to WalletConnect on BlockDAG network
  Future<bool> connectWalletConnect() async {
    try {
      // TODO: Implement WalletConnect connection for BlockDAG
      // This would typically involve:
      // 1. Creating a WalletConnect session
      // 2. Generating QR code for mobile wallet connection
      // 3. Handling the connection response
      // 4. Ensuring BlockDAG network is selected

      // Simulate connection for now
      await Future.delayed(const Duration(seconds: 2));

      _connectedWalletAddress = '0x8ba1f109551bD432803012645Hac136c';
      _connectedWalletType = 'WalletConnect (BlockDAG)';

      return true;
    } catch (e) {
      debugPrint('WalletConnect BlockDAG connection error: $e');
      return false;
    }
  }

  /// Connect to Coinbase Wallet on BlockDAG network
  Future<bool> connectCoinbaseWallet() async {
    try {
      // TODO: Implement Coinbase Wallet connection for BlockDAG

      // Simulate connection for now
      await Future.delayed(const Duration(seconds: 2));

      _connectedWalletAddress = '0x1234567890123456789012345678901234567890';
      _connectedWalletType = 'Coinbase Wallet (BlockDAG)';

      return true;
    } catch (e) {
      debugPrint('Coinbase Wallet BlockDAG connection error: $e');
      return false;
    }
  }

  /// Switch to BlockDAG network
  Future<bool> switchToBlockDAGNetwork({bool useTestnet = false}) async {
    try {
      final network = useTestnet ? 'testnet' : 'mainnet';
      final networkConfig = blockDAGNetworks[network]!;

      // TODO: Implement network switching
      // This would typically involve:
      // 1. Requesting network switch from wallet
      // 2. Adding BlockDAG network if not present
      // 3. Confirming the switch

      _currentNetworkId = networkConfig['chainId'];
      return true;
    } catch (e) {
      debugPrint('BlockDAG network switch error: $e');
      return false;
    }
  }

  /// Disconnect the current wallet
  Future<void> disconnectWallet() async {
    try {
      // TODO: Implement wallet disconnection
      // This would typically involve:
      // 1. Clearing the connection
      // 2. Removing event listeners
      // 3. Resetting state

      _connectedWalletAddress = null;
      _connectedWalletType = null;
    } catch (e) {
      debugPrint('Wallet disconnection error: $e');
    }
  }

  /// Get wallet balance (in BDAG)
  Future<String> getWalletBalance() async {
    if (!isWalletConnected) {
      throw Exception('No wallet connected');
    }

    try {
      // TODO: Implement balance fetching for BlockDAG
      // This would typically involve:
      // 1. Making RPC calls to BlockDAG network
      // 2. Getting BDAG balance
      // 3. Converting wei to BDAG
      // 4. Formatting the result

      // Simulate balance for now
      return '2.5 BDAG';
    } catch (e) {
      debugPrint('BlockDAG balance fetch error: $e');
      return '0 BDAG';
    }
  }

  /// Sign a message with the connected wallet
  Future<String> signMessage(String message) async {
    if (!isWalletConnected) {
      throw Exception('No wallet connected');
    }

    try {
      // TODO: Implement message signing for BlockDAG
      // This would typically involve:
      // 1. Requesting signature from wallet
      // 2. Returning the signed message

      // Simulate signing for now
      return '0x${message.hashCode.toRadixString(16)}';
    } catch (e) {
      debugPrint('BlockDAG message signing error: $e');
      rethrow;
    }
  }

  /// Send a transaction on BlockDAG network
  Future<String> sendTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    if (!isWalletConnected) {
      throw Exception('No wallet connected');
    }

    try {
      // TODO: Implement transaction sending for BlockDAG
      // This would typically involve:
      // 1. Building the transaction
      // 2. Requesting user confirmation
      // 3. Sending the transaction to BlockDAG network
      // 4. Returning the transaction hash

      // Simulate transaction for now
      return '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    } catch (e) {
      debugPrint('BlockDAG transaction error: $e');
      rethrow;
    }
  }

  /// Listen to wallet account changes
  void onAccountChanged(Function(String) callback) {
    // TODO: Implement account change listener for BlockDAG
    // This would typically involve:
    // 1. Setting up event listeners
    // 2. Calling callback when account changes
  }

  /// Listen to wallet network changes
  void onNetworkChanged(Function(int) callback) {
    // TODO: Implement network change listener for BlockDAG
    // This would typically involve:
    // 1. Setting up event listeners
    // 2. Calling callback when network changes
  }
}

/// BlockDAG Wallet connection dialog widget
class WalletConnectionDialog extends StatelessWidget {
  final Function(String walletType)? onWalletSelected;

  const WalletConnectionDialog({super.key, this.onWalletSelected});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connect to BlockDAG Network',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect your wallet to the BlockDAG blockchain network',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
              child: const Text(
                'BlockDAG Mainnet',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildWalletOption(
              context: context,
              title: 'MetaMask',
              subtitle: 'Connect using MetaMask on BlockDAG',
              icon: Icons.account_balance_wallet,
              color: Colors.orange,
              onTap: () => _connectWallet(context, 'MetaMask'),
            ),
            const SizedBox(height: 12),
            _buildWalletOption(
              context: context,
              title: 'WalletConnect',
              subtitle: 'Connect mobile wallet to BlockDAG',
              icon: Icons.qr_code,
              color: Colors.blue,
              onTap: () => _connectWallet(context, 'WalletConnect'),
            ),
            const SizedBox(height: 12),
            _buildWalletOption(
              context: context,
              title: 'Coinbase Wallet',
              subtitle: 'Connect Coinbase Wallet to BlockDAG',
              icon: Icons.account_balance,
              color: Colors.blue,
              onTap: () => _connectWallet(context, 'Coinbase Wallet'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _connectWallet(BuildContext context, String walletType) async {
    Navigator.pop(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final walletService = WalletConnectionService();
    bool success = false;

    try {
      switch (walletType) {
        case 'MetaMask':
          success = await walletService.connectMetaMask();
          break;
        case 'WalletConnect':
          success = await walletService.connectWalletConnect();
          break;
        case 'Coinbase Wallet':
          success = await walletService.connectCoinbaseWallet();
          break;
      }
    } catch (e) {
      debugPrint('Wallet connection error: $e');
    }

    // Hide loading dialog
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully connected to $walletType'),
          backgroundColor: Colors.green,
        ),
      );
      onWalletSelected?.call(walletType);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to $walletType'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
