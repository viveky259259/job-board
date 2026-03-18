import 'package:equatable/equatable.dart';
import 'package:job_board/core/constants/app_constants.dart';

enum SubscriptionTier {
  free,
  pro,
  premium;

  String get label {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  String get tagline {
    switch (this) {
      case SubscriptionTier.free:
        return 'Get Started';
      case SubscriptionTier.pro:
        return 'Get Hired Faster';
      case SubscriptionTier.premium:
        return 'Your AI Career Agent';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.pro:
        return AppConstants.proPriceMonthly;
      case SubscriptionTier.premium:
        return AppConstants.premiumPriceMonthly;
    }
  }

  double get yearlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.pro:
        return AppConstants.proPriceYearly;
      case SubscriptionTier.premium:
        return AppConstants.premiumPriceYearly;
    }
  }

  bool get isPaid => this != SubscriptionTier.free;

  bool hasFeature(ProFeature feature) {
    switch (feature) {
      case ProFeature.unlimitedCoverLetters:
      case ProFeature.unlimitedIntroMessages:
      case ProFeature.unlimitedApplications:
      case ProFeature.resumeAnalyzer:
      case ProFeature.interviewPrep:
      case ProFeature.salaryInsights:
      case ProFeature.matchBreakdown:
      case ProFeature.advancedAnalytics:
      case ProFeature.csvExport:
      case ProFeature.priorityCrawling:
        return this == SubscriptionTier.pro ||
            this == SubscriptionTier.premium;
      case ProFeature.resumeTailoring:
      case ProFeature.companyResearch:
      case ProFeature.followUpReminders:
      case ProFeature.multipleResumes:
        return this == SubscriptionTier.premium;
    }
  }
}

enum ProFeature {
  unlimitedCoverLetters('Unlimited Cover Letters', 'Generate as many AI cover letters as you need', 'pro'),
  unlimitedIntroMessages('Unlimited Intro Messages', 'Network without limits', 'pro'),
  unlimitedApplications('Unlimited Tracking', 'Track all your applications', 'pro'),
  resumeAnalyzer('Resume Analyzer', 'AI-powered resume scoring and keyword optimization', 'pro'),
  interviewPrep('Interview Prep', 'AI-generated interview questions per job', 'pro'),
  salaryInsights('Salary Insights', 'Market salary data for any role and location', 'pro'),
  matchBreakdown('Match Breakdown', 'See exactly why a job scored the way it did', 'pro'),
  advancedAnalytics('Advanced Analytics', 'Response rates, time-to-interview, funnel analysis', 'pro'),
  csvExport('CSV Export', 'Export your applications to spreadsheets', 'pro'),
  priorityCrawling('Priority Crawling', 'See new jobs 2 hours before free users', 'pro'),
  resumeTailoring('Resume Tailoring', 'AI optimizes your resume per job', 'premium'),
  companyResearch('Company Research', 'AI-generated company intelligence briefs', 'premium'),
  followUpReminders('Follow-up Reminders', 'Smart reminders to follow up on applications', 'premium'),
  multipleResumes('Multiple Resumes', 'Maintain up to 5 tailored resumes', 'premium');

  final String title;
  final String description;
  final String minTier;

  const ProFeature(this.title, this.description, this.minTier);
}

class UsageLimits extends Equatable {
  final int coverLettersUsed;
  final int introMessagesUsed;
  final int resumeAnalysesUsed;
  final int interviewPrepsUsed;
  final String monthKey;

  const UsageLimits({
    this.coverLettersUsed = 0,
    this.introMessagesUsed = 0,
    this.resumeAnalysesUsed = 0,
    this.interviewPrepsUsed = 0,
    required this.monthKey,
  });

  factory UsageLimits.forCurrentMonth() {
    final now = DateTime.now();
    return UsageLimits(
      monthKey: '${now.year}-${now.month.toString().padLeft(2, '0')}',
    );
  }

