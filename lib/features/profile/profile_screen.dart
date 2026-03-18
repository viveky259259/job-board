import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/widgets/xp_progress_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
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
            const SizedBox(height: 24),
            XpProgressBar(data: profile.gamification),
            const SizedBox(height: 24),
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
}
