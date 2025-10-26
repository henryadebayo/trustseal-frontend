import 'package:flutter/material.dart';
import 'package:trustseal_app/core/constants/app_constants.dart';
import '../../domain/entities/admin_entity.dart';
import '../../../business_owners/data/models/project_application_model.dart';
import '../../../business_owners/domain/entities/project_application_entity/project_application_entity.dart';
import '../../data/services/admin_service.dart';

class ApplicationReviewScreen extends StatefulWidget {
  final AdminService service;

  const ApplicationReviewScreen({super.key, required this.service});

  @override
  State<ApplicationReviewScreen> createState() =>
      _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  List<ProjectApplicationModel> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final applications = await widget.service.getApplicationsForReview();
      setState(() {
        _applications = applications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading applications: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Application Reviews'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApplications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadApplications,
              child: _applications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: AppConstants.paddingM),
                          Text(
                            'No Applications to Review',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: AppConstants.paddingS),
                          Text(
                            'All applications have been reviewed',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      itemCount: _applications.length,
                      itemBuilder: (context, index) {
                        final application = _applications[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.paddingM,
                          ),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusM,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                application.projectName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(application.projectDescription),
                                  const SizedBox(height: AppConstants.paddingS),
                                  Row(
                                    children: [
                                      _buildStatusChip(application.status),
                                      const Spacer(),
                                      Text(
                                        'Submitted: ${_formatDate(application.submittedAt)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _showReviewDialog(application),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status) {
    Color color;
    String label;

    switch (status) {
      case ApplicationStatus.submitted:
        color = Colors.blue;
        label = 'Submitted';
        break;
      case ApplicationStatus.underReview:
        color = Colors.orange;
        label = 'Under Review';
        break;
      case ApplicationStatus.approved:
        color = Colors.green;
        label = 'Approved';
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
      case ApplicationStatus.requiresChanges:
        color = Colors.amber;
        label = 'Requires Changes';
        break;
      case ApplicationStatus.draft:
        color = Colors.grey;
        label = 'Draft';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  void _showReviewDialog(ProjectApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Review: ${application.projectName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${application.projectDescription}'),
            const SizedBox(height: AppConstants.paddingM),
            Text('Website: ${application.website}'),
            const SizedBox(height: AppConstants.paddingM),
            Text(
              'Token: ${application.tokenSymbol} (${application.tokenName})',
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text('Contract: ${application.contractAddress}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _approveApplication(application);
            },
            child: const Text('Approve'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectApplication(application);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveApplication(ProjectApplicationModel application) async {
    try {
      await widget.service.createReview(
        applicationId: application.id,
        adminId: 'admin_1', // Mock admin ID
        status: ReviewStatus.approved,
        reviewNotes: 'Application approved after review',
        verificationScore: 85,
      );

      await widget.service.logAdminAction(
        adminId: 'admin_1',
        action: 'approve_application',
        targetType: 'application',
        targetId: application.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application approved successfully')),
        );
        _loadApplications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving application: $e')),
        );
      }
    }
  }

  Future<void> _rejectApplication(ProjectApplicationModel application) async {
    try {
      await widget.service.createReview(
        applicationId: application.id,
        adminId: 'admin_1', // Mock admin ID
        status: ReviewStatus.rejected,
        reviewNotes: 'Application rejected due to insufficient information',
        verificationScore: 30,
      );

      await widget.service.logAdminAction(
        adminId: 'admin_1',
        action: 'reject_application',
        targetType: 'application',
        targetId: application.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Application rejected')));
        _loadApplications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting application: $e')),
        );
      }
    }
  }
}
