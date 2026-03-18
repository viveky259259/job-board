import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/subscription.dart';

void main() {
  group('SubscriptionTier', () {
    test('free tier has correct properties', () {
      const tier = SubscriptionTier.free;
      expect(tier.label, 'Free');
      expect(tier.monthlyPrice, 0);
      expect(tier.isPaid, false);
    });

    test('pro tier has correct properties', () {
      const tier = SubscriptionTier.pro;
      expect(tier.label, 'Pro');
      expect(tier.monthlyPrice, 14.99);
      expect(tier.isPaid, true);
      expect(tier.tagline, 'Get Hired Faster');
    });

    test('premium tier has correct properties', () {
      const tier = SubscriptionTier.premium;
      expect(tier.label, 'Premium');
      expect(tier.monthlyPrice, 29.99);
      expect(tier.isPaid, true);
    });

    test('pro has pro features but not premium features', () {
      const tier = SubscriptionTier.pro;
      expect(tier.hasFeature(ProFeature.unlimitedCoverLetters), true);
      expect(tier.hasFeature(ProFeature.resumeAnalyzer), true);
      expect(tier.hasFeature(ProFeature.interviewPrep), true);
      expect(tier.hasFeature(ProFeature.resumeTailoring), false);
      expect(tier.hasFeature(ProFeature.companyResearch), false);
    });

    test('premium has all features', () {
      const tier = SubscriptionTier.premium;
      for (final feature in ProFeature.values) {
        expect(tier.hasFeature(feature), true, reason: '${feature.name} should be available');
      }
    });

    test('free has no pro features', () {
      const tier = SubscriptionTier.free;
      expect(tier.hasFeature(ProFeature.resumeAnalyzer), false);
      expect(tier.hasFeature(ProFeature.interviewPrep), false);
      expect(tier.hasFeature(ProFeature.resumeTailoring), false);
    });
  });

  group('UsageLimits', () {
    test('free tier cover letter limits', () {
      final usage = UsageLimits.forCurrentMonth();
      expect(usage.canUseCoverLetter(SubscriptionTier.free), true);
      expect(usage.coverLettersRemaining, 3);
    });

    test('incrementing cover letters reduces remaining', () {
      var usage = UsageLimits.forCurrentMonth();
      usage = usage.incrementCoverLetters();
      expect(usage.coverLettersUsed, 1);
      expect(usage.coverLettersRemaining, 2);

      usage = usage.incrementCoverLetters();
      usage = usage.incrementCoverLetters();
      expect(usage.coverLettersUsed, 3);
      expect(usage.coverLettersRemaining, 0);
      expect(usage.canUseCoverLetter(SubscriptionTier.free), false);
    });

    test('pro tier ignores limits', () {
      var usage = UsageLimits.forCurrentMonth();
      usage = usage.incrementCoverLetters();
      usage = usage.incrementCoverLetters();
      usage = usage.incrementCoverLetters();
      expect(usage.canUseCoverLetter(SubscriptionTier.pro), true);
    });

    test('intro message limits work correctly', () {
      var usage = UsageLimits.forCurrentMonth();
      for (int i = 0; i < 5; i++) {
        usage = usage.incrementIntroMessages();
      }
      expect(usage.introMessagesUsed, 5);
      expect(usage.introMessagesRemaining, 0);
      expect(usage.canUseIntroMessage(SubscriptionTier.free), false);
      expect(usage.canUseIntroMessage(SubscriptionTier.pro), true);
    });

    test('resume analyzer requires pro', () {
      final usage = UsageLimits.forCurrentMonth();
      expect(usage.canUseResumeAnalyzer(SubscriptionTier.free), false);
      expect(usage.canUseResumeAnalyzer(SubscriptionTier.pro), true);
      expect(usage.canUseResumeAnalyzer(SubscriptionTier.premium), true);
    });

    test('fromJson/toJson round-trip', () {
      final usage = UsageLimits(
        coverLettersUsed: 2,
        introMessagesUsed: 3,
        resumeAnalysesUsed: 1,
        interviewPrepsUsed: 0,
        monthKey: '2026-03',
      );

      final json = usage.toJson();
      final restored = UsageLimits.fromJson(json);

      expect(restored.coverLettersUsed, 2);
      expect(restored.introMessagesUsed, 3);
      expect(restored.monthKey, '2026-03');
    });
  });

  group('UserSubscription', () {
    test('free subscription factory', () {
      final sub = UserSubscription.free();
      expect(sub.tier, SubscriptionTier.free);
      expect(sub.isActive, true);
      expect(sub.effectiveTier, SubscriptionTier.free);
    });

    test('active pro subscription', () {
      final sub = UserSubscription(
        tier: SubscriptionTier.pro,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        usage: UsageLimits.forCurrentMonth(),
      );
      expect(sub.isActive, true);
      expect(sub.effectiveTier, SubscriptionTier.pro);
    });

    test('expired subscription falls back to free', () {
      final sub = UserSubscription(
        tier: SubscriptionTier.pro,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        usage: UsageLimits.forCurrentMonth(),
      );
      expect(sub.isActive, false);
      expect(sub.effectiveTier, SubscriptionTier.free);
    });

    test('fromJson resets usage on new month', () {
      final sub = UserSubscription.fromJson({
        'tier': 'pro',
        'usage': {
          'coverLettersUsed': 10,
          'monthKey': '2025-01',
        },
      });

      expect(sub.usage.coverLettersUsed, 0);
      expect(sub.usage.monthKey, isNot('2025-01'));
    });

    test('fromJson preserves usage for current month', () {
      final now = DateTime.now();
      final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final sub = UserSubscription.fromJson({
        'tier': 'free',
        'usage': {
          'coverLettersUsed': 2,
          'monthKey': currentMonth,
        },
      });

      expect(sub.usage.coverLettersUsed, 2);
    });

    test('copyWith works correctly', () {
      final sub = UserSubscription.free();
      final upgraded = sub.copyWith(tier: SubscriptionTier.pro);
      expect(upgraded.tier, SubscriptionTier.pro);
      expect(sub.tier, SubscriptionTier.free);
    });
  });
}
