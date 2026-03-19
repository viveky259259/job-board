import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/widgets/xp_progress_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileStreamProvider);
    final profile = profileAsync.value;

    if (profileAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off, size: 48),
              const SizedBox(height: 12),
              const Text('Profile not found'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/onboarding'),
                child: const Text('Set Up Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      (profile.name?.isNotEmpty == true)
                          ? profile.name![0].toUpperCase()
                          : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name ?? 'Set your name',
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (profile.headline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        profile.headline!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  Text(
                    profile.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _subscriptionBadge(context, theme, ref),
            const SizedBox(height: 16),
            XpProgressBar(data: profile.gamification),
            const SizedBox(height: 16),
            _proToolsRow(context, theme),
            const SizedBox(height: 16),
            _profileCompleteness(theme, profile.profileCompleteness),
            const SizedBox(height: 24),
            if (profile.summary != null && profile.summary!.isNotEmpty) ...[
              _sectionHeader(theme, 'About'),
              Text(profile.summary!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
            ],
            if (profile.skills.isNotEmpty) ...[
              _sectionHeader(theme, 'Skills'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.skills
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            if (profile.experience.isNotEmpty) ...[
              _sectionHeader(theme, 'Experience'),
              ...profile.experience.map((exp) => Card(
                    child: ListTile(
                      title: Text(exp.title),
                      subtitle: Text(exp.company),
                      trailing: Text(
                        [exp.startDate, exp.endDate ?? 'Present']
                            .where((e) => e != null)
                            .join(' - '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
            ],
            if (profile.education.isNotEmpty) ...[
              _sectionHeader(theme, 'Education'),
              ...profile.education.map((edu) => Card(
                    child: ListTile(
                      title: Text(edu.degree),
                      subtitle: Text(edu.school),
                      trailing: edu.year != null ? Text(edu.year!) : null,
                    ),
                  )),
              const SizedBox(height: 20),
            ],
            if (profile.preferences.isConfigured) ...[
              _sectionHeader(theme, 'Job Preferences'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...profile.preferences.targetRoles
                      .map((r) => Chip(label: Text(r))),
                  ...profile.preferences.locations
                      .map((l) => Chip(
                            avatar: const Icon(Icons.location_on, size: 16),
                            label: Text(l),
                          )),
                  ...profile.preferences.remotePreference
                      .map((r) => Chip(
                            avatar: const Icon(Icons.laptop, size: 16),
                            label: Text(r),
                          )),
                ],
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: theme.textTheme.titleMedium),
    );
  }

  Widget _profileCompleteness(ThemeData theme, int completeness) {
    Color color;
    if (completeness >= 80) {
      color = Colors.green;
    } else if (completeness >= 50) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

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
              Icon(Icons.person_pin, color: color),
              const SizedBox(width: 8),
              Text(
                'Profile Completeness: $completeness%',
                style: theme.textTheme.titleSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completeness / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          if (completeness < 100) ...[
            const SizedBox(height: 8),
            Text(
              completeness < 60
                  ? 'Complete your profile for better job matching!'
                  : 'Almost there! Add more details for the best results.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _subscriptionBadge(BuildContext context, ThemeData theme, WidgetRef ref) {
    final tier = ref.watch(currentTierProvider);
    return GestureDetector(
      onTap: () => context.go('/upgrade'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: tier.isPaid
              ? LinearGradient(colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ])
              : null,
          color: tier.isPaid ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tier.isPaid ? Icons.star : Icons.star_border,
              size: 16,
              color: tier.isPaid ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              tier.isPaid ? '${tier.label} Plan' : 'Upgrade to Pro',
              style: theme.textTheme.labelMedium?.copyWith(
                color: tier.isPaid ? Colors.white : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _proToolsRow(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            _toolButton(context, theme, Icons.analytics, 'Resume\nAnalyzer', '/resume-analyzer'),
            const SizedBox(width: 8),
            _toolButton(context, theme, Icons.bar_chart, 'Analytics', '/analytics'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _toolButton(context, theme, Icons.school, 'Interview\nPrep', '/interview-prep-framework'),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _toolButton(
      BuildContext context, ThemeData theme, IconData icon, String label, String route) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(height: 6),
                Text(label,
                    style: theme.textTheme.labelSmall,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
