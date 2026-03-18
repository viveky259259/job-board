import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:job_board/core/theme/app_theme.dart';
import 'package:job_board/models/achievement.dart';
import 'package:job_board/models/application.dart';
import 'package:job_board/providers/application_provider.dart';
import 'package:job_board/providers/gamification_provider.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/widgets/achievement_badge.dart';
import 'package:job_board/widgets/stat_card.dart';
import 'package:job_board/widgets/xp_progress_bar.dart';

class GamificationDashboardScreen extends ConsumerWidget {
  const GamificationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gamification = ref.watch(gamificationDataProvider);
    final profile = ref.watch(profileProvider);
    final totalApps = ref.watch(totalApplicationsProvider);
    final stats = ref.watch(applicationStatsProvider);

    final unlockedIds = gamification.unlockedAchievements.toSet();
    final achievements = Achievement.all
        .map((a) => unlockedIds.contains(a.id) ? a.unlock() : a)
        .toList();
    final recentUnlocked =
        achievements.where((a) => a.isUnlocked).take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/achievements'),
            icon: const Icon(Icons.emoji_events),
            label: const Text('All Badges'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.tertiary,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${gamification.level}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gamification.levelName,
                                style: theme.textTheme.titleLarge,
                              ),
                              Text(
                                '${gamification.xp} XP total',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    XpProgressBar(data: gamification, showLabel: false),
                    const SizedBox(height: 6),
                    if (gamification.xpForNextLevel > 0)
                      Text(
                        '${gamification.xpForNextLevel} XP to Level ${gamification.level + 1}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Streak',
                    value: '${gamification.currentStreak} days',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'Applications',
                    value: '$totalApps',
                    icon: Icons.send,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Interviews',
                    value: '${stats[ApplicationStatus.interviewing] ?? 0}',
                    icon: Icons.mic,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'Offers',
                    value: '${stats[ApplicationStatus.offered] ?? 0}',
                    icon: Icons.celebration,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (profile != null) ...[
              Text('Profile Completeness',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _completenessChart(theme, profile.profileCompleteness),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Achievements',
                    style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.go('/achievements'),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentUnlocked.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_outlined,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    Text(
                      'No achievements yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Apply to jobs and complete actions to earn badges!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: recentUnlocked
                    .map((a) => AchievementBadge(achievement: a))
                    .toList(),
              ),
            const SizedBox(height: 24),
            Text('Application Funnel', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _applicationFunnel(theme, stats),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _completenessChart(ThemeData theme, int completeness) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 25,
                sections: [
                  PieChartSectionData(
                    value: completeness.toDouble(),
                    color: theme.colorScheme.primary,
                    radius: 12,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (100 - completeness).toDouble(),
                    color: theme.colorScheme.surfaceContainerHighest,
                    radius: 12,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completeness%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  completeness >= 80
                      ? 'Looking great!'
                      : 'Add more details for better matching',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _applicationFunnel(
      ThemeData theme, Map<ApplicationStatus, int> stats) {
    final items = [
      ('Saved', stats[ApplicationStatus.saved] ?? 0, Colors.grey),
      ('Applied', stats[ApplicationStatus.applied] ?? 0, Colors.blue),
      ('Interviewing', stats[ApplicationStatus.interviewing] ?? 0,
          Colors.orange),
      ('Offered', stats[ApplicationStatus.offered] ?? 0,
          AppTheme.successColor),
    ];

    final maxVal =
        items.map((e) => e.$2).fold(1, (a, b) => a > b ? a : b);

    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(item.$1,
                          style: theme.textTheme.bodySmall),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.$2 / maxVal,
                          minHeight: 20,
                          backgroundColor:
                              item.$3.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(item.$3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${item.$2}',
                        style: theme.textTheme.labelLarge,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
