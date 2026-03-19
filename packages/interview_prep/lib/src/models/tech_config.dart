import 'package:flutter/material.dart';
import 'package:interview_prep/src/models/topic.dart';

class TechConfig {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<InterviewTopic> topics;

  const TechConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.topics,
  });

  int get totalQuestions =>
      topics.fold(0, (sum, t) => sum + t.totalQuestions);

  List<String> get allTopicNames => topics.map((t) => t.name).toList();
}
