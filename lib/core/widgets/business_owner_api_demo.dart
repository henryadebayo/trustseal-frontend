import 'package:flutter/material.dart';
import 'package:trustseal_app/core/services/business_owner_service.dart';
import 'package:trustseal_app/core/services/blockdag_service.dart';

class BusinessOwnerApiDemo extends StatefulWidget {
  const BusinessOwnerApiDemo({super.key});

  @override
  State<BusinessOwnerApiDemo> createState() => _BusinessOwnerApiDemoState();
}

class _BusinessOwnerApiDemoState extends State<BusinessOwnerApiDemo> {
  final BusinessOwnerService _businessService = BusinessOwnerService();
  final BlockDAGService _blockDAGService = BlockDAGService();

  bool _isLoading = false;
  Map<String, dynamic>? _projects;
  Map<String, dynamic>? _applications;
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _networkHealth;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all business owner data
      final results = await Future.wait([
        _businessService.getProjects(),
        _businessService.getApplications(),
        _businessService.getAnalytics(),
        _blockDAGService.getNetworkHealth(),
      ]);

      setState(() {
        _projects = results[0] as Map<String, dynamic>;
        _applications = results[1] as Map<String, dynamic>;
        _analytics = results[2] as Map<String, dynamic>;
        _networkHealth = results[3] as Map<String, dynamic>;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Owner API Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNetworkHealthCard(),
          const SizedBox(height: 16),
          _buildAnalyticsCard(),
          const SizedBox(height: 16),
          _buildProjectsCard(),
          const SizedBox(height: 16),
          _buildApplicationsCard(),
        ],
      ),
    );
  }

  Widget _buildNetworkHealthCard() {
    final health = _networkHealth?['data']?['health'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.network_check, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'BlockDAG Network Health',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (health != null) ...[
              _buildInfoRow('Status', health['status'] ?? 'Unknown'),
              _buildInfoRow(
                'Block Height',
                health['blockHeight']?.toString() ?? 'Unknown',
              ),
              _buildInfoRow(
                'Gas Price',
                '${health['gasPrice'] ?? 'Unknown'} ETH',
              ),
              _buildInfoRow(
                'Response Time',
                '${health['responseTime'] ?? 'Unknown'}ms',
              ),
            ] else
              const Text('No network data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    final analytics = _analytics?['data'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Business Analytics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (analytics != null) ...[
              _buildInfoRow(
                'Total Projects',
                analytics['projects']?['total']?.toString() ?? '0',
              ),
              _buildInfoRow(
                'Verified Projects',
                analytics['projects']?['verified']?.toString() ?? '0',
              ),
              _buildInfoRow(
                'Pending Projects',
                analytics['projects']?['pending']?.toString() ?? '0',
              ),
              _buildInfoRow(
                'Total Applications',
                analytics['applications']?['total']?.toString() ?? '0',
              ),
            ] else
              const Text('No analytics data available'),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsCard() {
    final projects = _projects?['data'] as List?;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Projects (${projects?.length ?? 0})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (projects != null && projects.isNotEmpty)
              ...projects.take(3).map((project) => _buildProjectItem(project))
            else
              const Text('No projects found'),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsCard() {
    final applications = _applications?['data'] as List?;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Applications (${applications?.length ?? 0})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (applications != null && applications.isNotEmpty)
              ...applications
                  .take(3)
                  .map((application) => _buildApplicationItem(application))
            else
              const Text('No applications found'),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project['name'] ?? 'Unknown Project',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  project['description'] ?? 'No description',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(project['verificationStatus']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              project['verificationStatus'] ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationItem(Map<String, dynamic> application) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application['projectName'] ?? 'Unknown Project',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Type: ${application['applicationType'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(application['status']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              application['status'] ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'under_review':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'submitted':
        return Colors.blue;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
