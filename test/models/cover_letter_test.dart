import 'package:flutter_test/flutter_test.dart';
import 'package:job_board/models/cover_letter.dart';

void main() {
  group('CoverLetter', () {
    test('fromJson/toJson round-trip', () {
      final cl = CoverLetter(
        id: 'cl1',
        userId: 'u1',
        jobId: 'j1',
        content: 'Dear Hiring Manager...',
        tone: ContentTone.professional,
        atsScore: 85,
        version: 1,
        createdAt: DateTime(2024, 3, 1),
      );

      final json = cl.toJson();
      final restored = CoverLetter.fromJson(json);

      expect(restored.id, cl.id);
      expect(restored.content, cl.content);
      expect(restored.tone, ContentTone.professional);
      expect(restored.atsScore, 85);
    });

    test('copyWith works correctly', () {
      final cl = CoverLetter(
        id: 'cl1', userId: 'u1', jobId: 'j1',
        content: 'Original', createdAt: DateTime.now(),
      );

      final updated = cl.copyWith(content: 'Updated', atsScore: 90);
      expect(updated.content, 'Updated');
      expect(updated.atsScore, 90);
      expect(updated.id, 'cl1');
    });
  });

  group('IntroMessage', () {
    test('fromJson/toJson round-trip', () {
      final msg = IntroMessage(
        id: 'im1',
        userId: 'u1',
        jobId: 'j1',
        content: 'Hi, I noticed...',
        tone: ContentTone.casual,
        platform: 'LinkedIn',
        createdAt: DateTime(2024, 3, 1),
      );

      final json = msg.toJson();
      final restored = IntroMessage.fromJson(json);

      expect(restored.id, msg.id);
      expect(restored.content, msg.content);
      expect(restored.tone, ContentTone.casual);
      expect(restored.platform, 'LinkedIn');
    });
  });
}
