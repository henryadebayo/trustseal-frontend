import 'package:flutter/material.dart';
import 'package:trustseal_app/core/services/vault_service.dart';
import 'package:trustseal_app/core/services/auth_manager.dart';

class VaultManagementScreen extends StatefulWidget {
  const VaultManagementScreen({super.key});

  @override
  State<VaultManagementScreen> createState() => _VaultManagementScreenState();
}

class _VaultManagementScreenState extends State<VaultManagementScreen>
    with TickerProviderStateMixin {
  final VaultService _vaultService = VaultService();

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _files = [];
  Map<String, dynamic>? _vaultStatus;
  bool _isLoading = true;
  String _selectedTab = 'transactions';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await AuthManager.getUserData();
      final userId = userData?['id'];

      if (userId != null) {
        // Load transactions for this receiver
        final transactionsResponse = await _vaultService
            .getReceiverTransactions(userId);
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(
            transactionsResponse['data'] ?? [],
          );
        });

        // Load files for this receiver
        final filesResponse = await _vaultService.getReceiverFiles();
        setState(() {
          _files = List<Map<String, dynamic>>.from(filesResponse['data'] ?? []);
        });
      }

      // Load vault status
      final statusResponse = await _vaultService.getVaultStatus();
      setState(() {
        _vaultStatus = statusResponse['data'];
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load vault data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadFile(String transactionId) async {
    try {
      final result = await _vaultService.downloadFromVault(
        transactionId: transactionId,
      );

      // Show download success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('File Downloaded'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('File decrypted and downloaded successfully!'),
              const SizedBox(height: 8),
              Text('File Name: ${result['fileName']}'),
              const SizedBox(height: 8),
              Text('File Size: ${result['fileSize']} bytes'),
              const SizedBox(height: 8),
              const Text('Content Preview:'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result['content'] ?? 'No content preview available',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault Management'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF1E293B)],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: Column(
            children: [
              // Status Header
              _buildStatusHeader(),

              // Tab Bar
              _buildTabBar(),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _selectedTab == 'transactions'
                    ? _buildTransactionsList()
                    : _buildFilesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.security, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Secure Vault Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_vaultStatus != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusItem(
                  'Total Transactions',
                  '${_vaultStatus!['totalTransactions'] ?? 0}',
                  Icons.receipt_long,
                ),
                _buildStatusItem(
                  'Active Senders',
                  '${_vaultStatus!['activeSenders'] ?? 0}',
                  Icons.person,
                ),
                _buildStatusItem(
                  'Active Receivers',
                  '${_vaultStatus!['activeReceivers'] ?? 0}',
                  Icons.admin_panel_settings,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'transactions',
              'Transactions',
              Icons.receipt_long,
            ),
          ),
          Expanded(child: _buildTabButton('files', 'Files', Icons.folder)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label, IconData icon) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Transaction ${transaction['id']?.substring(0, 8) ?? 'Unknown'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Encrypted',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTransactionInfo('Sender', transaction['senderId'] ?? 'Unknown'),
          _buildTransactionInfo(
            'File Hash',
            transaction['fileHash'] ?? 'Unknown',
          ),
          _buildTransactionInfo(
            'Created',
            _formatDate(transaction['createdAt']),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _downloadFile(transaction['id']),
              icon: const Icon(Icons.download),
              label: const Text('Download & Decrypt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList() {
    if (_files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No files available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        return _buildFileCard(file);
      },
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.file_present, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  file['fileName'] ?? 'Unknown File',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Encrypted',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTransactionInfo('Size', '${file['fileSize'] ?? 0} bytes'),
          _buildTransactionInfo('Status', file['status'] ?? 'Unknown'),
          _buildTransactionInfo('Uploaded', _formatDate(file['uploadedAt'])),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
