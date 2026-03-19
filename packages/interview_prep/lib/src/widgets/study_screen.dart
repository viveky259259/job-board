import 'package:flutter/material.dart';
import 'package:interview_prep/src/models/question.dart';

class StudyScreen extends StatefulWidget {
  final List<InterviewQuestion> questions;
  final Color accentColor;

  const StudyScreen({
    super.key,
    required this.questions,
    this.accentColor = Colors.blue,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  InterviewQuestion get _current => widget.questions[_currentIndex];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Study — ${_current.subtopic}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1} / ${widget.questions.length}',
                style: theme.textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.questions.length,
            valueColor: AlwaysStoppedAnimation(widget.accentColor),
            backgroundColor: widget.accentColor.withValues(alpha: 0.1),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _difficultyBadge(theme),
                  const SizedBox(height: 12),
                  Text(_current.question,
                      style: theme.textTheme.titleMedium?.copyWith(height: 1.5)),
                  if (_current.codeSnippet != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        _current.codeSnippet!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (!_showAnswer)
                    Center(
                      child: FilledButton.icon(
                        onPressed: () => setState(() => _showAnswer = true),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Show Answer'),
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.accentColor,
                        ),
                      ),
                    )
                  else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Text('Answer',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(_current.answer,
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                        ],
                      ),
                    ),
                    if (_current.explanation != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: widget.accentColor, size: 20),
                                const SizedBox(width: 8),
                                Text('Deep Dive',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(color: widget.accentColor)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(_current.explanation!,
                                style: theme.textTheme.bodySmall?.copyWith(height: 1.6)),
                          ],
                        ),
                      ),
                    ],
                    if (_current.followUp != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.forum, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Follow-up: ${_current.followUp}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    OutlinedButton(
                      onPressed: _prev,
                      child: const Text('Previous'),
                    ),
                  const Spacer(),
                  if (_currentIndex < widget.questions.length - 1)
                    FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(backgroundColor: widget.accentColor),
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _difficultyBadge(ThemeData theme) {
    final colors = {
      'Beginner': Colors.green,
      'Intermediate': Colors.blue,
      'Advanced': Colors.orange,
      'Expert': Colors.red,
    };
    final color = colors[_current.difficulty.label] ?? Colors.grey;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _current.difficulty.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(_current.topic, style: theme.textTheme.bodySmall),
      ],
    );
  }

  void _next() {
    setState(() {
      _currentIndex++;
      _showAnswer = false;
    });
  }

  void _prev() {
    setState(() {
      _currentIndex--;
      _showAnswer = false;
    });
  }
}
