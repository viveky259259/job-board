import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/achievement.dart';

void main() {
  group('Achievement', () {
    test('all achievements are defined', () {
      final achievements = Achievement.all;
      expect(achievements.length, greaterThanOrEqualTo(10));

      final ids = achievements.map((a) => a.id).toSet();
      expect(ids.length, achievements.length); // no duplicates
    });

    test('unlock creates unlocked copy', () {
      final achievement = Achievement.all.first;
      expect(achievement.isUnlocked, false);

      final unlocked = achievement.unlock();
      expect(unlocked.isUnlocked, true);
      expect(unlocked.unlockedAt, isNotNull);
      expect(unlocked.id, achievement.id);
    });

    test('all achievements have non-zero XP rewards', () {
      for (final a in Achievement.all) {
        expect(a.xpReward, greaterThan(0), reason: '${a.id} should have XP reward');
      }
    });
  });
}
