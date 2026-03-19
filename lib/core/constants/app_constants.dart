class AppConstants {
  AppConstants._();

  static const String appName = 'JobHunter AI';
  static const String appTagline = 'Your agentic job search companion';

  // XP thresholds per level
  static const List<int> levelThresholds = [
    0, // Level 1: Job Seeker
    500, // Level 2: Active Hunter
    1500, // Level 3: Application Pro
    3500, // Level 4: Interview Ready
    7000, // Level 5: Career Warrior
    15000, // Level 6: Job Master
    30000, // Level 7: Hiring Magnet
  ];

  static const List<String> levelNames = [
    'Job Seeker',
    'Active Hunter',
    'Application Pro',
    'Interview Ready',
    'Career Warrior',
    'Job Master',
    'Hiring Magnet',
  ];

  // XP rewards
  static const int xpCompleteProfile = 50;
  static const int xpDailyLogin = 10;
  static const int xpSaveJob = 5;
  static const int xpApplyJob = 25;
  static const int xpApplyHighMatch = 50;
  static const int xpCustomizeCoverLetter = 15;
  static const int xpSendIntroMessage = 20;
  static const int xpUpdateStatus = 10;
  static const int xpReceiveInterview = 100;
  static const int xpReceiveOffer = 500;
  static const int xpWeeklyChallenge = 200;

  static const int maxSaveXpPerDay = 20;
  static const int highMatchThreshold = 80;

  // Profile completeness weights
  static const Map<String, int> profileWeights = {
    'name': 10,
    'headline': 10,
    'summary': 15,
    'skills': 20,
    'experience': 25,
    'education': 10,
    'preferences': 10,
  };

  // Job sources
  static const List<String> jobSources = [
    'remoteok',
    'linkedin',
    'ycombinator',
    'google',
    'adzuna',
    'manual',
  ];

  // Application statuses
  static const List<String> applicationStatuses = [
    'saved',
    'applied',
    'interviewing',
    'offered',
    'rejected',
    'ghosted',
  ];

  static const List<String> jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance',
  ];

  static const List<String> remoteOptions = [
    'Remote',
    'Hybrid',
    'On-site',
  ];

  static const List<String> experienceLevels = [
    'Entry Level',
    'Mid Level',
    'Senior',
    'Lead',
    'Director',
    'Executive',
  ];

  // Subscription limits (Free tier)
  static const int freeCoverLettersPerMonth = 3;
  static const int freeIntroMessagesPerMonth = 5;
  static const int freeActiveApplications = 10;
  static const int freeResumeAnalyses = 0;
  static const int freeInterviewPreps = 0;

  // Subscription pricing
  static const double proPriceMonthly = 14.99;
  static const double premiumPriceMonthly = 29.99;
  static const double proPriceYearly = 119.99;
  static const double premiumPriceYearly = 239.99;
}
