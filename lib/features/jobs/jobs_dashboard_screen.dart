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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _triggerCrawl() async {
    final profile = ref.read(profileProvider);
    if (profile == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Searching for jobs...')),
    );

    try {
      await ref.read(jobServiceProvider).triggerCrawl(profile.preferences);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jobs updated!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch jobs')),
        );
      }
    }
  }

  Future<void> _saveJob(Job job) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobs = ref.watch(filteredJobsProvider);
    final filter = ref.watch(jobFilterProvider);
    final applications = ref.watch(applicationsStreamProvider).value ?? [];
    final savedJobIds = applications.map((a) => a.jobId).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
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
      body: Column(
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
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(jobFilterProvider.notifier).state =
                    filter.copyWith(query: value);
              },
            ),
          ),
          if (_showFilters) _buildFilters(theme, filter),
          Expanded(
            child: jobs.isEmpty
                ? EmptyState(
                    icon: Icons.work_off_outlined,
                    title: 'No jobs found',
                    subtitle:
                        'Tap the refresh button to search for new jobs matching your profile.',
                    actionLabel: 'Search Jobs',
                    onAction: _triggerCrawl,
                  )
                : RefreshIndicator(
                    onRefresh: _triggerCrawl,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: JobCard(
                            job: job,
                            isSaved: savedJobIds.contains(job.id),
                            onTap: () => context.go('/job/${job.id}'),
                            onSave: () => _saveJob(job),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme, JobFilter filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterDropdown(
                  'Job Type',
                  filter.jobType,
                  ['', ...AppConstants.jobTypes],
                  (v) => ref.read(jobFilterProvider.notifier).state =
                      filter.copyWith(jobType: v),
                ),
                const SizedBox(width: 8),
                _filterDropdown(
                  'Remote',
                  filter.remote,
                  ['', ...AppConstants.remoteOptions],
                  (v) => ref.read(jobFilterProvider.notifier).state =
                      filter.copyWith(remote: v),
                ),
                const SizedBox(width: 8),
                _filterDropdown(
                  'Sort By',
                  filter.sortBy,
                  ['match', 'date', 'salary', 'company'],
                  (v) => ref.read(jobFilterProvider.notifier).state =
                      filter.copyWith(sortBy: v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown(
    String label,
    String? current,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current ?? options.first,
          isDense: true,
          hint: Text(label),
          items: options
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(o.isEmpty ? 'All $label' : o),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
