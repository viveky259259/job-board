import 'package:equatable/equatable.dart';
import 'package:interview_prep/src/models/difficulty.dart';

enum QuestionType {
  conceptual,
  coding,
  scenario,
  multipleChoice,
  trueFalse,
}

class InterviewQuestion extends Equatable {
  final String id;
  final String topic;
  final String subtopic;
  final Difficulty difficulty;
  final QuestionType type;
  final String question;
  final String answer;
  final String? explanation;
  final String? codeSnippet;
  final List<String>? options;
  final int? correctOptionIndex;
  final List<String> tags;
  final String? followUp;

  const InterviewQuestion({
    required this.id,
    required this.topic,
    required this.subtopic,
    required this.difficulty,
    required this.type,
    required this.question,
    required this.answer,
    this.explanation,
    this.codeSnippet,
    this.options,
    this.correctOptionIndex,
    this.tags = const [],
    this.followUp,
  });

  bool get isMultipleChoice =>
      type == QuestionType.multipleChoice || type == QuestionType.trueFalse;

  bool checkAnswer(String userAnswer) {
    if (isMultipleChoice && correctOptionIndex != null) {
      return userAnswer.trim() == correctOptionIndex.toString();
    }
    return userAnswer.trim().toLowerCase() == answer.trim().toLowerCase();
  }

  @override
  List<Object?> get props => [id, topic, difficulty];
}
