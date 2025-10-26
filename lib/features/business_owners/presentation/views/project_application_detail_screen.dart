import 'package:flutter/material.dart';
import '../../data/models/project_application_model.dart';
import '../../domain/entities/project_application_entity/project_application_entity.dart';

class ProjectApplicationDetailScreen extends StatefulWidget {
  final ProjectApplicationModel application;

  const ProjectApplicationDetailScreen({super.key, required this.application});

  @override
  State<ProjectApplicationDetailScreen> createState() =>
      _ProjectApplicationDetailScreenState();
}

class _ProjectApplicationDetailScreenState
    extends State<ProjectApplicationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.application.projectName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareApplication,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Edit Application'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_outlined),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildStatusSection(),
            _buildProgressSection(),
            _buildDetailsSection(),
            _buildDocumentsSection(),
            _buildTimelineSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.application.projectName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.application.tokenName} (${widget.application.tokenSymbol})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(widget.application.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.application.projectDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.language,
                label: 'Website',
                value: widget.application.website,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.account_balance_wallet,
                label: 'Contract',
                value: widget.application.contractAddress,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ApplicationStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.length > 20 ? '${value.substring(0, 20)}...' : value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Status',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  label: 'Submitted',
                  date: widget.application.submittedAt,
                  isCompleted: true,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  label: 'Under Review',
                  date: widget.application.reviewedAt,
                  isCompleted:
                      widget.application.status ==
                          ApplicationStatus.underReview ||
                      widget.application.status == ApplicationStatus.approved,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  label: 'Verified',
                  date: widget.application.status == ApplicationStatus.approved
                      ? widget.application.reviewedAt
                      : null,
                  isCompleted:
                      widget.application.status == ApplicationStatus.approved,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String label,
    required DateTime? date,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.radio_button_unchecked,
            color: isCompleted
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        if (date != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatDate(date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection() {
    final checklist = widget.application.checklist;
    final checks = [
      ('Team Verification', checklist.teamVerificationComplete, Icons.group),
      (
        'Smart Contract Audit',
        checklist.smartContractAuditComplete,
        Icons.security,
      ),
      ('Liquidity Lock', checklist.liquidityLockVerified, Icons.lock),
      (
        'Tokenomics Review',
        checklist.tokenomicsVerified,
        Icons.account_balance_wallet,
      ),
      ('Financial Audit', checklist.financialAuditComplete, Icons.assessment),
      ('Technical Review', checklist.technicalReviewComplete, Icons.code),
      ('Marketing Plan', checklist.marketingPlanApproved, Icons.campaign),
      (
        'Community Guidelines',
        checklist.communityGuidelinesAccepted,
        Icons.groups,
      ),
    ];

    final completedChecks = checks.where((check) => check.$2).length;
    final progress = completedChecks / checks.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verification Progress',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 20),
          ...checks
              .map(
                (check) => _buildCheckItem(
                  title: check.$1,
                  isCompleted: check.$2,
                  icon: check.$3,
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required String title,
    required bool isCompleted,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Project Name', widget.application.projectName),
          _buildDetailRow('Token Symbol', widget.application.tokenSymbol),
          _buildDetailRow('Token Name', widget.application.tokenName),
          _buildDetailRow('Website', widget.application.website),
          _buildDetailRow(
            'Contract Address',
            widget.application.contractAddress,
          ),
          _buildDetailRow(
            'Submitted Date',
            _formatDate(widget.application.submittedAt),
          ),
          if (widget.application.reviewedAt != null)
            _buildDetailRow(
              'Reviewed Date',
              _formatDate(widget.application.reviewedAt!),
            ),
          if (widget.application.reviewNotes != null)
            _buildDetailRow('Review Notes', widget.application.reviewNotes!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documents',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _uploadDocument,
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Upload'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.application.documents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No documents uploaded yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload required documents to complete your application',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...widget.application.documents
                .map((doc) => _buildDocumentItem(doc))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(ApplicationDocumentModel document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getDocumentIcon(document.type),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(document.name),
        subtitle: Text(
          '${document.type} • ${_formatDate(document.uploadedAt)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download_outlined),
          onPressed: () => _downloadDocument(document),
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildTimelineSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            icon: Icons.add_circle_outline,
            title: 'Application Created',
            subtitle: 'Draft application started',
            time: widget.application.submittedAt,
            isFirst: true,
          ),
          _buildTimelineItem(
            icon: Icons.send,
            title: 'Application Submitted',
            subtitle: 'Application submitted for review',
            time: widget.application.submittedAt,
          ),
          if (widget.application.reviewedAt != null)
            _buildTimelineItem(
              icon: Icons.rate_review,
              title: 'Review Started',
              subtitle: 'Application under review',
              time: widget.application.reviewedAt!,
            ),
          if (widget.application.status == ApplicationStatus.approved)
            _buildTimelineItem(
              icon: Icons.verified,
              title: 'Application Verified',
              subtitle: 'Project successfully verified',
              time: widget.application.reviewedAt!,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required DateTime time,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(time),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.application.status == ApplicationStatus.draft)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _editApplication,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ),
          if (widget.application.status == ApplicationStatus.draft)
            const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _viewFullDetails,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Full Details'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  void _shareApplication() {
    // TODO: Implement share functionality
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editApplication();
        break;
      case 'duplicate':
        _duplicateApplication();
        break;
      case 'delete':
        _deleteApplication();
        break;
    }
  }

  void _editApplication() {
    // TODO: Navigate to edit screen
  }

  void _duplicateApplication() {
    // TODO: Implement duplicate functionality
  }

  void _deleteApplication() {
    // TODO: Show delete confirmation dialog
  }

  void _uploadDocument() {
    // TODO: Implement document upload
  }

  void _downloadDocument(ApplicationDocumentModel document) {
    // TODO: Implement document download
  }

  void _viewFullDetails() {
    // TODO: Navigate to full details screen
  }
}
