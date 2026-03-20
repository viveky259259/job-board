import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:job_board/models/application.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/application_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';

class FollowUpScreen extends ConsumerWidget {
  const FollowUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tier = ref.watch(currentTierProvider);

    if (!tier.hasFeature(ProFeature.followUpReminders)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Follow-up Reminders')),
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
                Text('Smart reminders to follow up on your applications.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: SubZeroColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SubZeroButton(
                  label: 'Upgrade to Premium',
                  variant: SubZeroButtonVariant.primary,
                  leadingIcon: Icons.star,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen(triggerFeature: ProFeature.followUpReminders)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final applications = ref.watch(applicationsStreamProvider).value ?? [];
    final needsFollowUp = _getFollowUpItems(applications);

    return Scaffold(
      appBar: AppBar(title: const Text('Follow-up Reminders')),
      body: needsFollowUp.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 64, color: SubZeroColors.success),
                    const SizedBox(height: 16),
                    Text('All caught up!', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('No follow-ups needed right now.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: SubZeroColors.textSecondary)),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: needsFollowUp.length,
              itemBuilder: (context, index) {
                final item = needsFollowUp[index];
                return _followUpCard(theme, item);
              },
            ),
    );
  }

  List<_FollowUpItem> _getFollowUpItems(List<Application> apps) {
    final items = <_FollowUpItem>[];

    for (final app in apps) {
      if (app.status == ApplicationStatus.applied) {
        final days = app.daysSinceLastUpdate;
        if (days >= 7 && days < 14) {
          items.add(_FollowUpItem(
            app: app,
            urgency: _Urgency.low,
            message: 'Consider following up — it\'s been $days days since you applied.',
            suggestion: 'Send a polite check-in email to the hiring manager or recruiter.',
          ));
        } else if (days >= 14 && days < 30) {
          items.add(_FollowUpItem(
            app: app,
            urgency: _Urgency.medium,
            message: '$days days without response. A follow-up could help.',
            suggestion: 'Reference your application date and reiterate your interest in the role.',
          ));
        } else if (days >= 30) {
          items.add(_FollowUpItem(
            app: app,
            urgency: _Urgency.high,
            message: '$days days — this may be ghosted. Final follow-up recommended.',
            suggestion: 'Send a brief final follow-up. If no response, consider moving on and marking as ghosted.',
          ));
        }
      } else if (app.status == ApplicationStatus.interviewing) {
        final days = app.daysSinceLastUpdate;
        if (days >= 5) {
          items.add(_FollowUpItem(
            app: app,
            urgency: _Urgency.medium,
            message: '$days days since last interview update. Send a thank-you note if you haven\'t.',
            suggestion: 'A brief email thanking the interviewer and expressing continued interest goes a long way.',
          ));
        }
      }
    }

    items.sort((a, b) => b.urgency.index.compareTo(a.urgency.index));
    return items;
  }

  Widget _followUpCard(ThemeData theme, _FollowUpItem item) {
    final color = switch (item.urgency) {
      _Urgency.low => SubZeroColors.info,
      _Urgency.medium => SubZeroColors.warning,
      _Urgency.high => SubZeroColors.error,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.app.jobTitle,
                      style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Text(timeago.format(item.app.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(color: SubZeroColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 4),
            Text(item.app.company, style: theme.textTheme.bodySmall?.copyWith(color: SubZeroColors.primary)),
            const SizedBox(height: 8),
            Text(item.message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.suggestion,
                        style: theme.textTheme.bodySmall?.copyWith(color: SubZeroColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Urgency { low, medium, high }

class _FollowUpItem {
  final Application app;
  final _Urgency urgency;
  final String message;
  final String suggestion;

  const _FollowUpItem({
    required this.app,
    required this.urgency,
    required this.message,
    required this.suggestion,
  });
}
