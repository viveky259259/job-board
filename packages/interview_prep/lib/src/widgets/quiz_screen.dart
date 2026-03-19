import 'package:flutter/material.dart';
import 'package:interview_prep/src/models/prep_session.dart';
import 'package:interview_prep/src/models/question.dart';
import 'package:interview_prep/src/services/prep_engine.dart';

class QuizScreen extends StatefulWidget {
  final List<InterviewQuestion> questions;
  final PrepSession session;
  final PrepEngine engine;
  final Color accentColor;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.session,
    required this.engine,
    this.accentColor = Colors.blue,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _confidence = 3;
  late PrepSession _session;
  late DateTime _questionStart;

  InterviewQuestion get _current => widget.questions[_currentIndex];
  bool get _isLast => _currentIndex >= widget.questions.length - 1;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _questionStart = DateTime.now();
  }

  void _submitAnswer() {
    final timeTaken = DateTime.now().difference(_questionStart);
    final isCorrect = _current.isMultipleChoice
        ? _selectedOption == _current.correctOptionIndex
        : true;

    final result = QuestionResult(
      questionId: _current.id,
      isCorrect: isCorrect,
      confidenceLevel: _confidence,
      timeTaken: timeTaken,
      answeredAt: DateTime.now(),
      userAnswer: _selectedOption?.toString(),
    );

    widget.engine.recordAnswer(_current.id, result);
    _session = _session.addResult(result);

    setState(() => _answered = true);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _answered = false;
      _confidence = 3;
      _questionStart = DateTime.now();
    });
  }

  void _finish() {
    final completed = widget.engine.completeSession(_session);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => _ResultsScreen(
        session: completed,
        questions: widget.questions,
        accentColor: widget.accentColor,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz — ${_current.difficulty.label}'),
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
                  Text(
                    _current.question,
                    style: theme.textTheme.titleMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  if (_current.isMultipleChoice && _current.options != null)
                    ..._current.options!.asMap().entries.map(
                          (entry) => _optionTile(theme, entry.key, entry.value),
                        )
                  else if (!_answered)
                    _selfAssessment(theme),
                  if (_answered) ...[
                    const SizedBox(height: 16),
                    _answerReveal(theme),
                    const SizedBox(height: 12),
                    if (!_current.isMultipleChoice) _confidenceSlider(theme),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: _answered
                    ? FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: Text(_isLast ? 'See Results' : 'Next Question'),
                      )
                    : _current.isMultipleChoice
                        ? FilledButton(
                            onPressed: _selectedOption != null ? _submitAnswer : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: widget.accentColor,
                              minimumSize: const Size(double.infinity, 52),
                            ),
                            child: const Text('Submit'),
                          )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile(ThemeData theme, int index, String option) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == _current.correctOptionIndex;
    Color? borderColor;
    Color? bgColor;

    if (_answered) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.08);
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.08);
      }
    } else if (isSelected) {
      borderColor = widget.accentColor;
      bgColor = widget.accentColor.withValues(alpha: 0.06);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _answered ? null : () => setState(() => _selectedOption = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: borderColor ?? theme.colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? (borderColor ?? widget.accentColor)
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(option)),
              if (_answered && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
              if (_answered && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: Colors.red, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selfAssessment(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text('Think about your answer, then reveal it.',
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _confidence = 1;
                        _submitAnswer();
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text("Didn't know"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _confidence = 3;
                        _submitAnswer();
                      },
                      icon: const Icon(Icons.lightbulb, color: Colors.orange),
                      label: const Text('Partial'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        _confidence = 5;
                        _submitAnswer();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Knew it'),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _answerReveal(ThemeData theme) {
    return Container(
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
          Text('Answer', style: theme.textTheme.titleSmall?.copyWith(color: Colors.green)),
          const SizedBox(height: 8),
          Text(_current.answer, style: theme.textTheme.bodyMedium),
          if (_current.explanation != null) ...[
            const Divider(height: 20),
            Text(_current.explanation!,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _confidenceSlider(ThemeData theme) {
    return const SizedBox.shrink();
  }
}

class _ResultsScreen extends StatelessWidget {
  final PrepSession session;
  final List<InterviewQuestion> questions;
  final Color accentColor;

  const _ResultsScreen({
    required this.session,
    required this.questions,
    this.accentColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = session.scorePercent;
    final color = score >= 80 ? Colors.green : score >= 50 ? Colors.orange : Colors.red;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '$score%',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    score >= 80
                        ? 'Excellent!'
                        : score >= 50
                            ? 'Good progress!'
                            : 'Keep practicing!',
                    style: theme.textTheme.titleMedium?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _statCard(theme, '${session.totalCorrect}', 'Correct', Colors.green),
                const SizedBox(width: 8),
                _statCard(theme, '${session.totalIncorrect}', 'Wrong', Colors.red),
                const SizedBox(width: 8),
                _statCard(theme, '${session.avgTimePerQuestion.inSeconds}s', 'Avg Time', Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            Text('Question Breakdown', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...session.results.asMap().entries.map((entry) {
              final idx = entry.key;
              final result = entry.value;
              final q = questions.firstWhere(
                (q) => q.id == result.questionId,
                orElse: () => questions[idx < questions.length ? idx : 0],
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Icon(
                    result.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: result.isCorrect ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    q.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Text('${result.timeTaken.inSeconds}s',
                      style: theme.textTheme.labelSmall),
                ),
              );
            }),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('Back to Topics'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statCard(ThemeData theme, String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.bold)),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
