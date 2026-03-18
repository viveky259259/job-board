import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/core/constants/app_constants.dart';
import 'package:job_board/core/theme/app_theme.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final ProFeature? triggerFeature;
  final String? customTitle;

  const PaywallScreen({super.key, this.triggerFeature, this.customTitle});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isYearly = false;
  bool _isLoading = false;

  Future<void> _subscribe(SubscriptionTier tier) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(subscriptionServiceProvider).upgradeTo(
            user.uid,
            tier,
            yearly: _isYearly,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome to ${tier.label}!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upgrade failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTier = ref.watch(currentTierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (widget.triggerFeature != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customTitle ?? '${widget.triggerFeature!.title} is a Pro feature',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            widget.triggerFeature!.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Icon(Icons.rocket_launch, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'Supercharge Your Job Search',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '87% of Pro users report faster response rates',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            _billingToggle(theme),
            const SizedBox(height: 20),
            _tierCard(
              theme,
              tier: SubscriptionTier.premium,
              currentTier: currentTier,
              isRecommended: false,
            ),
            const SizedBox(height: 12),
            _tierCard(
              theme,
              tier: SubscriptionTier.pro,
              currentTier: currentTier,
              isRecommended: true,
            ),
            const SizedBox(height: 32),
            _featureComparison(theme),
            const SizedBox(height: 24),
            Text(
              'Cancel anytime. No questions asked.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _billingToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isYearly ? theme.colorScheme.surface : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isYearly
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
                      : null,
                ),
                child: Text(
                  'Monthly',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: !_isYearly
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isYearly ? theme.colorScheme.surface : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isYearly
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Yearly',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _isYearly
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Save 33%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierCard(
    ThemeData theme, {
    required SubscriptionTier tier,
    required SubscriptionTier currentTier,
    required bool isRecommended,
  }) {
    final isCurrentTier = currentTier == tier;
    final price = _isYearly ? tier.yearlyPrice : tier.monthlyPrice;
    final period = _isYearly ? '/year' : '/month';
    final isPremium = tier == SubscriptionTier.premium;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isRecommended ? 2 : 1,
        ),
        gradient: isPremium
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                  theme.colorScheme.tertiary.withValues(alpha: 0.05),
                ],
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(tier.label, style: theme.textTheme.titleLarge),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'POPULAR',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(tier.tagline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(period, style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._tierFeatures(tier).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 18, color: AppTheme.successColor),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(f, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: isCurrentTier
                  ? OutlinedButton(
                      onPressed: null,
                      child: const Text('Current Plan'),
                    )
                  : FilledButton(
                      onPressed: _isLoading ? null : () => _subscribe(tier),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Upgrade to ${tier.label}'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _tierFeatures(SubscriptionTier tier) {
    if (tier == SubscriptionTier.pro) {
      return [
        'Unlimited AI cover letters & intro messages',
        'Resume Analyzer with keyword optimization',
        'Interview Prep — AI questions per job',
        'Salary insights for any role',
        'Detailed match score breakdown',
        'Advanced analytics dashboard',
        'Priority job crawling',
      ];
    }
    return [
      'Everything in Pro',
      'AI Resume Tailoring per job',
      'Company Research Briefs',
      'Smart Follow-up Reminders',
      'Up to 5 tailored resumes',
      'Priority support',
    ];
  }

  Widget _featureComparison(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compare Plans', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        _comparisonRow(theme, 'Cover Letters', '${AppConstants.freeCoverLettersPerMonth}/mo', 'Unlimited', 'Unlimited'),
        _comparisonRow(theme, 'Intro Messages', '${AppConstants.freeIntroMessagesPerMonth}/mo', 'Unlimited', 'Unlimited'),
        _comparisonRow(theme, 'Resume Analyzer', '—', 'Yes', 'Yes'),
        _comparisonRow(theme, 'Interview Prep', '—', 'Yes', 'Yes'),
        _comparisonRow(theme, 'Salary Insights', '—', 'Yes', 'Yes'),
        _comparisonRow(theme, 'Analytics', 'Basic', 'Advanced', 'Advanced'),
        _comparisonRow(theme, 'Resume Tailoring', '—', '—', 'Yes'),
        _comparisonRow(theme, 'Company Research', '—', '—', 'Yes'),
      ],
    );
  }

  Widget _comparisonRow(ThemeData theme, String feature, String free, String pro, String premium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(feature, style: theme.textTheme.bodySmall)),
          Expanded(child: Text(free, style: theme.textTheme.bodySmall, textAlign: TextAlign.center)),
          Expanded(
              child: Text(pro,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center)),
          Expanded(
              child: Text(premium,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
