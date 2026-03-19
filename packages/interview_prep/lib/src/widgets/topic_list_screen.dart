import 'package:flutter/material.dart';
import 'package:interview_prep/src/models/difficulty.dart';
import 'package:interview_prep/src/models/tech_config.dart';
import 'package:interview_prep/src/services/prep_engine.dart';
import 'package:interview_prep/src/widgets/quiz_screen.dart';
import 'package:interview_prep/src/widgets/study_screen.dart';

class TopicListScreen extends StatelessWidget {
  final TechConfig config;
  final PrepEngine engine;

  const TopicListScreen({
    super.key,
    required this.config,
    required this.engine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = engine.getStats();
    final masteryByTopic = engine.getMasteryByTopic();
    final masteryByDifficulty = engine.getMasteryByDifficulty();

    return Scaffold(
      appBar: AppBar(title: Text('${config.name} Interview Prep')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _overviewCard(theme, stats),
          const SizedBox(height: 16),
          _difficultySelector(context, theme, masteryByDifficulty),
          const SizedBox(height: 20),
          Text('Topics', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...config.topics.map((topic) => _topicTile(
                context,
                theme,
                topic,
                masteryByTopic[topic.id] ?? 0.0,
              )),
          const SizedBox(height: 16),
          _quickActions(context, theme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _overviewCard(ThemeData theme, Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(config.icon, size: 32, color: config.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(config.name, style: theme.textTheme.titleLarge),
                      Text(
                        '${stats['totalQuestions']} questions across ${config.topics.length} topics',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stats['mastered']}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('mastered', style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (stats['overallMastery'] as double).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: config.color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(config.color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStat(theme, '${stats['questionsSeen']}', 'Practiced'),
                _miniStat(theme, '${stats['needsReview']}', 'To Review'),
                _miniStat(theme, '${stats['totalSessions']}', 'Sessions'),
                _miniStat(theme, '${stats['totalXp']}', 'XP'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }

  Widget _difficultySelector(
      BuildContext context, ThemeData theme, Map<Difficulty, double> mastery) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.red];
    return Row(
      children: Difficulty.values.asMap().entries.map((entry) {
        final d = entry.value;
        final m = mastery[d] ?? 0.0;
        final count = config.topics
            .expand((t) => t.questionsForDifficulty(d))
            .length;

        return Expanded(
          child: GestureDetector(
            onTap: () => _startQuiz(context, difficulty: d),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      d.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors[entry.key],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$count Q', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: m,
                        minHeight: 4,
                        backgroundColor: colors[entry.key].withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(colors[entry.key]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _topicTile(
    BuildContext context,
    ThemeData theme,
    dynamic topic,
    double mastery,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: config.color.withValues(alpha: 0.12),
          child: Icon(topic.icon, color: config.color, size: 20),
        ),
        title: Text(topic.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${topic.totalQuestions} questions',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: mastery,
                minHeight: 4,
                backgroundColor: config.color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(config.color),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'study':
                _startStudy(context, topicId: topic.id);
              case 'quiz':
                _startQuiz(context, topicId: topic.id);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'study', child: Text('Study')),
            const PopupMenuItem(value: 'quiz', child: Text('Quiz')),
          ],
        ),
        onTap: () => _startStudy(context, topicId: topic.id),
      ),
    );
  }

  Widget _quickActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Start', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                theme,
                icon: Icons.shuffle,
                label: 'Random Quiz',
                subtitle: '10 mixed questions',
                onTap: () => _startQuiz(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionCard(
                theme,
                icon: Icons.replay,
                label: 'Review',
                subtitle: 'Weak areas',
                onTap: () => _startQuiz(context, mode: QuizMode.weakAreas),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: config.color),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.labelLarge),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  void _startStudy(BuildContext context, {String? topicId}) {
    final questions = engine.getQuestionsForSession(
      topicId: topicId,
      count: 50,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => StudyScreen(questions: questions, accentColor: config.color),
    ));
  }

  void _startQuiz(
    BuildContext context, {
    Difficulty? difficulty,
    String? topicId,
    QuizMode mode = QuizMode.practice,
  }) {
    final questions = engine.getQuestionsForSession(
      difficulty: difficulty,
      topicId: topicId,
      mode: mode,
      count: 10,
    );
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions available for this filter')),
      );
      return;
    }
    final session = engine.startSession(
      difficulty: difficulty,
      topicId: topicId,
      mode: mode,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QuizScreen(
        questions: questions,
        session: session,
        engine: engine,
        accentColor: config.color,
      ),
    ));
  }
}
