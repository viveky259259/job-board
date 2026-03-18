import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/services/job_service.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';

class InterviewPrepScreen extends ConsumerStatefulWidget {
  final String jobId;
  const InterviewPrepScreen({super.key, required this.jobId});

  @override
  ConsumerState<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends ConsumerState<InterviewPrepScreen> {
  Job? _job;
  bool _isLoading = true;
  List<Map<String, String>>? _questions;
  final Map<int, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    final job = await JobService().getJob(widget.jobId);
    if (mounted) setState(() { _job = job; _isLoading = false; });
  }

  void _generateQuestions() {
    final profile = ref.read(profileProvider);
    if (_job == null) return;

    final job = _job!;
    final skills = profile?.skills ?? [];
    final jobReqs = job.requirements;

    final questions = <Map<String, String>>[
      {
        'category': 'Behavioral',
        'question': 'Tell me about yourself and why you\'re interested in the ${job.title} role at ${job.company}.',
        'tip': 'Structure with: current role → key achievements → why this role. Keep it under 2 minutes.',
      },
      {
        'category': 'Behavioral',
        'question': 'Describe a challenging project you worked on. What was your role and how did you handle obstacles?',
        'tip': 'Use the STAR method: Situation, Task, Action, Result. Quantify your impact.',
      },
      {
        'category': 'Behavioral',
        'question': 'Tell me about a time you disagreed with a team member. How did you resolve it?',
        'tip': 'Show emotional intelligence. Focus on the process of resolution, not who was right.',
      },
    ];

    if (jobReqs.isNotEmpty) {
      for (int i = 0; i < jobReqs.length && i < 3; i++) {
        final req = jobReqs[i];
        final hasSkill = skills.any((s) => s.toLowerCase() == req.toLowerCase());
        questions.add({
          'category': 'Technical',
          'question': 'Can you describe your experience with $req? Give a specific example of a project where you used it.',
          'tip': hasSkill
              ? 'You have $req on your profile — prepare 2-3 concrete examples with measurable outcomes.'
              : 'This is listed in your requirements but not in your skills. Research it and be honest about your experience level.',
        });
      }
    }

    questions.addAll([
      {
        'category': 'Technical',
        'question': 'How do you approach debugging a complex issue in production?',
        'tip': 'Walk through your methodology: reproduce → isolate → hypothesize → fix → verify → post-mortem.',
      },
      {
        'category': 'Role-Specific',
        'question': 'What interests you most about ${job.company}? What do you know about our products/mission?',
        'tip': 'Research the company before the interview. Mention specific products, recent news, or values that resonate.',
      },
      {
        'category': 'Role-Specific',
        'question': 'Where do you see yourself in 3-5 years?',
        'tip': 'Align your growth goals with the role\'s trajectory. Show ambition without implying you\'ll leave quickly.',
      },
      {
        'category': 'Situational',
        'question': 'If you joined our team and found the codebase had significant technical debt, how would you handle it?',
        'tip': 'Show pragmatism: prioritize based on impact, communicate trade-offs, propose incremental improvements.',
      },
      {
        'category': 'Closing',
        'question': 'What questions do you have for us?',
        'tip': 'Always ask 2-3 questions. Great ones: "What does success look like in 90 days?", "What\'s the biggest challenge the team is facing?"',
      },
    ]);

    setState(() => _questions = questions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = ref.watch(currentTierProvider);

    if (!tier.hasFeature(ProFeature.interviewPrep)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interview Prep')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Pro Feature', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Get AI-generated interview questions tailored to each job.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaywallScreen(triggerFeature: ProFeature.interviewPrep),
                    ),
                  ),
                  icon: const Icon(Icons.star),
                  label: const Text('Upgrade to Pro'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interview Prep')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_job?.title ?? 'Interview Prep')),
      body: _questions == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('Prepare for Your Interview', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Get personalized interview questions based on this job and your profile.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _generateQuestions,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Questions'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions!.length,
              itemBuilder: (context, index) {
                final q = _questions![index];
                final isExpanded = _expanded[index] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _expanded[index] = !isExpanded),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _categoryColor(q['category']!).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  q['category']!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _categoryColor(q['category']!),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: q['question']!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied!')),
                                  );
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(q['question']!, style: theme.textTheme.bodyMedium),
                          if (isExpanded) ...[
                            const Divider(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    q['tip']!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Behavioral':
        return Colors.blue;
      case 'Technical':
        return Colors.orange;
      case 'Role-Specific':
        return Colors.purple;
      case 'Situational':
        return Colors.teal;
      case 'Closing':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
