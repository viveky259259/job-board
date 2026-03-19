import 'package:flutter/material.dart';
import 'package:interview_prep/interview_prep.dart';

class InterviewPrepLanding extends StatelessWidget {
  const InterviewPrepLanding({super.key});

  @override
  Widget build(BuildContext context) {
    final config = flutterConfig();
    final engine = PrepEngine(config: config);

    return TopicListScreen(config: config, engine: engine);
  }
}
