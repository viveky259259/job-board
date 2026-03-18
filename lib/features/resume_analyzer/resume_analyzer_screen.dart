import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/core/theme/app_theme.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';

class ResumeAnalyzerScreen extends ConsumerStatefulWidget {
  const ResumeAnalyzerScreen({super.key});

  @override
  ConsumerState<ResumeAnalyzerScreen> createState() => _ResumeAnalyzerScreenState();
}

class _ResumeAnalyzerScreenState extends ConsumerState<ResumeAnalyzerScreen> {
  bool _hasAnalyzed = false;
  Map<String, dynamic>? _analysis;

  void _analyze() {
    final profile = ref.read(profileProvider);
    if (profile == null) return;

    int overallScore = 0;
    final sections = <Map<String, dynamic>>[];

    // Contact info
    final hasName = profile.name?.isNotEmpty == true;
    final hasEmail = profile.email.isNotEmpty;
    final contactScore = (hasName ? 50 : 0) + (hasEmail ? 50 : 0);
    sections.add({
      'name': 'Contact Information',
      'score': contactScore,
      'tips': [
        if (!hasName) 'Add your full name',
        'Add a phone number and LinkedIn URL',
      ],
    });

    // Professional summary
    final summaryLength = profile.summary?.length ?? 0;
    int summaryScore = 0;
    if (summaryLength > 200) {
      summaryScore = 100;
    } else if (summaryLength > 100) {
      summaryScore = 70;
    } else if (summaryLength > 30) {
      summaryScore = 40;
    }
    sections.add({
      'name': 'Professional Summary',
      'score': summaryScore,
      'tips': [
        if (summaryLength < 100) 'Expand your summary to 2-3 sentences',
        'Include your years of experience and key specialization',
        'Mention your career goal or target role',
      ],
    });

    // Skills
    final skillsCount = profile.skills.length;
    int skillsScore = (skillsCount * 12).clamp(0, 100);
    sections.add({
      'name': 'Skills',
      'score': skillsScore,
      'tips': [
        if (skillsCount < 5) 'Add at least 8-10 relevant skills',
        'Include both technical and soft skills',
        'Match keywords from your target job descriptions',
        if (skillsCount >= 8) 'Great skill coverage!',
      ],
    });

    // Experience
    final expCount = profile.experience.length;
    final hasDescriptions = profile.experience.any((e) => e.description?.isNotEmpty == true);
    int expScore = 0;
    if (expCount >= 3 && hasDescriptions) {
      expScore = 100;
    } else if (expCount >= 2) {
      expScore = 70;
    } else if (expCount >= 1) {
      expScore = 40;
    }
    sections.add({
      'name': 'Work Experience',
      'score': expScore,
      'tips': [
        if (expCount == 0) 'Add your work experience',
        if (expCount > 0 && !hasDescriptions) 'Add descriptions with quantified achievements',
        'Use action verbs: Led, Built, Increased, Reduced',
        'Include metrics: "Increased revenue by 30%"',
      ],
    });

    // Education
    int eduScore = profile.education.isNotEmpty ? 100 : 0;
    sections.add({
      'name': 'Education',
      'score': eduScore,
      'tips': [
        if (profile.education.isEmpty) 'Add your education background',
        'Include relevant coursework or certifications',
      ],
    });

    // ATS optimization
    final hasKeywords = profile.skills.length >= 5;
    final hasStructure = profile.experience.isNotEmpty && profile.education.isNotEmpty;
    int atsScore = 0;
    if (hasKeywords) atsScore += 40;
    if (hasStructure) atsScore += 30;
    if (summaryLength > 50) atsScore += 30;
    sections.add({
      'name': 'ATS Optimization',
      'score': atsScore,
      'tips': [
        'Use standard section headings',
        'Include keywords from job descriptions',
        'Avoid tables, graphics, or unusual formatting',
        if (!hasKeywords) 'Add more skills for keyword matching',
      ],
    });

    overallScore = sections.fold<int>(0, (sum, s) => sum + (s['score'] as int)) ~/ sections.length;

    setState(() {
      _hasAnalyzed = true;
      _analysis = {
        'overallScore': overallScore,
        'sections': sections,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = ref.watch(currentTierProvider);

    if (!tier.hasFeature(ProFeature.resumeAnalyzer)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resume Analyzer')),
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
                  'Get AI-powered resume analysis with keyword optimization tips.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaywallScreen(triggerFeature: ProFeature.resumeAnalyzer),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Resume Analyzer')),
      body: !_hasAnalyzed
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('Analyze Your Resume', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Get a detailed score and actionable tips to improve your resume.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _analyze,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Analyze Now'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _overallScoreCard(theme),
                  const SizedBox(height: 20),
                  ...(_analysis!['sections'] as List).map((section) =>
                      _sectionCard(theme, section as Map<String, dynamic>)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _analyze,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Re-analyze'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _overallScoreCard(ThemeData theme) {
    final score = _analysis!['overallScore'] as int;
    final color = AppTheme.matchScoreColor(score);
    String verdict;
    if (score >= 80) {
      verdict = 'Excellent! Your resume is well-optimized.';
    } else if (score >= 60) {
      verdict = 'Good foundation. A few improvements will make it shine.';
    } else if (score >= 40) {
      verdict = 'Needs work. Follow the tips below to improve.';
    } else {
      verdict = 'Significant gaps. Let\'s build this up step by step.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('Resume Score',
              style: theme.textTheme.titleMedium?.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: theme.textTheme.displayMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('/100', style: theme.textTheme.titleSmall?.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(verdict,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _sectionCard(ThemeData theme, Map<String, dynamic> section) {
    final score = section['score'] as int;
    final tips = section['tips'] as List;
    final color = AppTheme.matchScoreColor(score);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(section['name'] as String,
                      style: theme.textTheme.titleSmall),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score/100',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
            if (tips.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          score >= 80 ? Icons.check_circle : Icons.lightbulb_outline,
                          size: 16,
                          color: score >= 80 ? AppTheme.successColor : Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(tip as String, style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
