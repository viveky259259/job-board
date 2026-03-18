import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/job.dart';

void main() {
  group('Job', () {
    test('fromJson/toJson round-trip', () {
      final job = Job(
        id: 'j1',
        title: 'Flutter Developer',
        company: 'TestCo',
        location: 'Remote',
        description: 'Build stuff',
        salaryMin: 100000,
        salaryMax: 150000,
        jobType: 'Full-time',
        remote: 'Remote',
        source: 'demo',
        requirements: ['Flutter', 'Dart'],
        tags: ['flutter', 'dart'],
        postedAt: DateTime(2024, 3, 1),
      );

      final json = job.toJson();
      final restored = Job.fromJson(json);

      expect(restored.id, job.id);
      expect(restored.title, job.title);
      expect(restored.company, job.company);
      expect(restored.salaryMin, 100000);
      expect(restored.requirements, ['Flutter', 'Dart']);
    });

    test('salaryRange formats correctly', () {
      const both = Job(
        id: '1', title: 't', company: 'c', location: 'l',
        description: 'd', salaryMin: 80000, salaryMax: 120000,
      );
      expect(both.salaryRange, '\$80000 - \$120000 USD');

      const minOnly = Job(
        id: '2', title: 't', company: 'c', location: 'l',
        description: 'd', salaryMin: 80000,
      );
      expect(minOnly.salaryRange, 'From \$80000 USD');

      const none = Job(
        id: '3', title: 't', company: 'c', location: 'l',
        description: 'd',
      );
      expect(none.salaryRange, 'Not specified');
    });

    test('isExpired works correctly', () {
      final active = Job(
        id: '1', title: 't', company: 'c', location: 'l',
        description: 'd',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
      expect(active.isExpired, false);

      final expired = Job(
        id: '2', title: 't', company: 'c', location: 'l',
        description: 'd',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expired.isExpired, true);

      const noExpiry = Job(
        id: '3', title: 't', company: 'c', location: 'l',
        description: 'd',
      );
      expect(noExpiry.isExpired, false);
    });

    test('copyWith creates modified copy', () {
      const job = Job(
        id: '1', title: 'Old Title', company: 'c',
        location: 'l', description: 'd', matchScore: 50,
      );

      final updated = job.copyWith(title: 'New Title', matchScore: 90);
      expect(updated.title, 'New Title');
      expect(updated.matchScore, 90);
      expect(updated.company, 'c');
      expect(job.title, 'Old Title'); // original unchanged
    });
  });
}
