import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';

class CompanyResearchScreen extends ConsumerStatefulWidget {
  final Job job;
  const CompanyResearchScreen({super.key, required this.job});

  @override
  ConsumerState<CompanyResearchScreen> createState() => _CompanyResearchScreenState();
}

class _CompanyResearchScreenState extends ConsumerState<CompanyResearchScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _research;

  void _generateResearch() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _research = _buildCompanyBrief(widget.job);
        _isLoading = false;
      });
    });
  }

  Map<String, dynamic> _buildCompanyBrief(Job job) {
    return {
      'overview': '${job.company} is a technology company with operations in ${job.location}. '
          'They are actively hiring for ${job.title} roles, suggesting growth in their engineering division.',
      'culture': [
        'Focus on innovation and cutting-edge technology',
        'Collaborative team environment',
        'Investment in employee growth and learning',
        'Competitive compensation and benefits packages',
      ],
      'interviewTips': [
        'Research their recent products and company news',
        'Prepare examples demonstrating ${job.requirements.take(3).join(", ")} experience',
        'Ask about team structure and growth plans',
        'Show enthusiasm for their mission and values',
      ],
      'pros': [
        'Active hiring indicates company growth',
        '${job.remote} work arrangement available',
        if (job.salaryMax != null) 'Competitive salary range (${job.salaryRange})',
        'Opportunity to work with ${job.requirements.take(2).join(" and ")}',
      ],
      'watchFor': [
        'Verify company size and funding stage',
        'Ask about work-life balance expectations',
        'Understand the team you\'d be joining',
        'Clarify career growth path within the role',
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = ref.watch(currentTierProvider);

    if (!tier.hasFeature(ProFeature.companyResearch)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Company Research')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 64, color: SubZeroColors.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Premium Feature', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('AI-generated company intelligence briefs.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: SubZeroColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SubZeroButton(
                  label: 'Upgrade to Premium',
                  variant: SubZeroButtonVariant.primary,
                  leadingIcon: Icons.star,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen(triggerFeature: ProFeature.companyResearch)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.job.company)),
      body: _research == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business, size: 64, color: SubZeroColors.primary),
                    const SizedBox(height: 16),
                    Text('Company Research Brief', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Get AI-generated insights about ${widget.job.company}.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: SubZeroColors.textSecondary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SubZeroButton(
                      label: _isLoading ? 'Generating...' : 'Generate Brief',
                      variant: SubZeroButtonVariant.primary,
                      leadingIcon: Icons.auto_awesome,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _generateResearch,
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(theme, 'Company Overview', Icons.business, _research!['overview'] as String),
                  const SizedBox(height: 16),
                  _listSection(theme, 'Culture & Values', Icons.people, _research!['culture'] as List),
                  const SizedBox(height: 16),
                  _listSection(theme, 'Interview Tips', Icons.lightbulb, _research!['interviewTips'] as List),
                  const SizedBox(height: 16),
                  _listSection(theme, 'Pros', Icons.thumb_up, _research!['pros'] as List, color: SubZeroColors.success),
                  const SizedBox(height: 16),
                  _listSection(theme, 'Things to Verify', Icons.warning_amber, _research!['watchFor'] as List, color: SubZeroColors.warning),
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final text = 'Company Research: ${widget.job.company}\n\n${_research!['overview']}\n\n'
                            'Culture: ${(_research!['culture'] as List).join(", ")}\n\n'
                            'Interview Tips: ${(_research!['interviewTips'] as List).join(", ")}';
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Brief'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _section(ThemeData theme, String title, IconData icon, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: SubZeroColors.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall),
            ]),
            const SizedBox(height: 8),
            Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _listSection(ThemeData theme, String title, IconData icon, List items, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: color ?? SubZeroColors.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall),
            ]),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 16, color: color ?? SubZeroColors.primary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item as String, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
