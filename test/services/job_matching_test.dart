import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/services/job_service.dart';

void main() {
  group('calculateMatchScore', () {
    test('perfect match returns high score', () {
      const job = Job(
        id: 'j1',
        title: 'Flutter Developer',
        company: 'TestCo',
        location: 'San Francisco',
        description: 'Build Flutter apps',
        jobType: 'Full-time',
        remote: 'Remote',
        requirements: ['Flutter', 'Dart', 'Firebase'],
      );

      const profile = UserProfile(
        uid: 'u1',
        email: 'test@test.com',
        skills: ['Flutter', 'Dart', 'Firebase'],
        preferences: JobPreferences(
          targetRoles: ['Flutter Developer'],
          locations: ['San Francisco'],
          remotePreference: ['Remote'],
          jobTypes: ['Full-time'],
        ),
      );

      final score = JobService.calculateMatchScore(job, profile);
      expect(score, greaterThanOrEqualTo(90));
    });

    test('no match returns low score', () {
      const job = Job(
        id: 'j1',
        title: 'Data Scientist',
        company: 'TestCo',
        location: 'Berlin',
        description: 'ML work',
        jobType: 'Contract',
        remote: 'On-site',
        requirements: ['Python', 'TensorFlow', 'SQL'],
      );

      const profile = UserProfile(
        uid: 'u1',
        email: 'test@test.com',
        skills: ['Flutter', 'Dart'],
        preferences: JobPreferences(
          targetRoles: ['Flutter Developer'],
          locations: ['San Francisco'],
          remotePreference: ['Remote'],
          jobTypes: ['Full-time'],
        ),
      );

      final score = JobService.calculateMatchScore(job, profile);
      expect(score, lessThan(30));
    });

    test('partial match returns moderate score', () {
      const job = Job(
        id: 'j1',
        title: 'Mobile Developer',
        company: 'TestCo',
        location: 'Remote',
        description: 'Build mobile apps',
        jobType: 'Full-time',
        remote: 'Remote',
        requirements: ['Flutter', 'Swift', 'Kotlin'],
      );

      const profile = UserProfile(
        uid: 'u1',
        email: 'test@test.com',
        skills: ['Flutter', 'Dart'],
        preferences: JobPreferences(
          targetRoles: ['Software Engineer'],
          locations: [],
          remotePreference: ['Remote'],
          jobTypes: ['Full-time'],
        ),
      );

      final score = JobService.calculateMatchScore(job, profile);
      expect(score, greaterThan(30));
      expect(score, lessThan(90));
    });

    test('empty preferences gives generous scores', () {
      const job = Job(
        id: 'j1',
        title: 'Developer',
        company: 'TestCo',
        location: 'Remote',
        description: 'Code stuff',
        requirements: ['Go'],
      );

      const profile = UserProfile(
        uid: 'u1',
        email: 'test@test.com',
        skills: ['Go'],
        preferences: JobPreferences(),
      );

      final score = JobService.calculateMatchScore(job, profile);
      expect(score, greaterThanOrEqualTo(50));
    });
  });
}
