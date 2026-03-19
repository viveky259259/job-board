import 'package:flutter_test/flutter_test.dart';
import 'package:interview_prep/interview_prep.dart';

void main() {
  group('Difficulty', () {
    test('sort order is correct', () {
      expect(Difficulty.beginner.sortOrder, lessThan(Difficulty.expert.sortOrder));
    });

    test('weight increases with difficulty', () {
      expect(Difficulty.beginner.weight, 1.0);
      expect(Difficulty.expert.weight, 3.0);
      expect(Difficulty.advanced.weight, greaterThan(Difficulty.intermediate.weight));
    });
  });

  group('InterviewQuestion', () {
    test('multiple choice check answer', () {
      const q = InterviewQuestion(
        id: 'q1',
        topic: 'test',
        subtopic: 'sub',
        difficulty: Difficulty.beginner,
        type: QuestionType.multipleChoice,
        question: 'Which is correct?',
        answer: 'B',
        options: ['A', 'B', 'C', 'D'],
        correctOptionIndex: 1,
      );

      expect(q.isMultipleChoice, true);
      expect(q.checkAnswer('1'), true);
      expect(q.checkAnswer('0'), false);
    });

    test('conceptual question properties', () {
      const q = InterviewQuestion(
        id: 'q2',
        topic: 'dart',
        subtopic: 'types',
        difficulty: Difficulty.intermediate,
        type: QuestionType.conceptual,
        question: 'What is var?',
        answer: 'A type-inferred variable',
      );

      expect(q.isMultipleChoice, false);
      expect(q.topic, 'dart');
    });
  });

  group('PrepSession', () {
    test('tracks results and accuracy', () {
      var session = PrepSession(
        id: 's1',
        techId: 'flutter',
        startedAt: DateTime.now(),
      );

      session = session.addResult(QuestionResult(
        questionId: 'q1',
        isCorrect: true,
        timeTaken: const Duration(seconds: 10),
        answeredAt: DateTime.now(),
      ));
      session = session.addResult(QuestionResult(
        questionId: 'q2',
        isCorrect: false,
        timeTaken: const Duration(seconds: 15),
        answeredAt: DateTime.now(),
      ));

      expect(session.totalAnswered, 2);
      expect(session.totalCorrect, 1);
      expect(session.accuracy, 0.5);
      expect(session.scorePercent, 50);
    });

    test('complete sets completedAt', () {
      var session = PrepSession(
        id: 's1',
        techId: 'flutter',
        startedAt: DateTime.now(),
      );

      expect(session.isComplete, false);
      session = session.complete();
      expect(session.isComplete, true);
      expect(session.completedAt, isNotNull);
    });

    test('fromJson/toJson round-trip', () {
      final session = PrepSession(
        id: 's1',
        techId: 'flutter',
        filterDifficulty: Difficulty.beginner,
        startedAt: DateTime(2024, 3, 1),
        results: [
          QuestionResult(
            questionId: 'q1',
            isCorrect: true,
            timeTaken: const Duration(seconds: 10),
            answeredAt: DateTime(2024, 3, 1),
          ),
        ],
      );

      final json = session.toJson();
      final restored = PrepSession.fromJson(json);

      expect(restored.id, 's1');
      expect(restored.techId, 'flutter');
      expect(restored.filterDifficulty, Difficulty.beginner);
      expect(restored.results.length, 1);
    });
  });

  group('QuestionProgress', () {
    test('mastery score increases with correct answers', () {
      var progress = const QuestionProgress(questionId: 'q1');
      expect(progress.isNew, true);
      expect(progress.masteryScore, 0.0);

      progress = progress.recordAnswer(QuestionResult(
        questionId: 'q1',
        isCorrect: true,
        confidenceLevel: 5,
        timeTaken: const Duration(seconds: 5),
        answeredAt: DateTime.now(),
      ));

      expect(progress.timesAnswered, 1);
      expect(progress.timesCorrect, 1);
      expect(progress.masteryScore, greaterThan(0.5));
    });

    test('isMastered requires 2+ answers and high score', () {
      var progress = const QuestionProgress(questionId: 'q1');

      progress = progress.recordAnswer(QuestionResult(
        questionId: 'q1',
        isCorrect: true,
        confidenceLevel: 5,
        timeTaken: const Duration(seconds: 5),
        answeredAt: DateTime.now(),
      ));
      expect(progress.isMastered, false); // only 1 answer

      progress = progress.recordAnswer(QuestionResult(
        questionId: 'q1',
        isCorrect: true,
        confidenceLevel: 5,
        timeTaken: const Duration(seconds: 5),
        answeredAt: DateTime.now(),
      ));
      expect(progress.isMastered, true);
    });

    test('spaced repetition sets next review date', () {
      var progress = const QuestionProgress(questionId: 'q1');
      final now = DateTime.now();

      progress = progress.recordAnswer(QuestionResult(
        questionId: 'q1',
        isCorrect: true,
        confidenceLevel: 4,
        timeTaken: const Duration(seconds: 10),
        answeredAt: now,
      ));

      expect(progress.nextReviewAt, isNotNull);
      expect(progress.nextReviewAt!.isAfter(now), true);
    });

    test('incorrect answer schedules earlier review', () {
      var progress = const QuestionProgress(questionId: 'q1');
      final now = DateTime.now();

      progress = progress.recordAnswer(QuestionResult(
        questionId: 'q1',
        isCorrect: false,
        confidenceLevel: 1,
        timeTaken: const Duration(seconds: 10),
        answeredAt: now,
      ));

      // Incorrect should schedule review in 4 hours
      final diff = progress.nextReviewAt!.difference(now);
      expect(diff.inHours, 4);
    });
  });

  group('TechProgress', () {
    test('records results and tracks XP', () {
      var tp = const TechProgress(techId: 'flutter');

      tp = tp.recordResult(
        'q1',
        QuestionResult(
          questionId: 'q1',
          isCorrect: true,
          timeTaken: const Duration(seconds: 5),
          answeredAt: DateTime.now(),
        ),
      );

      expect(tp.totalXp, 10);
      expect(tp.totalQuestionsSeen, 1);
    });

    test('incorrect answers give less XP', () {
      var tp = const TechProgress(techId: 'flutter');

      tp = tp.recordResult(
        'q1',
        QuestionResult(
          questionId: 'q1',
          isCorrect: false,
          timeTaken: const Duration(seconds: 5),
          answeredAt: DateTime.now(),
        ),
      );

      expect(tp.totalXp, 2);
    });
  });
}
