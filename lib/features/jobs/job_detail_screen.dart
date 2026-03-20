import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:job_board/core/theme/app_theme.dart';
import 'package:job_board/models/application.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/job_provider.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/providers/application_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/services/job_service.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';
import 'package:job_board/features/salary_insights/salary_insights_screen.dart';
import 'package:job_board/features/company_research/company_research_screen.dart';
import 'package:job_board/widgets/match_score_indicator.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  Job? _job;
  bool _isLoading = true;
  Application? _application;

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    final jobService = ref.read(jobServiceProvider);
    final job = await jobService.getJob(widget.jobId);
    final user = ref.read(currentUserProvider);

    Application? app;
    if (user != null) {
      app = await ref.read(applicationServiceProvider).getApplicationForJob(user.uid, widget.jobId);
    }

    if (mounted) {
      final profile = ref.read(profileProvider);
      setState(() {
        if (job != null && profile != null) {
          final score = JobService.calculateMatchScore(job, profile);
          _job = job.copyWith(matchScore: score);
        } else {
          _job = job;
        }
        _application = app;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveJob() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _job == null) return;

    try {
      final app = await ref.read(applicationServiceProvider).saveJob(
            userId: user.uid,
            jobId: _job!.id,
            jobTitle: _job!.title,
            company: _job!.company,
            matchScore: _job!.matchScore,
          );

      if (!mounted) return;
      setState(() => _application = app);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job saved!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save job.')),
      );
    }
  }

  Future<void> _markApplied() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _application == null) return;

    try {
      await ref.read(applicationServiceProvider).updateStatus(
            user.uid,
            _application!.id,
            ApplicationStatus.applied,
          );

      if (!mounted) return;
      setState(() {
        _application = _application!.copyWith(
          status: ApplicationStatus.applied,
          appliedAt: DateTime.now(),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as applied! +25 XP')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_job == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Job not found')),
      );
    }

    final job = _job!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (job.sourceUrl != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => launchUrl(Uri.parse(job.sourceUrl!)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                MatchScoreIndicator(score: job.matchScore, size: 60),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(theme, Icons.location_on, job.location),
                _infoChip(theme, Icons.work, job.jobType),
                _infoChip(theme, Icons.laptop, job.remote),
                if (job.salaryMin != null || job.salaryMax != null)
                  _infoChip(theme, Icons.attach_money, job.salaryRange),
                if (job.postedAt != null)
                  _infoChip(theme, Icons.schedule, timeago.format(job.postedAt!)),
              ],
            ),
            const SizedBox(height: 24),
            if (job.matchScore > 0) ...[
              _matchBreakdown(theme, job, ref.watch(currentTierProvider)),
              const SizedBox(height: 24),
            ],
            Text('Description', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(job.description, style: theme.textTheme.bodyMedium),
            if (job.requirements.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Requirements', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...job.requirements.map((req) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 18, color: AppTheme.successColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(req)),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 24),
            _proActions(context, theme, job),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_application == null)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _saveJob,
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Save Job'),
                  ),
                )
              else if (_application!.status == ApplicationStatus.saved) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _markApplied,
                    icon: const Icon(Icons.send),
                    label: const Text('Mark Applied'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.go('/cover-letter/${job.id}'),
                    icon: const Icon(Icons.edit_document),
                    label: const Text('Cover Letter'),
                  ),
                ),
              ] else
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.go('/cover-letter/${job.id}'),
                    icon: const Icon(Icons.edit_document),
                    label: Text(
                        'Status: ${_application!.status.label}'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(ThemeData theme, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _matchBreakdown(ThemeData theme, Job job, SubscriptionTier tier) {
    final color = AppTheme.matchScoreColor(job.matchScore);
    final isPro = tier.hasFeature(ProFeature.matchBreakdown);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${job.matchScore}% Match',
                        style: theme.textTheme.titleSmall?.copyWith(color: color)),
                    Text(
                      job.matchScore >= 80
                          ? 'Great fit for your profile!'
                          : job.matchScore >= 60
                              ? 'Good match with your skills'
                              : 'Partial match — explore to learn more',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isPro) ...[
            const Divider(height: 20),
            _breakdownRow(theme, 'Role Match', job.matchScore >= 60 ? 'Strong' : 'Partial', job.matchScore >= 60),
            _breakdownRow(theme, 'Skills Overlap', '${(job.matchScore * 0.3).round()}%', job.matchScore >= 50),
            _breakdownRow(theme, 'Location', job.location.toLowerCase().contains('remote') ? 'Match' : 'Partial', true),
            _breakdownRow(theme, 'Job Type', 'Match', true),
          ] else ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PaywallScreen(triggerFeature: ProFeature.matchBreakdown),
              )),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('Upgrade to Pro for detailed breakdown',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _breakdownRow(ThemeData theme, String label, String value, bool isGood) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(
            color: isGood ? AppTheme.successColor : Colors.orange,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  Widget _proActions(BuildContext context, ThemeData theme, Job job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pro Tools', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _proButton(theme, icon: Icons.mic, label: 'Interview Prep',
                onTap: () => context.go('/interview-prep/${job.id}')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _proButton(theme, icon: Icons.attach_money, label: 'Salary Insights',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SalaryInsightsScreen(job: job)))),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _proButton(theme, icon: Icons.business, label: 'Company Research',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CompanyResearchScreen(job: job)))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _proButton(theme, icon: Icons.analytics, label: 'Resume Analyzer',
                onTap: () => context.go('/resume-analyzer')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _proButton(ThemeData theme,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: theme.textTheme.labelMedium),
              ),
              Icon(Icons.chevron_right,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
