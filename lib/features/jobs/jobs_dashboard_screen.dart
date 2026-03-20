import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_board/core/constants/app_constants.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/job_provider.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/providers/application_provider.dart';
import 'package:job_board/widgets/job_card.dart';
import 'package:job_board/widgets/empty_state.dart';

class JobsDashboardScreen extends ConsumerStatefulWidget {
  const JobsDashboardScreen({super.key});

  @override
  ConsumerState<JobsDashboardScreen> createState() =>
      _JobsDashboardScreenState();
}

class _JobsDashboardScreenState extends ConsumerState<JobsDashboardScreen> {
  final _searchController = TextEditingController();
  bool _showFilters = false;
  bool _isCrawling = false;
  DateTime? _lastCrawlTime;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _triggerCrawl() async {
    // Debounce: prevent spamming (5 second cooldown)
    if (_isCrawling) return;
    if (_lastCrawlTime != null &&
        DateTime.now().difference(_lastCrawlTime!).inSeconds < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait a few seconds before refreshing again.')),
      );
      return;
    }

    final profile = ref.read(profileProvider);
    if (profile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete your profile first to search for matching jobs.')),
        );
      }
      return;
    }

    setState(() => _isCrawling = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Searching for jobs...')),
    );

    try {
      await ref.read(jobServiceProvider).triggerCrawl(profile.preferences);
      _lastCrawlTime = DateTime.now();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jobs updated!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch jobs. Check your connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCrawling = false);
    }
  }

  Future<void> _saveJob(Job job) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (job.isExpired) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This job listing has expired.')),
        );
      }
      return;
    }

    try {
      await ref.read(applicationServiceProvider).saveJob(
            userId: user.uid,
            jobId: job.id,
            jobTitle: job.title,
            company: job.company,
            matchScore: job.matchScore,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${job.title} saved! +${AppConstants.xpSaveJob} XP')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save job.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobsAsync = ref.watch(jobsStreamProvider);
    final filter = ref.watch(jobFilterProvider);
    final applications = ref.watch(applicationsStreamProvider).value ?? [];
    final savedJobIds = applications.map((a) => a.jobId).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          if (_isCrawling)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _triggerCrawl,
              tooltip: 'Find new jobs',
            ),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Failed to load jobs',
          subtitle: 'Check your internet connection and try again.',
          actionLabel: 'Retry',
          onAction: _triggerCrawl,
        ),
        data: (rawJobs) {
          final jobs = ref.watch(filteredJobsProvider);
          final activeJobs = jobs.where((j) => !j.isExpired).toList();
          final hasExpired = jobs.length != activeJobs.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search jobs, companies, locations...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(jobFilterProvider.notifier).state =
                                  filter.copyWith(query: '');
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    ref.read(jobFilterProvider.notifier).state =
                        filter.copyWith(query: value);
                    setState(() {});
                  },
                ),
              ),
              if (_showFilters) _buildFilters(theme, filter),
              if (hasExpired)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${jobs.length - activeJobs.length} expired job(s) hidden',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: activeJobs.isEmpty
                    ? EmptyState(
                        icon: Icons.work_off_outlined,
                        title: rawJobs.isEmpty ? 'No jobs yet' : 'No matching jobs',
                        subtitle: rawJobs.isEmpty
                            ? 'Tap refresh to search for jobs matching your profile.'
                            : 'Try adjusting your search or filters.',
                        actionLabel: rawJobs.isEmpty ? 'Search Jobs' : 'Clear Filters',
                        onAction: rawJobs.isEmpty
                            ? _triggerCrawl
                            : () {
                                _searchController.clear();
                                ref.read(jobFilterProvider.notifier).state = const JobFilter();
                                setState(() {});
                              },
                      )
                    : RefreshIndicator(
                        onRefresh: _triggerCrawl,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: activeJobs.length,
                          itemBuilder: (context, index) {
                            final job = activeJobs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: JobCard(
                                job: job,
                                isSaved: savedJobIds.contains(job.id),
                                onTap: () => context.go('/job/${job.id}'),
                                onSave: savedJobIds.contains(job.id)
                                    ? null
                                    : () => _saveJob(job),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(ThemeData theme, JobFilter filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterDropdown('Job Type', filter.jobType, ['', ...AppConstants.jobTypes],
                (v) => ref.read(jobFilterProvider.notifier).state = filter.copyWith(jobType: v)),
            const SizedBox(width: 8),
            _filterDropdown('Remote', filter.remote, ['', ...AppConstants.remoteOptions],
                (v) => ref.read(jobFilterProvider.notifier).state = filter.copyWith(remote: v)),
            const SizedBox(width: 8),
            _filterDropdown('Sort By', filter.sortBy, ['match', 'date', 'salary', 'company'],
                (v) => ref.read(jobFilterProvider.notifier).state = filter.copyWith(sortBy: v)),
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown(String label, String? current, List<String> options, ValueChanged<String> onChanged) {
    final effectiveValue = (current != null && options.contains(current)) ? current : options.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          isDense: true,
          hint: Text(label),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o.isEmpty ? 'All $label' : o)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
