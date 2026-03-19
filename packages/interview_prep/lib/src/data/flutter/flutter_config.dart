import 'package:flutter/material.dart';
import 'package:interview_prep/src/models/tech_config.dart';
import 'package:interview_prep/src/models/topic.dart';
import 'package:interview_prep/src/data/flutter/beginner_questions.dart';
import 'package:interview_prep/src/data/flutter/intermediate_questions.dart';
import 'package:interview_prep/src/data/flutter/advanced_questions.dart';
import 'package:interview_prep/src/data/flutter/expert_questions.dart';
import 'package:interview_prep/src/data/flutter/flutter_topics.dart';

TechConfig flutterConfig() {
  final topics = flutterTopics();
  final allQuestions = [
    ...beginnerQuestions(),
    ...intermediateQuestions(),
    ...advancedQuestions(),
    ...expertQuestions(),
  ];

  return TechConfig(
    id: 'flutter',
    name: 'Flutter',
    description: 'Comprehensive Flutter & Dart interview preparation from beginner to expert',
    icon: Icons.flutter_dash,
    color: const Color(0xFF027DFD),
    topics: topics.map((topic) {
      final topicQuestions = allQuestions.where((q) => q.topic == topic.id).toList();
      return InterviewTopic(
        id: topic.id,
        name: topic.name,
        description: topic.description,
        icon: topic.icon,
        subtopics: topic.subtopics,
        questions: topicQuestions,
      );
    }).toList(),
  );
}
