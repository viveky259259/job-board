import 'package:equatable/equatable.dart';
import 'package:interview_prep/src/models/difficulty.dart';

class QuestionResult extends Equatable {
  final String questionId;
  final bool isCorrect;
  final int confidenceLevel; // 1-5
  final Duration timeTaken;
  final DateTime answeredAt;
  final String? userAnswer;

  const QuestionResult({
    required this.questionId,
    required this.isCorrect,
    this.confidenceLevel = 3,
    required this.timeTaken,
    required this.answeredAt,
    this.userAnswer,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'] as String,
      isCorrect: json['isCorrect'] as bool,
      confidenceLevel: json['confidenceLevel'] as int? ?? 3,
      timeTaken: Duration(milliseconds: json['timeTakenMs'] as int? ?? 0),
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      userAnswer: json['userAnswer'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'isCorrect': isCorrect,
        'confidenceLevel': confidenceLevel,
        'timeTakenMs': timeTaken.inMilliseconds,
        'answeredAt': answeredAt.toIso8601String(),
        'userAnswer': userAnswer,
      };

  @override
  List<Object?> get props => [questionId, isCorrect, answeredAt];
}

class PrepSession extends Equatable {
  final String id;
  final String techId;
  final Difficulty? filterDifficulty;
  final String? filterTopic;
  final List<QuestionResult> results;
  final DateTime startedAt;
  final DateTime? completedAt;

  const PrepSession({
    required this.id,
    required this.techId,
    this.filterDifficulty,
    this.filterTopic,
    this.results = const [],
    required this.startedAt,
    this.completedAt,
  });

  int get totalAnswered => results.length;
  int get totalCorrect => results.where((r) => r.isCorrect).length;
  int get totalIncorrect => totalAnswered - totalCorrect;

  double get accuracy =>
      totalAnswered > 0 ? totalCorrect / totalAnswered : 0.0;

  int get scorePercent => (accuracy * 100).round();

  Duration get totalTime =>
      results.fold(Duration.zero, (sum, r) => sum + r.timeTaken);

  Duration get avgTimePerQuestion =>
      totalAnswered > 0
          ? Duration(milliseconds: totalTime.inMilliseconds ~/ totalAnswered)
          : Duration.zero;

  double get avgConfidence =>
      totalAnswered > 0
          ? results.map((r) => r.confidenceLevel).reduce((a, b) => a + b) /
              totalAnswered
          : 0.0;

  bool get isComplete => completedAt != null;

  PrepSession addResult(QuestionResult result) {
    return PrepSession(
      id: id,
      techId: techId,
      filterDifficulty: filterDifficulty,
      filterTopic: filterTopic,
      results: [...results, result],
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  PrepSession complete() {
    return PrepSession(
      id: id,
      techId: techId,
      filterDifficulty: filterDifficulty,
      filterTopic: filterTopic,
      results: results,
      startedAt: startedAt,
      completedAt: DateTime.now(),
    );
  }

  factory PrepSession.fromJson(Map<String, dynamic> json) {
    return PrepSession(
      id: json['id'] as String,
      techId: json['techId'] as String,
      filterDifficulty: json['filterDifficulty'] != null
          ? Difficulty.values.firstWhere((d) => d.name == json['filterDifficulty'])
          : null,
      filterTopic: json['filterTopic'] as String?,
      results: (json['results'] as List<dynamic>?)
              ?.map((r) => QuestionResult.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'techId': techId,
        'filterDifficulty': filterDifficulty?.name,
        'filterTopic': filterTopic,
        'results': results.map((r) => r.toJson()).toList(),
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, techId];
}
