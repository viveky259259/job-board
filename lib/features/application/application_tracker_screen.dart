import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:job_board/core/theme/app_theme.dart';
import 'package:job_board/models/application.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/application_provider.dart';
import 'package:job_board/widgets/empty_state.dart';
import 'package:job_board/widgets/stat_card.dart';

class ApplicationTrackerScreen extends ConsumerStatefulWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  ConsumerState<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState
    extends ConsumerState<ApplicationTrackerScreen> {
  ApplicationStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applicationsAsync = ref.watch(applicationsStreamProvider);
    final stats = ref.watch(applicationStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Application Tracker')),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (applications) {
          final filtered = _filterStatus != null
              ? applications
                  .where((a) => a.status == _filterStatus)
                  .toList()
              : applications;

          return Column(
            children: [
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _statTile(theme, stats, ApplicationStatus.saved,
                        Icons.bookmark, null),
                    _statTile(theme, stats, ApplicationStatus.applied,
                        Icons.send, Colors.blue),
                    _statTile(theme, stats, ApplicationStatus.interviewing,
                        Icons.mic, Colors.orange),
                    _statTile(theme, stats, ApplicationStatus.offered,
                        Icons.celebration, AppTheme.successColor),
                    _statTile(theme, stats, ApplicationStatus.rejected,
                        Icons.close, Colors.red),
                    _statTile(theme, stats, ApplicationStatus.ghosted,
                        Icons.visibility_off, Colors.grey),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      _filterStatus != null
                          ? '${_filterStatus!.label} (${filtered.length})'
                          : 'All Applications (${filtered.length})',
                      style: theme.textTheme.titleSmall,
                    ),
                    const Spacer(),
                    if (_filterStatus != null)
                      TextButton(
                        onPressed: () =>
                            setState(() => _filterStatus = null),
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No applications yet',
                        subtitle: 'Save and apply to jobs to track them here.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildApplicationTile(
                                context, theme, filtered[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statTile(
    ThemeData theme,
    Map<ApplicationStatus, int> stats,
    ApplicationStatus status,
    IconData icon,
    Color? color,
  ) {
    final count = stats[status] ?? 0;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: 100,
        child: StatCard(
          label: status.label,
          value: '$count',
          icon: icon,
          color: color,
          onTap: () => setState(() {
            _filterStatus = _filterStatus == status ? null : status;
          }),
        ),
      ),
    );
  }

  Widget _buildApplicationTile(
      BuildContext context, ThemeData theme, Application app) {
    final isGhosted = app.isPossiblyGhosted;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _statusColor(app.status).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(app.status.emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(app.jobTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(app.company),
            if (isGhosted && app.status == ApplicationStatus.applied)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'No response for ${app.daysSinceLastUpdate} days',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (app.matchScore > 0)
              Text(
                '${app.matchScore}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.matchScoreColor(app.matchScore),
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              timeago.format(app.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: () => _showStatusUpdateSheet(context, app),
      ),
    );
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.saved:
        return Colors.grey;
      case ApplicationStatus.applied:
        return Colors.blue;
      case ApplicationStatus.interviewing:
        return Colors.orange;
      case ApplicationStatus.offered:
        return AppTheme.successColor;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.ghosted:
        return Colors.grey;
    }
  }

  void _showStatusUpdateSheet(BuildContext context, Application app) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.jobTitle,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(app.company,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text('Update Status',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                ...ApplicationStatus.values.map((status) => ListTile(
                      leading: Text(status.emoji,
                          style: const TextStyle(fontSize: 20)),
                      title: Text(status.label),
                      selected: app.status == status,
                      onTap: () async {
                        await ref
                            .read(applicationServiceProvider)
                            .updateStatus(user.uid, app.id, status);
                        if (context.mounted) Navigator.pop(context);
                      },
                    )),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await ref
                          .read(applicationServiceProvider)
                          .deleteApplication(user.uid, app.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Delete Application',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
