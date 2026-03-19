import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_board/core/constants/app_constants.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sub = ref.watch(subscriptionProvider);
    final tier = sub.effectiveTier;
    final usage = sub.usage;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _subscriptionCard(context, theme, sub, tier),
          const SizedBox(height: 16),
          if (tier == SubscriptionTier.free) ...[
            _usageCard(theme, usage),
            const SizedBox(height: 16),
          ],
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Appearance'),
                  subtitle: const Text('System default'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text('Sign Out',
                  style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out')),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await ref.read(authServiceProvider).signOut();
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to sign out.')),
                      );
                    }
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'JobHunter AI v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subscriptionCard(
      BuildContext context, ThemeData theme, UserSubscription sub, SubscriptionTier tier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: tier.isPaid
                        ? LinearGradient(colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ])
                        : null,
                    color: tier.isPaid ? null : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tier.label.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: tier.isPaid ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(tier.tagline, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            if (tier.isPaid)
              Text(
                'Active — \$${(sub.isYearly ? tier.yearlyPrice : tier.monthlyPrice).toStringAsFixed(2)}/${sub.isYearly ? 'year' : 'month'}',
                style: theme.textTheme.bodyMedium,
              )
            else
              Text(
                'Upgrade to unlock all features',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: tier.isPaid
                  ? OutlinedButton(
                      onPressed: () => context.push('/upgrade'),
                      child: const Text('Manage Subscription'),
                    )
                  : FilledButton.icon(
                      onPressed: () => context.push('/upgrade'),
                      icon: const Icon(Icons.star),
                      label: const Text('Upgrade to Pro'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageCard(ThemeData theme, UsageLimits usage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Free Tier Usage', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            _usageRow(
              theme,
              'Cover Letters',
              usage.coverLettersUsed,
              AppConstants.freeCoverLettersPerMonth,
            ),
            const SizedBox(height: 10),
            _usageRow(
              theme,
              'Intro Messages',
              usage.introMessagesUsed,
              AppConstants.freeIntroMessagesPerMonth,
            ),
            const SizedBox(height: 8),
            Text(
              'Resets monthly',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _usageRow(ThemeData theme, String label, int used, int total) {
    final remaining = (total - used).clamp(0, total);
    final progress = total > 0 ? used / total : 0.0;
    final color = remaining == 0
        ? theme.colorScheme.error
        : remaining <= 1
            ? Colors.orange
            : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              '$used / $total used',
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
