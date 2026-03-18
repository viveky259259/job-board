import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('fromJson/toJson round-trip', () {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@test.com',
        name: 'Test User',
        headline: 'Flutter Developer',
        summary: 'Experienced developer',
        skills: ['Flutter', 'Dart', 'Firebase'],
        experience: [
          const WorkExperience(
            title: 'Developer',
            company: 'TestCo',
            startDate: '2023-01',
            endDate: '2024-01',
          ),
        ],
        education: [
          const Education(
            school: 'MIT',
            degree: 'BS',
            field: 'CS',
            year: '2022',
          ),
        ],
        preferences: const JobPreferences(
          targetRoles: ['Flutter Developer'],
          locations: ['San Francisco'],
          salaryMin: 100000,
          salaryMax: 200000,
          remotePreference: ['Remote'],
          jobTypes: ['Full-time'],
        ),
        createdAt: DateTime(2024, 1, 1),
      );

      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.uid, profile.uid);
      expect(restored.email, profile.email);
      expect(restored.name, profile.name);
      expect(restored.headline, profile.headline);
      expect(restored.skills, profile.skills);
      expect(restored.experience.length, 1);
      expect(restored.education.length, 1);
      expect(restored.preferences.targetRoles, ['Flutter Developer']);
    });

    test('profileCompleteness calculates correctly', () {
      const empty = UserProfile(uid: 'u1', email: 'a@b.com');
      expect(empty.profileCompleteness, 0);

      final partial = UserProfile(
        uid: 'u2',
        email: 'a@b.com',
        name: 'Test',
        headline: 'Dev',
        skills: ['Dart'],
      );
      expect(partial.profileCompleteness, 40); // name(10) + headline(10) + skills(20)

      final full = UserProfile(
        uid: 'u3',
        email: 'a@b.com',
        name: 'Test',
        headline: 'Dev',
        summary: 'About me',
        skills: ['Dart'],
        experience: [const WorkExperience(title: 'Dev', company: 'Co')],
        education: [const Education(school: 'Uni', degree: 'BS')],
        preferences: const JobPreferences(targetRoles: ['Dev']),
      );
      expect(full.profileCompleteness, 100);
    });

    test('copyWith creates modified copy', () {
      const profile = UserProfile(uid: 'u1', email: 'a@b.com', name: 'Old');
      final updated = profile.copyWith(name: 'New');
      expect(updated.name, 'New');
      expect(updated.uid, 'u1');
      expect(profile.name, 'Old');
    });
  });

  group('GamificationData', () {
    test('levelProgress calculates correctly', () {
      const data = GamificationData(xp: 250, level: 1);
      expect(data.levelProgress, closeTo(0.5, 0.01)); // 250/500

      const maxed = GamificationData(xp: 500, level: 2);
      expect(maxed.levelProgress, closeTo(0.0, 0.01)); // 500-500 / 1000 = 0/1000

      const high = GamificationData(xp: 30000, level: 7);
      expect(high.levelProgress, 1.0);
    });

    test('xpForNextLevel returns correct value', () {
      const data = GamificationData(xp: 300, level: 1);
      expect(data.xpForNextLevel, 200); // 500 - 300

      const maxLevel = GamificationData(
        xp: 30000,
        level: 7, // max level index
      );
      expect(maxLevel.xpForNextLevel, 0);
    });

    test('levelName returns correct name', () {
      const l1 = GamificationData(level: 1);
      expect(l1.levelName, 'Job Seeker');

      const l5 = GamificationData(level: 5);
      expect(l5.levelName, 'Career Warrior');
    });
  });

  group('WorkExperience', () {
    test('fromJson/toJson round-trip', () {
      const exp = WorkExperience(
        title: 'Senior Developer',
        company: 'TechCo',
        startDate: '2022-01',
        endDate: '2024-01',
        description: 'Built stuff',
      );

      final json = exp.toJson();
      final restored = WorkExperience.fromJson(json);

      expect(restored.title, exp.title);
      expect(restored.company, exp.company);
      expect(restored.startDate, exp.startDate);
      expect(restored.description, exp.description);
    });
  });

  group('JobPreferences', () {
    test('isConfigured returns true when roles set', () {
      const empty = JobPreferences();
      expect(empty.isConfigured, false);

      const configured = JobPreferences(targetRoles: ['Developer']);
      expect(configured.isConfigured, true);
    });
  });
}
