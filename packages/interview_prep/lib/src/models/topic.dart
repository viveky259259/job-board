import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:interview_prep/src/models/difficulty.dart';
import 'package:interview_prep/src/models/question.dart';

class InterviewTopic extends Equatable {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> subtopics;
  final List<InterviewQuestion> questions;

  const InterviewTopic({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.subtopics = const [],
    this.questions = const [],
  });

  int get totalQuestions => questions.length;

  Map<Difficulty, List<InterviewQuestion>> get questionsByDifficulty {
    final map = <Difficulty, List<InterviewQuestion>>{};
    for (final d in Difficulty.values) {
      map[d] = questions.where((q) => q.difficulty == d).toList();
    }
    return map;
  }

  List<InterviewQuestion> questionsForDifficulty(Difficulty d) =>
      questions.where((q) => q.difficulty == d).toList();

  @override
  List<Object?> get props => [id, name];
}
