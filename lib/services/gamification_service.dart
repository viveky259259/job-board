import 'package:job_board/core/constants/app_constants.dart';
import 'package:job_board/models/achievement.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/services/profile_service.dart';
import 'package:intl/intl.dart';

class GamificationService {
  final ProfileService _profileService;

  GamificationService({required ProfileService profileService})
      : _profileService = profileService;

  Future<GamificationData> awardXp(String uid, int xp, GamificationData current) async {
    int newXp = current.xp + xp;
    int newLevel = current.level;

    while (newLevel < AppConstants.levelThresholds.length &&
        newXp >= AppConstants.levelThresholds[newLevel]) {
      newLevel++;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int newStreak = current.currentStreak;
    int longestStreak = current.longestStreak;

    if (current.lastActiveDate != null) {
      final lastDate = DateTime.tryParse(current.lastActiveDate!);
      if (lastDate != null) {
        final diff = DateTime.now().difference(lastDate).inDays;
        if (diff == 1) {
          newStreak++;
        } else if (diff > 1) {
          newStreak = 1;
        }
      }
    } else {
      newStreak = 1;
    }

    if (newStreak > longestStreak) {
      longestStreak = newStreak;
    }

    final updated = current.copyWith(
      xp: newXp,
      level: newLevel,
      currentStreak: newStreak,
      longestStreak: longestStreak,
      lastActiveDate: today,
    );

    await _profileService.updateGamification(uid, updated);
    return updated;
  }

  Future<GamificationData> handleDailyLogin(String uid, GamificationData current) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (current.lastActiveDate == today) return current;
    return awardXp(uid, AppConstants.xpDailyLogin, current);
  }

  Future<GamificationData> handleJobSaved(String uid, GamificationData current) async {
    return awardXp(uid, AppConstants.xpSaveJob, current);
  }

  Future<GamificationData> handleJobApplied(
      String uid, GamificationData current, int matchScore) async {
    final xp = matchScore >= AppConstants.highMatchThreshold
        ? AppConstants.xpApplyHighMatch
        : AppConstants.xpApplyJob;
    return awardXp(uid, xp, current);
  }

  Future<GamificationData> handleCoverLetterGenerated(
      String uid, GamificationData current) async {
    return awardXp(uid, AppConstants.xpCustomizeCoverLetter, current);
  }

  Future<GamificationData> handleIntroMessageSent(
      String uid, GamificationData current) async {
    return awardXp(uid, AppConstants.xpSendIntroMessage, current);
  }

  Future<GamificationData> handleStatusUpdate(
      String uid, GamificationData current, String newStatus) async {
    int xp = AppConstants.xpUpdateStatus;
    if (newStatus == 'interviewing') xp = AppConstants.xpReceiveInterview;
    if (newStatus == 'offered') xp = AppConstants.xpReceiveOffer;
    return awardXp(uid, xp, current);
  }

  List<Achievement> checkAchievements({
    required GamificationData gamification,
    required int totalApplications,
    required int totalCoverLetters,
    required int totalIntroMessages,
    required int totalInterviews,
    required int totalOffers,
    required int profileCompleteness,
    required int citiesApplied,
    required bool appliedWithinHour,
    required int highestMatchApplied,
  }) {
    final newlyUnlocked = <Achievement>[];
    final achievements = Achievement.all;

    for (final achievement in achievements) {
      if (gamification.unlockedAchievements.contains(achievement.id)) continue;

      bool unlocked = false;
      switch (achievement.id) {
        case 'first_blood':
          unlocked = totalApplications >= 1;
        case 'wordsmith':
          unlocked = totalCoverLetters >= 10;
        case 'on_fire':
          unlocked = gamification.currentStreak >= 7;
        case 'perfect_match':
          unlocked = highestMatchApplied >= 95;
        case 'interview_champ':
          unlocked = totalInterviews >= 5;
        case 'profile_master':
          unlocked = profileCompleteness >= 100;
        case 'networker':
          unlocked = totalIntroMessages >= 20;
        case 'quick_draw':
          unlocked = appliedWithinHour;
        case 'explorer':
          unlocked = citiesApplied >= 5;
        case 'diamond_hands':
          unlocked = gamification.longestStreak >= 30;
        case 'centurion':
          unlocked = totalApplications >= 100;
        case 'offer_collector':
          unlocked = totalOffers >= 3;
      }

      if (unlocked) {
        newlyUnlocked.add(achievement.unlock());
      }
    }

    return newlyUnlocked;
  }
}
