import 'package:equatable/equatable.dart';
import 'package:interview_prep/src/models/difficulty.dart';
import 'package:interview_prep/src/models/prep_session.dart';

class QuestionProgress extends Equatable {
  final String questionId;
  final int timesAnswered;
  final int timesCorrect;
  final int lastConfidence;
  final DateTime? lastAnsweredAt;
  final DateTime? nextReviewAt;

  const QuestionProgress({
    required this.questionId,
    this.timesAnswered = 0,
    this.timesCorrect = 0,
    this.lastConfidence = 0,
    this.lastAnsweredAt,
    this.nextReviewAt,
  });

  double get masteryScore {
    if (timesAnswered == 0) return 0.0;
    final accuracy = timesCorrect / timesAnswered;
    final confidenceFactor = lastConfidence / 5.0;
    return (accuracy * 0.7 + confidenceFactor * 0.3).clamp(0.0, 1.0);
  }

  bool get isMastered => masteryScore >= 0.8 && timesAnswered >= 2;
  bool get needsReview =>
      nextReviewAt != null && DateTime.now().isAfter(nextReviewAt!);
  bool get isNew => timesAnswered == 0;

  QuestionProgress recordAnswer(QuestionResult result) {
    final newTimesCorrect = timesCorrect + (result.isCorrect ? 1 : 0);
    final interval = _spacedInterval(timesAnswered + 1, result.isCorrect);

    return QuestionProgress(
      questionId: questionId,
      timesAnswered: timesAnswered + 1,
      timesCorrect: newTimesCorrect,
      lastConfidence: result.confidenceLevel,
      lastAnsweredAt: result.answeredAt,
      nextReviewAt: result.answeredAt.add(interval),
    );
  }

  Duration _spacedInterval(int repetition, bool wasCorrect) {
    if (!wasCorrect) return const Duration(hours: 4);
    switch (repetition) {
      case 1:
        return const Duration(days: 1);
      case 2:
        return const Duration(days: 3);
      case 3:
        return const Duration(days: 7);
      case 4:
        return const Duration(days: 14);
      default:
        return const Duration(days: 30);
    }
  }

  factory QuestionProgress.fromJson(Map<String, dynamic> json) {
    return QuestionProgress(
      questionId: json['questionId'] as String,
      timesAnswered: json['timesAnswered'] as int? ?? 0,
      timesCorrect: json['timesCorrect'] as int? ?? 0,
      lastConfidence: json['lastConfidence'] as int? ?? 0,
      lastAnsweredAt: json['lastAnsweredAt'] != null
          ? DateTime.parse(json['lastAnsweredAt'] as String)
          : null,
      nextReviewAt: json['nextReviewAt'] != null
          ? DateTime.parse(json['nextReviewAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'timesAnswered': timesAnswered,
        'timesCorrect': timesCorrect,
        'lastConfidence': lastConfidence,
        'lastAnsweredAt': lastAnsweredAt?.toIso8601String(),
        'nextReviewAt': nextReviewAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [questionId, timesAnswered];
}

class TechProgress extends Equatable {
  final String techId;
  final Map<String, QuestionProgress> questionProgress;
  final List<PrepSession> sessions;
  final int totalXp;

  const TechProgress({
    required this.techId,
    this.questionProgress = const {},
    this.sessions = const [],
    this.totalXp = 0,
  });

  int get totalQuestionsSeen => questionProgress.values
      .where((p) => p.timesAnswered > 0)
      .length;

  int get masteredCount =>
      questionProgress.values.where((p) => p.isMastered).length;

  int get needsReviewCount =>
      questionProgress.values.where((p) => p.needsReview).length;

  double overallMastery(int totalQuestions) =>
      totalQuestions > 0 ? masteredCount / totalQuestions : 0.0;

  Map<Difficulty, double> masteryByDifficulty(
      Map<Difficulty, List<String>> questionIdsByDifficulty) {
    final result = <Difficulty, double>{};
    for (final entry in questionIdsByDifficulty.entries) {
      final ids = entry.value;
      if (ids.isEmpty) {
        result[entry.key] = 0.0;
        continue;
      }
      final mastered = ids.where((id) {
        final p = questionProgress[id];
        return p != null && p.isMastered;
      }).length;
      result[entry.key] = mastered / ids.length;
    }
    return result;
  }

  int get bestStreak {
    if (sessions.isEmpty) return 0;
    int maxStreak = 0;
    int current = 0;
    for (final s in sessions) {
      if (s.accuracy >= 0.7) {
        current++;
        if (current > maxStreak) maxStreak = current;
      } else {
        current = 0;
      }
    }
    return maxStreak;
  }

  TechProgress recordResult(String questionId, QuestionResult result) {
    final existing = questionProgress[questionId] ??
        QuestionProgress(questionId: questionId);
    final updated = existing.recordAnswer(result);
    final xpEarned = result.isCorrect ? 10 : 2;

    return TechProgress(
      techId: techId,
      questionProgress: {...questionProgress, questionId: updated},
      sessions: sessions,
      totalXp: totalXp + xpEarned,
    );
  }

  TechProgress addSession(PrepSession session) {
    return TechProgress(
      techId: techId,
      questionProgress: questionProgress,
      sessions: [...sessions, session],
      totalXp: totalXp,
    );
  }

  @override
  List<Object?> get props => [techId, totalXp];
}
