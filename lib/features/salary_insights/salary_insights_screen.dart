import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';

class SalaryInsightsScreen extends ConsumerWidget {
  final Job job;
  const SalaryInsightsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tier = ref.watch(currentTierProvider);

    if (!tier.hasFeature(ProFeature.salaryInsights)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Salary Insights')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 64, color: SubZeroColors.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Pro Feature', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Market salary data for any role and location.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: SubZeroColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SubZeroButton(
                  label: 'Upgrade to Pro',
                  variant: SubZeroButtonVariant.primary,
                  leadingIcon: Icons.star,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen(triggerFeature: ProFeature.salaryInsights)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final salaryData = _generateSalaryData(job);

    return Scaffold(
      appBar: AppBar(title: Text('Salary: ${job.title}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _salaryRangeCard(theme, salaryData),
            const SizedBox(height: 20),
            Text('Market Comparison', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _comparisonBars(theme, salaryData),
            const SizedBox(height: 20),
            Text('By Experience Level', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...salaryData['byLevel'].entries.map((e) =>
                _levelRow(theme, e.key, e.value['min'], e.value['max'])),
            const SizedBox(height: 20),
            Text('Location Factor', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...salaryData['byLocation'].entries.map((e) =>
                _locationRow(theme, e.key, e.value)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SubZeroColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: SubZeroColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Data based on market averages for ${job.title} roles. Actual compensation varies by company, experience, and negotiation.',
                      style: theme.textTheme.bodySmall?.copyWith(color: SubZeroColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _generateSalaryData(Job job) {
    final baseMin = job.salaryMin ?? 90000;
    final baseMax = job.salaryMax ?? 160000;
    final mid = ((baseMin + baseMax) / 2).round();

    return {
      'min': baseMin,
      'max': baseMax,
      'median': mid,
      'p25': (baseMin + (mid - baseMin) * 0.3).round(),
      'p75': (mid + (baseMax - mid) * 0.7).round(),
      'marketAvg': (mid * 1.05).round(),
      'byLevel': {
        'Entry Level': {'min': (baseMin * 0.7).round(), 'max': (baseMax * 0.7).round()},
        'Mid Level': {'min': baseMin, 'max': baseMax},
        'Senior': {'min': (baseMin * 1.3).round(), 'max': (baseMax * 1.3).round()},
        'Lead/Staff': {'min': (baseMin * 1.6).round(), 'max': (baseMax * 1.6).round()},
      },
      'byLocation': {
        'San Francisco': 1.15,
        'New York': 1.10,
        'Seattle': 1.08,
        'Austin': 0.95,
        'Remote (US)': 1.0,
        'London': 0.85,
      },
    };
  }

  Widget _salaryRangeCard(ThemeData theme, Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          SubZeroColors.primary.withValues(alpha: 0.1),
          SubZeroColors.actionTertiary.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Estimated Range', style: theme.textTheme.titleSmall?.copyWith(color: SubZeroColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            '\$${_formatK(data['min'])} — \$${_formatK(data['max'])}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: SubZeroColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('Median: \$${_formatK(data['median'])}',
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _comparisonBars(ThemeData theme, Map<String, dynamic> data) {
    final items = [
      ('25th Percentile', data['p25'] as int, Colors.orange),
      ('Median', data['median'] as int, SubZeroColors.primary),
      ('75th Percentile', data['p75'] as int, SubZeroColors.success),
      ('Market Average', data['marketAvg'] as int, SubZeroColors.info),
    ];
    final maxVal = items.map((e) => e.$2).fold(1, (a, b) => a > b ? a : b);

    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(item.$1, style: theme.textTheme.bodySmall)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.$2 / maxVal,
                  minHeight: 20,
                  backgroundColor: item.$3.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(item.$3),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text('\$${_formatK(item.$2)}',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _levelRow(ThemeData theme, String level, int min, int max) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(level, style: theme.textTheme.bodyMedium),
          Text('\$${_formatK(min)} — \$${_formatK(max)}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _locationRow(ThemeData theme, String location, double factor) {
    final pct = ((factor - 1) * 100).round();
    final label = pct >= 0 ? '+$pct%' : '$pct%';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(location, style: theme.textTheme.bodyMedium),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(
            color: pct >= 0 ? SubZeroColors.success : SubZeroColors.error,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  String _formatK(int amount) {
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toString();
  }
}