  factory UsageLimits.fromJson(Map<String, dynamic> json) {
    return UsageLimits(
      coverLettersUsed: json['coverLettersUsed'] as int? ?? 0,
      introMessagesUsed: json['introMessagesUsed'] as int? ?? 0,
      resumeAnalysesUsed: json['resumeAnalysesUsed'] as int? ?? 0,
      interviewPrepsUsed: json['interviewPrepsUsed'] as int? ?? 0,
      monthKey: json['monthKey'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'coverLettersUsed': coverLettersUsed,
        'introMessagesUsed': introMessagesUsed,
        'resumeAnalysesUsed': resumeAnalysesUsed,
        'interviewPrepsUsed': interviewPrepsUsed,
        'monthKey': monthKey,
      };

  bool canUseCoverLetter(SubscriptionTier tier) {
    if (tier.isPaid) return true;
    return coverLettersUsed < AppConstants.freeCoverLettersPerMonth;
  }

  bool canUseIntroMessage(SubscriptionTier tier) {
    if (tier.isPaid) return true;
    return introMessagesUsed < AppConstants.freeIntroMessagesPerMonth;
  }

  bool canUseResumeAnalyzer(SubscriptionTier tier) {
    return tier.hasFeature(ProFeature.resumeAnalyzer);
  }

  bool canUseInterviewPrep(SubscriptionTier tier) {
    return tier.hasFeature(ProFeature.interviewPrep);
  }

  int get coverLettersRemaining =>
      (AppConstants.freeCoverLettersPerMonth - coverLettersUsed).clamp(0, AppConstants.freeCoverLettersPerMonth);

  int get introMessagesRemaining =>
      (AppConstants.freeIntroMessagesPerMonth - introMessagesUsed).clamp(0, AppConstants.freeIntroMessagesPerMonth);

  UsageLimits incrementCoverLetters() => UsageLimits(
        coverLettersUsed: coverLettersUsed + 1,
        introMessagesUsed: introMessagesUsed,
        resumeAnalysesUsed: resumeAnalysesUsed,
        interviewPrepsUsed: interviewPrepsUsed,
        monthKey: monthKey,
      );

  UsageLimits incrementIntroMessages() => UsageLimits(
        coverLettersUsed: coverLettersUsed,
        introMessagesUsed: introMessagesUsed + 1,
        resumeAnalysesUsed: resumeAnalysesUsed,
        interviewPrepsUsed: interviewPrepsUsed,
        monthKey: monthKey,
      );

  UsageLimits incrementResumeAnalyses() => UsageLimits(
        coverLettersUsed: coverLettersUsed,
        introMessagesUsed: introMessagesUsed,
        resumeAnalysesUsed: resumeAnalysesUsed + 1,
        interviewPrepsUsed: interviewPrepsUsed,
        monthKey: monthKey,
      );

  UsageLimits incrementInterviewPreps() => UsageLimits(
        coverLettersUsed: coverLettersUsed,
        introMessagesUsed: introMessagesUsed,
        resumeAnalysesUsed: resumeAnalysesUsed,
        interviewPrepsUsed: interviewPrepsUsed + 1,
        monthKey: monthKey,
      );

  @override
  List<Object?> get props => [
        coverLettersUsed,
        introMessagesUsed,
        resumeAnalysesUsed,
        interviewPrepsUsed,
        monthKey,
      ];
}

class UserSubscription extends Equatable {
  final SubscriptionTier tier;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isYearly;
  final UsageLimits usage;

  const UserSubscription({
    this.tier = SubscriptionTier.free,
    this.startDate,
    this.endDate,
    this.isYearly = false,
    required this.usage,
  });

  factory UserSubscription.free() => UserSubscription(
        usage: UsageLimits.forCurrentMonth(),
      );

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    final currentMonth = UsageLimits.forCurrentMonth().monthKey;
    final usageData = json['usage'] as Map<String, dynamic>?;
    UsageLimits usage;

    if (usageData != null && usageData['monthKey'] == currentMonth) {
      usage = UsageLimits.fromJson(usageData);
    } else {
      usage = UsageLimits.forCurrentMonth();
    }

    return UserSubscription(
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      isYearly: json['isYearly'] as bool? ?? false,
      usage: usage,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'isYearly': isYearly,
        'usage': usage.toJson(),
      };

  bool get isActive {
    if (tier == SubscriptionTier.free) return true;
    if (endDate == null) return true;
    return DateTime.now().isBefore(endDate!);
  }

  SubscriptionTier get effectiveTier => isActive ? tier : SubscriptionTier.free;

  UserSubscription copyWith({
    SubscriptionTier? tier,
    DateTime? startDate,
    DateTime? endDate,
    bool? isYearly,
    UsageLimits? usage,
  }) {
    return UserSubscription(
      tier: tier ?? this.tier,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isYearly: isYearly ?? this.isYearly,
      usage: usage ?? this.usage,
    );
  }

  @override
  List<Object?> get props => [tier, startDate, endDate, isYearly, usage];
}
