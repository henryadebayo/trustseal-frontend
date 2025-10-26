import 'package:flutter/material.dart';
import '../../domain/entities/project_application_entity/project_application_entity.dart';

class ApplicationStatusChip extends StatelessWidget {
  final ApplicationStatus status;
  final bool showIcon;

  const ApplicationStatusChip({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case ApplicationStatus.approved:
        color = Colors.green;
        label = 'Approved';
        icon = Icons.verified;
        break;
      case ApplicationStatus.underReview:
        color = Colors.orange;
        label = 'Under Review';
        icon = Icons.hourglass_empty;
        break;
      case ApplicationStatus.draft:
        color = Colors.blue;
        label = 'Draft';
        icon = Icons.edit_outlined;
        break;
      case ApplicationStatus.submitted:
        color = Colors.purple;
        label = 'Submitted';
        icon = Icons.send;
        break;
      case ApplicationStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      case ApplicationStatus.requiresChanges:
        color = Colors.amber;
        label = 'Requires Changes';
        icon = Icons.edit_note;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationProgressIndicator extends StatelessWidget {
  final bool teamVerificationComplete;
  final bool smartContractAuditComplete;
  final bool liquidityLockVerified;
  final bool tokenomicsVerified;
  final bool financialAuditComplete;
  final bool technicalReviewComplete;
  final bool marketingPlanApproved;
  final bool communityGuidelinesAccepted;

  const VerificationProgressIndicator({
    super.key,
    required this.teamVerificationComplete,
    required this.smartContractAuditComplete,
    required this.liquidityLockVerified,
    required this.tokenomicsVerified,
    required this.financialAuditComplete,
    required this.technicalReviewComplete,
    required this.marketingPlanApproved,
    required this.communityGuidelinesAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final checks = [
      ('Team Verification', teamVerificationComplete, Icons.group),
      ('Smart Contract Audit', smartContractAuditComplete, Icons.security),
      ('Liquidity Lock', liquidityLockVerified, Icons.lock),
      ('Tokenomics Review', tokenomicsVerified, Icons.account_balance_wallet),
      ('Financial Audit', financialAuditComplete, Icons.assessment),
      ('Technical Review', technicalReviewComplete, Icons.code),
      ('Marketing Plan', marketingPlanApproved, Icons.campaign),
      ('Community Guidelines', communityGuidelinesAccepted, Icons.groups),
    ];

    final completedChecks = checks.where((check) => check.$2).length;
    final progress = completedChecks / checks.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Verification Progress',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${completedChecks}/${checks.length}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          minHeight: 8,
        ),
        const SizedBox(height: 16),
        ...checks
            .map(
              (check) => _buildCheckItem(
                context,
                title: check.$1,
                isCompleted: check.$2,
                icon: check.$3,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildCheckItem(
    BuildContext context, {
    required String title,
    required bool isCompleted,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted
                ? Colors.green
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isCompleted
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentUploadWidget extends StatefulWidget {
  final Function(List<String>) onFilesSelected;
  final List<String> acceptedTypes;
  final int maxFiles;

  const DocumentUploadWidget({
    super.key,
    required this.onFilesSelected,
    this.acceptedTypes = const ['pdf', 'jpg', 'png', 'doc', 'docx'],
    this.maxFiles = 5,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  final List<String> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Documents',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Accepted formats: ${widget.acceptedTypes.join(', ')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectFiles,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select files',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Maximum ${widget.maxFiles} files',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Selected Files (${_selectedFiles.length}/${widget.maxFiles})',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ..._selectedFiles.map((file) => _buildFileItem(file)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildFileItem(String fileName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getFileIcon(fileName),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(fileName),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _removeFile(fileName),
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _selectFiles() {
    // TODO: Implement file selection
    // For now, add mock files
    if (_selectedFiles.length < widget.maxFiles) {
      setState(() {
        _selectedFiles.add('document_${_selectedFiles.length + 1}.pdf');
      });
      widget.onFilesSelected(_selectedFiles);
    }
  }

  void _removeFile(String fileName) {
    setState(() {
      _selectedFiles.remove(fileName);
    });
    widget.onFilesSelected(_selectedFiles);
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveBackgroundColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
