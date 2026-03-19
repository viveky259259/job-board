import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:job_board/core/theme/app_theme.dart';
import 'package:job_board/models/cover_letter.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/subscription.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/providers/subscription_provider.dart';
import 'package:job_board/providers/job_provider.dart';
import 'package:job_board/services/ai_service.dart';
import 'package:job_board/features/paywall/paywall_screen.dart';

class CoverLetterScreen extends ConsumerStatefulWidget {
  final String jobId;
  const CoverLetterScreen({super.key, required this.jobId});

  @override
  ConsumerState<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends ConsumerState<CoverLetterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Job? _job;
  bool _isLoading = true;
  bool _isGenerating = false;
  ContentTone _selectedTone = ContentTone.professional;
  CoverLetter? _coverLetter;
  IntroMessage? _introMessage;
  final _editController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadJob();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _loadJob() async {
    try {
      final job = await ref.read(jobServiceProvider).getJob(widget.jobId);
      if (mounted) setState(() { _job = job; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateCoverLetter() async {
    final profile = ref.read(profileProvider);
    if (profile == null || _job == null) return;

    final canUse = ref.read(canUseCoverLetterProvider);
    if (!canUse) {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PaywallScreen(
            triggerFeature: ProFeature.unlimitedCoverLetters,
            customTitle: 'You\'ve used all free cover letters this month',
          ),
        ));
      }
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final cl = await AiService().generateCoverLetter(
        job: _job!,
        profile: profile,
        tone: _selectedTone,
      );
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(subscriptionServiceProvider).incrementUsage(user.uid, 'coverLetter');
      }
      setState(() {
        _coverLetter = cl;
        _editController.text = cl.content;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate cover letter')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateIntroMessage() async {
    final profile = ref.read(profileProvider);
    if (profile == null || _job == null) return;

    final canUse = ref.read(canUseIntroMessageProvider);
    if (!canUse) {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const PaywallScreen(
            triggerFeature: ProFeature.unlimitedIntroMessages,
            customTitle: 'You\'ve used all free intro messages this month',
          ),
        ));
      }
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final msg = await AiService().generateIntroMessage(
        job: _job!,
        profile: profile,
        tone: _selectedTone,
      );
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(subscriptionServiceProvider).incrementUsage(user.uid, 'introMessage');
      }
      setState(() => _introMessage = msg);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate intro message')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Writer')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_job?.title ?? 'AI Writer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cover Letter'),
            Tab(text: 'Intro Message'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Tone:', style: theme.textTheme.labelLarge),
                  const SizedBox(width: 12),
                  ...ContentTone.values.map((tone) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tone.name[0].toUpperCase() + tone.name.substring(1)),
                          selected: _selectedTone == tone,
                          onSelected: (_) =>
                              setState(() => _selectedTone = tone),
                        ),
                      )),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCoverLetterTab(theme),
                _buildIntroMessageTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverLetterTab(ThemeData theme) {
    if (_coverLetter == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_document,
                  size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'Generate a tailored cover letter',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'AI will craft a cover letter based on your profile and this job description.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isGenerating ? null : _generateCoverLetter,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Generate'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_coverLetter!.atsScore != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.matchScoreColor(_coverLetter!.atsScore!)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics,
                    color: AppTheme.matchScoreColor(_coverLetter!.atsScore!)),
                const SizedBox(width: 8),
                Text(
                  'ATS Score: ${_coverLetter!.atsScore}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.matchScoreColor(_coverLetter!.atsScore!),
                  ),
                ),
                const Spacer(),
                Text(
                  _coverLetter!.atsScore! >= 80
                      ? 'ATS-friendly!'
                      : 'Consider adding more keywords',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        Expanded(
          child: _isEditing
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _editController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _coverLetter!.content,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (_isEditing) {
                      setState(() {
                        _coverLetter = _coverLetter!
                            .copyWith(content: _editController.text);
                        _isEditing = false;
                      });
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  tooltip: _isEditing ? 'Save' : 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _coverLetter!.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard!')),
                    );
                  },
                  tooltip: 'Copy',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () =>
                      SharePlus.instance.share(ShareParams(text: _coverLetter!.content)),
                  tooltip: 'Share',
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _isGenerating ? null : _generateCoverLetter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroMessageTab(ThemeData theme) {
    if (_introMessage == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.message,
                  size: 64, color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'Generate an intro message',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Perfect for LinkedIn outreach or cold emails to hiring managers.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isGenerating ? null : _generateIntroMessage,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Generate'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.send, color: theme.colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          '${_introMessage!.platform} Message',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    SelectableText(
                      _introMessage!.content,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _introMessage!.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard!')),
                    );
                  },
                  tooltip: 'Copy',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () =>
                      SharePlus.instance.share(ShareParams(text: _introMessage!.content)),
                  tooltip: 'Share',
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _isGenerating ? null : _generateIntroMessage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
