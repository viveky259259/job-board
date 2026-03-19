import 'package:flutter_test/flutter_test.dart';
import 'package:interview_prep/interview_prep.dart';

void main() {
  group('Flutter Config', () {
    late TechConfig config;

    setUp(() {
      config = flutterConfig();
    });

    test('has correct id and name', () {
      expect(config.id, 'flutter');
      expect(config.name, 'Flutter');
    });

    test('has 12 topics', () {
      expect(config.topics.length, 12);
    });

    test('topics include key areas', () {
      final topicIds = config.topics.map((t) => t.id).toSet();
      expect(topicIds, contains('dart_fundamentals'));
      expect(topicIds, contains('widgets'));
      expect(topicIds, contains('state_management'));
      expect(topicIds, contains('internals'));
      expect(topicIds, contains('performance'));
      expect(topicIds, contains('testing'));
    });

    test('has questions across all difficulty levels', () {
      final allQuestions = config.topics.expand((t) => t.questions).toList();
      final difficulties = allQuestions.map((q) => q.difficulty).toSet();

      expect(difficulties, contains(Difficulty.beginner));
      expect(difficulties, contains(Difficulty.intermediate));
      expect(difficulties, contains(Difficulty.advanced));
      expect(difficulties, contains(Difficulty.expert));
    });

    test('has at least 50 questions total', () {
      expect(config.totalQuestions, greaterThanOrEqualTo(50));
    });

    test('all questions have non-empty content', () {
      final allQuestions = config.topics.expand((t) => t.questions).toList();
      for (final q in allQuestions) {
        expect(q.question.isNotEmpty, true, reason: '${q.id} has empty question');
        expect(q.answer.isNotEmpty, true, reason: '${q.id} has empty answer');
        expect(q.topic.isNotEmpty, true, reason: '${q.id} has empty topic');
      }
    });

    test('all question IDs are unique', () {
      final allQuestions = config.topics.expand((t) => t.questions).toList();
      final ids = allQuestions.map((q) => q.id).toSet();
      expect(ids.length, allQuestions.length);
    });

    test('multiple choice questions have valid options', () {
      final allQuestions = config.topics.expand((t) => t.questions).toList();
      final mcQuestions = allQuestions.where((q) => q.isMultipleChoice);

      for (final q in mcQuestions) {
        expect(q.options, isNotNull, reason: '${q.id} missing options');
        expect(q.options!.length, greaterThanOrEqualTo(2),
            reason: '${q.id} needs at least 2 options');
        expect(q.correctOptionIndex, isNotNull,
            reason: '${q.id} missing correctOptionIndex');
        expect(q.correctOptionIndex!, lessThan(q.options!.length),
            reason: '${q.id} correctOptionIndex out of range');
      }
    });

    test('each topic has at least 1 question', () {
      for (final topic in config.topics) {
        expect(topic.totalQuestions, greaterThan(0),
            reason: '${topic.name} has no questions');
      }
    });
  });

  group('PrepEngine with Flutter config', () {
    late PrepEngine engine;

    setUp(() {
      engine = PrepEngine(config: flutterConfig());
    });

    test('getStats returns correct initial state', () {
      final stats = engine.getStats();
      expect(stats['questionsSeen'], 0);
      expect(stats['mastered'], 0);
      expect(stats['totalSessions'], 0);
      expect(stats['totalXp'], 0);
      expect(stats['totalQuestions'], greaterThan(0));
    });

    test('getQuestionsForSession returns questions', () {
      final questions = engine.getQuestionsForSession(count: 5);
      expect(questions.length, 5);
    });

    test('filtering by difficulty works', () {
      final questions = engine.getQuestionsForSession(
        difficulty: Difficulty.beginner,
        count: 50,
      );
      for (final q in questions) {
        expect(q.difficulty, Difficulty.beginner);
      }
    });

    test('filtering by topic works', () {
      final questions = engine.getQuestionsForSession(
        topicId: 'widgets',
        count: 50,
      );
      for (final q in questions) {
        expect(q.topic, 'widgets');
      }
    });

    test('recording answers updates progress', () {
      engine.recordAnswer(
        'b_dart_1',
        QuestionResult(
          questionId: 'b_dart_1',
          isCorrect: true,
          timeTaken: const Duration(seconds: 10),
          answeredAt: DateTime.now(),
        ),
      );

      final stats = engine.getStats();
      expect(stats['questionsSeen'], 1);
      expect(stats['totalXp'], 10);
    });

    test('mastery by difficulty returns all levels', () {
      final mastery = engine.getMasteryByDifficulty();
      expect(mastery.keys.length, Difficulty.values.length);
    });

    test('mastery by topic returns all topics', () {
      final mastery = engine.getMasteryByTopic();
      expect(mastery.keys.length, greaterThan(0));
    });
  });
}
