import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:job_board/core/theme/app_theme.dart';
import 'package:job_board/models/application.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/application_provider.dart';
import 'package:job_board/providers/gamification_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';
import 'package:job_board/widgets/stat_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tier = ref.watch(currentTierProvider);

    if (!tier.hasFeature(ProFeature.advancedAnalytics)) {
      return _lockedView(context, theme);
    }

    final applications = ref.watch(applicationsStreamProvider).value ?? [];
    final stats = ref.watch(applicationStatsProvider);
    final gamification = ref.watch(gamificationDataProvider);

    final applied = applications.where((a) => a.status != ApplicationStatus.saved).toList();
    final interviews = stats[ApplicationStatus.interviewing] ?? 0;
    final offers = stats[ApplicationStatus.offered] ?? 0;
    final responseRate = applied.isNotEmpty
        ? ((interviews + offers) / applied.length * 100).round()
        : 0;
    final avgMatchScore = applied.isNotEmpty
        ? (applied.map((a) => a.matchScore).fold(0, (a, b) => a + b) / applied.length).round()
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Response Rate',
                    value: '$responseRate%',
                    icon: Icons.reply,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'Avg Match',
                    value: '$avgMatchScore%',
                    icon: Icons.auto_awesome,
                    color: AppTheme.matchScoreColor(avgMatchScore),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Applied',
                    value: '${applied.length}',
                    icon: Icons.send,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'Streak',
                    value: '${gamification.currentStreak}d',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Application Funnel', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _funnelChart(theme, stats, applied.length),
            const SizedBox(height: 24),
            Text('Applications Over Time', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _timelineChart(theme, applications),
            const SizedBox(height: 24),
            Text('Match Score Distribution', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _matchDistribution(theme, applied),
            const SizedBox(height: 24),
            Text('Key Insights', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._generateInsights(theme, applied, stats, responseRate, avgMatchScore),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _lockedView(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('Pro Feature', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Unlock detailed analytics — response rates, funnel analysis, and actionable insights.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaywallScreen(triggerFeature: ProFeature.advancedAnalytics),
                  ),
                ),
                icon: const Icon(Icons.star),
                label: const Text('Upgrade to Pro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _funnelChart(ThemeData theme, Map<ApplicationStatus, int> stats, int totalApplied) {
    final stages = [
      ('Applied', totalApplied, Colors.blue),
      ('Interviewing', stats[ApplicationStatus.interviewing] ?? 0, Colors.orange),
      ('Offered', stats[ApplicationStatus.offered] ?? 0, AppTheme.successColor),
    ];

    final maxVal = stages.map((e) => e.$2).fold(1, (a, b) => a > b ? a : b);

    return Column(
      children: stages.map((stage) {
        final pct = totalApplied > 0 ? (stage.$2 / totalApplied * 100).round() : 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(stage.$1, style: theme.textTheme.bodyMedium),
                  Text('${stage.$2} ($pct%)',
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: maxVal > 0 ? stage.$2 / maxVal : 0,
                  minHeight: 24,
                  backgroundColor: stage.$3.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(stage.$3),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _timelineChart(ThemeData theme, List<Application> applications) {
    final now = DateTime.now();
    final weeks = <int, int>{};
    for (int i = 0; i < 8; i++) {
      weeks[i] = 0;
    }

    for (final app in applications) {
      if (app.status == ApplicationStatus.saved) continue;
      final weeksAgo = now.difference(app.createdAt).inDays ~/ 7;
      if (weeksAgo < 8) {
        weeks[weeksAgo] = (weeks[weeksAgo] ?? 0) + 1;
      }
    }

    final spots = weeks.entries
        .map((e) => FlSpot((7 - e.key).toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final weeksAgo = 7 - value.toInt();
                  if (weeksAgo == 0) return Text('Now', style: theme.textTheme.labelSmall);
                  return Text('${weeksAgo}w', style: theme.textTheme.labelSmall);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchDistribution(ThemeData theme, List<Application> applied) {
    final buckets = {'0-40': 0, '40-60': 0, '60-80': 0, '80-100': 0};
    for (final app in applied) {
      if (app.matchScore < 40) {
        buckets['0-40'] = buckets['0-40']! + 1;
      } else if (app.matchScore < 60) {
        buckets['40-60'] = buckets['40-60']! + 1;
      } else if (app.matchScore < 80) {
        buckets['60-80'] = buckets['60-80']! + 1;
      } else {
        buckets['80-100'] = buckets['80-100']! + 1;
      }
    }

    final colors = [Colors.red, Colors.orange, Colors.amber, AppTheme.successColor];
    final maxVal = buckets.values.fold(1, (a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: buckets.entries.toList().asMap().entries.map((entry) {
        final idx = entry.key;
        final bucket = entry.value;
        final height = maxVal > 0 ? (bucket.value / maxVal * 100).clamp(4.0, 100.0) : 4.0;

        return Expanded(
          child: Column(
            children: [
              Text('${bucket.value}', style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Container(
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors[idx],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(bucket.key, style: theme.textTheme.labelSmall),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _generateInsights(
    ThemeData theme,
    List<Application> applied,
    Map<ApplicationStatus, int> stats,
    int responseRate,
    int avgMatchScore,
  ) {
    final insights = <Widget>[];

    if (responseRate > 20) {
      insights.add(_insightTile(theme, Icons.thumb_up, Colors.green,
          'Your response rate of $responseRate% is above average. Keep applying to high-match jobs!'));
    } else if (applied.isNotEmpty) {
      insights.add(_insightTile(theme, Icons.trending_up, Colors.orange,
          'Response rate is $responseRate%. Try applying to jobs with 70%+ match score for better results.'));
    }

    if (avgMatchScore < 60 && applied.isNotEmpty) {
      insights.add(_insightTile(theme, Icons.gps_fixed, Colors.blue,
          'Your average match score is $avgMatchScore%. Focus on jobs that better align with your skills.'));
    }

    final ghosted = stats[ApplicationStatus.ghosted] ?? 0;
    if (ghosted > 3) {
      insights.add(_insightTile(theme, Icons.visibility_off, Colors.grey,
          '$ghosted applications ghosted. Consider following up after 7-14 days.'));
    }

    if (insights.isEmpty) {
      insights.add(_insightTile(theme, Icons.info, Colors.blue,
          'Start applying to jobs to see personalized insights here.'));
    }

    return insights;
  }

  Widget _insightTile(ThemeData theme, IconData icon, Color color, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
          ],
        ),
      ),
    );
  }
}
