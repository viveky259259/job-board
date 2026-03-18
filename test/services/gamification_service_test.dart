import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/services/gamification_service.dart';
import 'package:job_board/services/profile_service.dart';

void main() {
  group('GamificationService.checkAchievements', () {
    late GamificationService service;

    setUp(() {
      // GamificationService requires ProfileService, but checkAchievements
      // is a pure function that doesn't use it, so we pass a stub.
      // For the checkAchievements test, the ProfileService is not called.
      service = GamificationService(
        profileService: _FakeProfileService(),
      );
    });

    test('first_blood unlocks with 1 application', () {
      final results = service.checkAchievements(
        gamification: const GamificationData(),
        totalApplications: 1,
        totalCoverLetters: 0,
        totalIntroMessages: 0,
        totalInterviews: 0,
        totalOffers: 0,
        profileCompleteness: 30,
        citiesApplied: 1,
        appliedWithinHour: false,
        highestMatchApplied: 60,
      );

      expect(results.any((a) => a.id == 'first_blood'), true);
    });

    test('profile_master unlocks at 100% completeness', () {
      final results = service.checkAchievements(
        gamification: const GamificationData(),
        totalApplications: 0,
        totalCoverLetters: 0,
        totalIntroMessages: 0,
        totalInterviews: 0,
        totalOffers: 0,
        profileCompleteness: 100,
        citiesApplied: 0,
        appliedWithinHour: false,
        highestMatchApplied: 0,
      );

      expect(results.any((a) => a.id == 'profile_master'), true);
    });

    test('on_fire unlocks at 7-day streak', () {
      final results = service.checkAchievements(
        gamification: const GamificationData(currentStreak: 7),
        totalApplications: 5,
        totalCoverLetters: 0,
        totalIntroMessages: 0,
        totalInterviews: 0,
        totalOffers: 0,
        profileCompleteness: 50,
        citiesApplied: 1,
        appliedWithinHour: false,
        highestMatchApplied: 70,
      );

      expect(results.any((a) => a.id == 'on_fire'), true);
    });

    test('does not re-unlock already unlocked achievements', () {
      final results = service.checkAchievements(
        gamification: const GamificationData(
          unlockedAchievements: ['first_blood'],
        ),
        totalApplications: 50,
        totalCoverLetters: 0,
        totalIntroMessages: 0,
        totalInterviews: 0,
        totalOffers: 0,
        profileCompleteness: 50,
        citiesApplied: 1,
        appliedWithinHour: false,
        highestMatchApplied: 70,
      );

      expect(results.any((a) => a.id == 'first_blood'), false);
    });

    test('perfect_match unlocks at 95%+ match', () {
      final results = service.checkAchievements(
        gamification: const GamificationData(),
        totalApplications: 1,
        totalCoverLetters: 0,
        totalIntroMessages: 0,
        totalInterviews: 0,
        totalOffers: 0,
        profileCompleteness: 50,
        citiesApplied: 1,
        appliedWithinHour: false,
        highestMatchApplied: 96,
      );

      expect(results.any((a) => a.id == 'perfect_match'), true);
    });

    test('centurion unlocks at 100 applications', () {
      final results = service.checkAchievements(
        gamification: const GamificationData(),
        totalApplications: 100,
        totalCoverLetters: 0,
        totalIntroMessages: 0,
        totalInterviews: 0,
        totalOffers: 0,
        profileCompleteness: 50,
        citiesApplied: 5,
        appliedWithinHour: false,
        highestMatchApplied: 70,
      );

      expect(results.any((a) => a.id == 'centurion'), true);
    });
  });
}

class _FakeProfileService extends Fake implements ProfileService {}
