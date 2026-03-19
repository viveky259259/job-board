import 'package:interview_prep/src/models/difficulty.dart';
import 'package:interview_prep/src/models/prep_session.dart';
import 'package:interview_prep/src/models/progress.dart';
import 'package:interview_prep/src/models/question.dart';
import 'package:interview_prep/src/models/tech_config.dart';
import 'package:uuid/uuid.dart';

enum QuizMode {
  practice,
  timed,
  review,
  weakAreas,
}

class PrepEngine {
  final TechConfig config;
  TechProgress _progress;

  PrepEngine({required this.config, TechProgress? progress})
      : _progress = progress ?? TechProgress(techId: config.id);

  TechProgress get progress => _progress;

  PrepSession startSession({
    Difficulty? difficulty,
    String? topicId,
    QuizMode mode = QuizMode.practice,
    int questionCount = 10,
  }) {
    return PrepSession(
      id: const Uuid().v4(),
      techId: config.id,
      filterDifficulty: difficulty,
      filterTopic: topicId,
      startedAt: DateTime.now(),
    );
  }

  List<InterviewQuestion> _selectQuestions({
    Difficulty? difficulty,
    String? topicId,
    QuizMode mode = QuizMode.practice,
    int count = 10,
  }) {
    var pool = config.topics.expand((t) => t.questions).toList();

    if (difficulty != null) {
      pool = pool.where((q) => q.difficulty == difficulty).toList();
    }
    if (topicId != null) {
      pool = pool.where((q) => q.topic == topicId).toList();
    }

    switch (mode) {
      case QuizMode.review:
        pool = _prioritizeReview(pool);
      case QuizMode.weakAreas:
        pool = _prioritizeWeak(pool);
      case QuizMode.practice:
      case QuizMode.timed:
        pool.shuffle();
    }

    return pool.take(count).toList();
  }

  List<InterviewQuestion> getQuestionsForSession({
    Difficulty? difficulty,
    String? topicId,
    QuizMode mode = QuizMode.practice,
    int count = 10,
  }) {
    return _selectQuestions(
      difficulty: difficulty,
      topicId: topicId,
      mode: mode,
      count: count,
    );
  }

  List<InterviewQuestion> _prioritizeReview(List<InterviewQuestion> pool) {
    final needsReview = <InterviewQuestion>[];
    final rest = <InterviewQuestion>[];

    for (final q in pool) {
      final p = _progress.questionProgress[q.id];
      if (p != null && p.needsReview) {
        needsReview.add(q);
      } else {
        rest.add(q);
      }
    }

    needsReview.shuffle();
    rest.shuffle();
    return [...needsReview, ...rest];
  }

  List<InterviewQuestion> _prioritizeWeak(List<InterviewQuestion> pool) {
    final scored = pool.map((q) {
      final p = _progress.questionProgress[q.id];
      final mastery = p?.masteryScore ?? 0.0;
      return (question: q, mastery: mastery);
    }).toList();

    scored.sort((a, b) => a.mastery.compareTo(b.mastery));
    return scored.map((s) => s.question).toList();
  }

  void recordAnswer(String questionId, QuestionResult result) {
    _progress = _progress.recordResult(questionId, result);
  }

  PrepSession completeSession(PrepSession session) {
    final completed = session.complete();
    _progress = _progress.addSession(completed);
    return completed;
  }

  Map<String, dynamic> getStats() {
    final allQuestions = config.totalQuestions;
    return {
      'totalQuestions': allQuestions,
      'questionsSeen': _progress.totalQuestionsSeen,
      'mastered': _progress.masteredCount,
      'needsReview': _progress.needsReviewCount,
      'overallMastery': _progress.overallMastery(allQuestions),
      'totalSessions': _progress.sessions.length,
      'totalXp': _progress.totalXp,
      'bestStreak': _progress.bestStreak,
    };
  }

  Map<Difficulty, double> getMasteryByDifficulty() {
    final idsByDifficulty = <Difficulty, List<String>>{};
    for (final d in Difficulty.values) {
      idsByDifficulty[d] = config.topics
          .expand((t) => t.questionsForDifficulty(d))
          .map((q) => q.id)
          .toList();
    }
    return _progress.masteryByDifficulty(idsByDifficulty);
  }

  Map<String, double> getMasteryByTopic() {
    final result = <String, double>{};
    for (final topic in config.topics) {
      final ids = topic.questions.map((q) => q.id).toList();
      if (ids.isEmpty) {
        result[topic.id] = 0.0;
        continue;
      }
      final mastered = ids.where((id) {
        final p = _progress.questionProgress[id];
        return p != null && p.isMastered;
      }).length;
      result[topic.id] = mastered / ids.length;
    }
    return result;
  }
}
