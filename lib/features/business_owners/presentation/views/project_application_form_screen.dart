import 'package:flutter/material.dart';
import 'package:trustseal_app/features/business_owners/data/services/business_owners_service.dart';
import 'package:trustseal_app/features/business_owners/data/models/project_application_model.dart';
import 'package:trustseal_app/features/business_owners/domain/entities/project_application_entity/project_application_entity.dart';

class ProjectApplicationFormScreen extends StatefulWidget {
  final BusinessOwnersService service;

  const ProjectApplicationFormScreen({super.key, required this.service});

  @override
  State<ProjectApplicationFormScreen> createState() =>
      _ProjectApplicationFormScreenState();
}

class _ProjectApplicationFormScreenState
    extends State<ProjectApplicationFormScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  final int _totalSteps = 7;

  // Form data
  String _projectName = '';
  String _projectDescription = '';
  String _website = '';
  String _contractAddress = '';
  String _tokenSymbol = '';
  String _tokenName = '';

  // Tokenomics data
  int _totalSupply = 0;
  int _circulatingSupply = 0;
  Map<String, int> _tokenDistribution = {};
  List<Map<String, dynamic>> _vestingSchedules = [];
  bool _liquidityLocked = false;
  int _liquidityLockDuration = 0;
  String _liquidityLockProvider = '';

  // Team data
  List<Map<String, String>> _teamMembers = [];
  bool _teamDoxxed = false;
  String _teamBackground = '';
  List<String> _credentials = [];
  String _linkedinProfile = '';

  // Financial data
  double _fundingRaised = 0;
  List<String> _investors = [];
  String _treasuryAddress = '';
  Map<String, int> _budgetAllocation = {};
  bool _hasAudit = false;
  String _auditReportUrl = '';

  // Technical data
  String _githubRepository = '';
  String _whitepaperUrl = '';
  String _technicalDocumentation = '';
  bool _hasSmartContractAudit = false;
  String _auditProvider = '';
  String _technicalAuditReportUrl = '';
  List<String> _features = [];

  // Marketing data
  String _twitterHandle = '';
  String _telegramGroup = '';
  String _discordServer = '';
  List<String> _socialMediaLinks = [];
  String _marketingStrategy = '';
  int _promotionPoolPercentage = 0;
  String _contentCreatorProgram = '';

  // Review checklist
  bool _teamVerificationComplete = false;
  bool _smartContractAuditComplete = false;
  bool _liquidityLockVerified = false;
  bool _tokenomicsVerified = false;
  bool _financialAuditComplete = false;
  bool _technicalReviewComplete = false;
  bool _marketingPlanApproved = false;
  bool _communityGuidelinesAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Application'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildTokenomicsStep(),
                _buildTeamStep(),
                _buildFinancialStep(),
                _buildTechnicalStep(),
                _buildMarketingStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Project Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about your project and what it aims to achieve.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              label: 'Project Name',
              hint: 'Enter your project name',
              value: _projectName,
              onChanged: (value) => setState(() => _projectName = value),
              validator: (value) =>
                  value?.isEmpty == true ? 'Project name is required' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Project Description',
              hint: 'Describe your project and its goals',
              value: _projectDescription,
              onChanged: (value) => setState(() => _projectDescription = value),
              validator: (value) => value?.isEmpty == true
                  ? 'Project description is required'
                  : null,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Website URL',
              hint: 'https://yourproject.com',
              value: _website,
              onChanged: (value) => setState(() => _website = value),
              validator: (value) {
                if (value?.isEmpty == true) return 'Website URL is required';
                final uri = Uri.tryParse(value!);
                if (uri == null || (!uri.hasScheme || !uri.hasAuthority)) {
                  return 'Please enter a valid URL (e.g., https://example.com)';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Contract Address',
              hint: '0x...',
              value: _contractAddress,
              onChanged: (value) => setState(() => _contractAddress = value),
              validator: (value) => value?.isEmpty == true
                  ? 'Contract address is required'
                  : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Token Symbol',
                    hint: 'BTC',
                    value: _tokenSymbol,
                    onChanged: (value) => setState(() => _tokenSymbol = value),
                    validator: (value) => value?.isEmpty == true
                        ? 'Token symbol is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Token Name',
                    hint: 'Bitcoin',
                    value: _tokenName,
                    onChanged: (value) => setState(() => _tokenName = value),
                    validator: (value) => value?.isEmpty == true
                        ? 'Token name is required'
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenomicsStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tokenomics Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide details about your token distribution and economics.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            // Token Supply Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Token Supply',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Total Supply',
                            hint: '1000000000',
                            value: _totalSupply.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(
                              () => _totalSupply = int.tryParse(value) ?? 0,
                            ),
                            validator: (value) => value?.isEmpty == true
                                ? 'Total supply is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Circulating Supply',
                            hint: '200000000',
                            value: _circulatingSupply.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(
                              () =>
                                  _circulatingSupply = int.tryParse(value) ?? 0,
                            ),
                            validator: (value) => value?.isEmpty == true
                                ? 'Circulating supply is required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Token Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Token Distribution',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTokenDistribution,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_tokenDistribution.isEmpty)
                      const Text('No distribution categories added yet.')
                    else
                      ..._tokenDistribution.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(child: Text(entry.key)),
                              Text('${entry.value}%'),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () =>
                                    _removeTokenDistribution(entry.key),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vesting Schedules
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vesting Schedules',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addVestingSchedule,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_vestingSchedules.isEmpty)
                      const Text('No vesting schedules added yet.')
                    else
                      ..._vestingSchedules.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${entry.value['category']} - ${entry.value['amount']} tokens',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _removeVestingSchedule(entry.key),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Cliff: ${entry.value['cliffPeriod']} days',
                                  ),
                                  Text(
                                    'Duration: ${entry.value['duration']} days',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Liquidity Lock
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liquidity Lock',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Liquidity Locked'),
                      value: _liquidityLocked,
                      onChanged: (value) =>
                          setState(() => _liquidityLocked = value),
                    ),
                    if (_liquidityLocked) ...[
                      _buildTextField(
                        label: 'Lock Duration (months)',
                        hint: '12',
                        value: _liquidityLockDuration.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(
                          () =>
                              _liquidityLockDuration = int.tryParse(value) ?? 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Lock Provider',
                        hint: 'Uniswap, PancakeSwap, etc.',
                        value: _liquidityLockProvider,
                        onChanged: (value) =>
                            setState(() => _liquidityLockProvider = value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Introduce your team members and their backgrounds.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          // Team Members
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Team Members',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTeamMember,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_teamMembers.isEmpty)
                    const Text('No team members added yet.')
                  else
                    ..._teamMembers.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${entry.value['name']} - ${entry.value['role']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () =>
                                          _removeTeamMember(entry.key),
                                    ),
                                  ],
                                ),
                                if (entry.value['linkedin']?.isNotEmpty == true)
                                  Text('LinkedIn: ${entry.value['linkedin']}'),
                                if (entry.value['twitter']?.isNotEmpty == true)
                                  Text('Twitter: ${entry.value['twitter']}'),
                                if (entry.value['bio']?.isNotEmpty == true)
                                  Text('Bio: ${entry.value['bio']}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Team Verification
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Verification',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Team Doxxed'),
                    subtitle: const Text(
                      'Team members have revealed their identities',
                    ),
                    value: _teamDoxxed,
                    onChanged: (value) => setState(() => _teamDoxxed = value),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Team Background',
                    hint: 'Describe your team\'s experience and background',
                    value: _teamBackground,
                    maxLines: 3,
                    onChanged: (value) =>
                        setState(() => _teamBackground = value),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'LinkedIn Company Profile',
                    hint: 'https://linkedin.com/company/yourcompany',
                    value: _linkedinProfile,
                    onChanged: (value) =>
                        setState(() => _linkedinProfile = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Credentials
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credentials',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addCredential,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_credentials.isEmpty)
                    const Text('No credentials added yet.')
                  else
                    ..._credentials.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(entry.value)),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () => _removeCredential(entry.key),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide financial details and audit information.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _buildInfoCard(
                icon: Icons.attach_money,
                title: 'Funding Information',
                description: 'Details about funding raised and investors.',
                onTap: () => _showFundingDialog(),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.account_balance,
                title: 'Treasury Management',
                description: 'Treasury address and budget allocation.',
                onTap: () => _showTreasuryDialog(),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.assessment,
                title: 'Audit Information',
                description: 'Financial audit details and reports.',
                onTap: () => _showAuditDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share technical details and development information.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _buildInfoCard(
                icon: Icons.code,
                title: 'Development',
                description: 'GitHub repository and technical documentation.',
                onTap: () => _showDevelopmentDialog(),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.security,
                title: 'Smart Contract Audit',
                description: 'Audit provider and security reports.',
                onTap: () => _showSecurityDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketingStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marketing & Community',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define your marketing strategy and community presence.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _buildInfoCard(
                icon: Icons.campaign,
                title: 'Marketing Strategy',
                description:
                    'Define your marketing approach and target audience.',
                onTap: () => _showMarketingDialog(),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.groups,
                title: 'Community Channels',
                description: 'Social media and community platform links.',
                onTap: () => _showCommunityDialog(),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.percent,
                title: 'Promotion Pool',
                description:
                    'Configure promotion pool percentage for content creators.',
                onTap: () => _showPromotionPoolDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review & Submit',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review your application and submit for verification.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                // Application Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Summary',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryItem('Project Name', _projectName),
                        _buildSummaryItem('Website', _website),
                        _buildSummaryItem('Token Symbol', _tokenSymbol),
                        _buildSummaryItem(
                          'Total Supply',
                          _totalSupply.toString(),
                        ),
                        _buildSummaryItem(
                          'Team Members',
                          _teamMembers.length.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Verification Checklist
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verification Checklist',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: const Text('Team Verification Complete'),
                          value: _teamVerificationComplete,
                          onChanged: (value) => setState(
                            () => _teamVerificationComplete = value ?? false,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Smart Contract Audit Complete'),
                          value: _smartContractAuditComplete,
                          onChanged: (value) => setState(
                            () => _smartContractAuditComplete = value ?? false,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Liquidity Lock Verified'),
                          value: _liquidityLockVerified,
                          onChanged: (value) => setState(
                            () => _liquidityLockVerified = value ?? false,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Tokenomics Verified'),
                          value: _tokenomicsVerified,
                          onChanged: (value) => setState(
                            () => _tokenomicsVerified = value ?? false,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Financial Audit Complete'),
                          value: _financialAuditComplete,
                          onChanged: (value) => setState(
                            () => _financialAuditComplete = value ?? false,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Technical Review Complete'),
                          value: _technicalReviewComplete,
                          onChanged: (value) => setState(
                            () => _technicalReviewComplete = value ?? false,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Marketing Plan Approved'),
                          value: _marketingPlanApproved,
                          onChanged: (value) => setState(
                            () => _marketingPlanApproved = value ?? false,
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('Community Guidelines Accepted'),
                          value: _communityGuidelinesAccepted,
                          onChanged: (value) => setState(
                            () => _communityGuidelinesAccepted = value ?? false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSubmit() ? _submitApplication : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Submit Application'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Not provided' : value)),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _projectName.isNotEmpty &&
        _website.isNotEmpty &&
        _tokenSymbol.isNotEmpty &&
        _totalSupply > 0 &&
        _teamMembers.isNotEmpty;
  }

  void _submitApplication() async {
    try {
      // Create the application model
      final application = ProjectApplicationModel(
        id: '',
        businessOwnerId: 'current_user', // TODO: Get from auth
        projectName: _projectName,
        projectDescription: _projectDescription,
        website: _website,
        contractAddress: _contractAddress,
        tokenSymbol: _tokenSymbol,
        tokenName: _tokenName,
        status: ApplicationStatus.draft,
        submittedAt: DateTime.now(),
        applicationData: ProjectApplicationDataModel(
          tokenomics: TokenomicsDataModel(
            totalSupply: _totalSupply,
            circulatingSupply: _circulatingSupply,
            distribution: _tokenDistribution,
            vestingSchedules: _vestingSchedules
                .map(
                  (v) => VestingScheduleModel(
                    category: v['category'] as String,
                    amount: v['amount'] as int,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(
                      Duration(days: v['duration'] as int),
                    ),
                    cliffPeriod: v['cliffPeriod'] as int,
                  ),
                )
                .toList(),
            contractAddress: _contractAddress,
            liquidityLocked: _liquidityLocked,
            liquidityLockDuration: _liquidityLockDuration,
            liquidityLockProvider: _liquidityLockProvider,
          ),
          team: TeamDataModel(
            members: _teamMembers
                .map(
                  (m) => TeamMemberModel(
                    name: m['name']!,
                    role: m['role']!,
                    linkedin: m['linkedin']!,
                    twitter: m['twitter']!,
                    bio: m['bio']!,
                  ),
                )
                .toList(),
            teamDoxxed: _teamDoxxed,
            teamBackground: _teamBackground,
            credentials: _credentials,
            linkedinProfile: _linkedinProfile,
          ),
          financial: FinancialDataModel(
            fundingRaised: _fundingRaised.toInt(),
            investors: _investors,
            treasuryAddress: _treasuryAddress,
            budgetAllocation: _budgetAllocation,
            hasAudit: _hasAudit,
            auditReportUrl: _auditReportUrl,
          ),
          technical: TechnicalDataModel(
            githubRepository: _githubRepository,
            whitepaperUrl: _whitepaperUrl,
            technicalDocumentation: _technicalDocumentation,
            hasSmartContractAudit: _hasSmartContractAudit,
            auditProvider: _auditProvider,
            auditReportUrl: _technicalAuditReportUrl,
            features: _features,
          ),
          marketing: MarketingDataModel(
            twitterHandle: _twitterHandle,
            telegramGroup: _telegramGroup,
            discordServer: _discordServer,
            website: _website,
            socialMediaLinks: _socialMediaLinks,
            marketingStrategy: _marketingStrategy,
            promotionPoolPercentage: _promotionPoolPercentage,
            contentCreatorProgram: _contentCreatorProgram,
          ),
        ),
        documents: [],
        checklist: VerificationChecklistModel(
          teamVerificationComplete: _teamVerificationComplete,
          smartContractAuditComplete: _smartContractAuditComplete,
          liquidityLockVerified: _liquidityLockVerified,
          tokenomicsVerified: _tokenomicsVerified,
          financialAuditComplete: _financialAuditComplete,
          technicalReviewComplete: _technicalReviewComplete,
          marketingPlanApproved: _marketingPlanApproved,
          communityGuidelinesAccepted: _communityGuidelinesAccepted,
        ),
      );

      // Save the application
      await widget.service.createApplication(application);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
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
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
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
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < _totalSteps - 1
                  ? _nextStep
                  : _submitApplication,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep < _totalSteps - 1 ? 'Next' : 'Submit Application',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() == true) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Dialog methods (placeholder implementations)
  void _showFundingDialog() {
    // TODO: Implement funding dialog
  }

  void _showTreasuryDialog() {
    // TODO: Implement treasury dialog
  }

  void _showAuditDialog() {
    // TODO: Implement audit dialog
  }

  void _showDevelopmentDialog() {
    // TODO: Implement development dialog
  }

  void _showSecurityDialog() {
    // TODO: Implement security dialog
  }

  void _showMarketingDialog() {
    // TODO: Implement marketing dialog
  }

  void _showCommunityDialog() {
    // TODO: Implement community dialog
  }

  void _showPromotionPoolDialog() {
    // TODO: Implement promotion pool dialog
  }

  // Tokenomics helper methods
  void _addTokenDistribution() {
    final nameController = TextEditingController();
    final percentageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Token Distribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category (e.g., Team, Investors)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: percentageController,
              decoration: const InputDecoration(labelText: 'Percentage'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  percentageController.text.isNotEmpty) {
                setState(() {
                  _tokenDistribution[nameController.text] =
                      int.tryParse(percentageController.text) ?? 0;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeTokenDistribution(String key) {
    setState(() {
      _tokenDistribution.remove(key);
    });
  }

  void _addVestingSchedule() {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final cliffController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Vesting Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cliffController,
              decoration: const InputDecoration(
                labelText: 'Cliff Period (days)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duration (days)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                setState(() {
                  _vestingSchedules.add({
                    'category': categoryController.text,
                    'amount': int.tryParse(amountController.text) ?? 0,
                    'cliffPeriod': int.tryParse(cliffController.text) ?? 0,
                    'duration': int.tryParse(durationController.text) ?? 0,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeVestingSchedule(int index) {
    setState(() {
      _vestingSchedules.removeAt(index);
    });
  }

  // Team helper methods
  void _addTeamMember() {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final linkedinController = TextEditingController();
    final twitterController = TextEditingController();
    final bioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Team Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn URL'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: twitterController,
                decoration: const InputDecoration(labelText: 'Twitter URL'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  roleController.text.isNotEmpty) {
                setState(() {
                  _teamMembers.add({
                    'name': nameController.text,
                    'role': roleController.text,
                    'linkedin': linkedinController.text,
                    'twitter': twitterController.text,
                    'bio': bioController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeTeamMember(int index) {
    setState(() {
      _teamMembers.removeAt(index);
    });
  }

  void _addCredential() {
    final credentialController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Credential'),
        content: TextField(
          controller: credentialController,
          decoration: const InputDecoration(
            labelText: 'Credential (e.g., MIT, Google, Microsoft)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (credentialController.text.isNotEmpty) {
                setState(() {
                  _credentials.add(credentialController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCredential(int index) {
    setState(() {
      _credentials.removeAt(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
