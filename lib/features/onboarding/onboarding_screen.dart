import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_board/core/constants/app_constants.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _nameController = TextEditingController();
  final _headlineController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillController = TextEditingController();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();

  final List<String> _skills = [];
  final List<String> _targetRoles = [];
  final List<String> _locations = [];
  final List<String> _selectedRemote = [];
  final List<String> _selectedJobTypes = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _headlineController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final profileService = ref.read(profileServiceProvider);
      await profileService.updateProfile(user.uid, {
        'name': _nameController.text.trim(),
        'headline': _headlineController.text.trim(),
        'summary': _summaryController.text.trim(),
        'skills': _skills,
        'preferences': JobPreferences(
          targetRoles: _targetRoles,
          locations: _locations,
          remotePreference: _selectedRemote,
          jobTypes: _selectedJobTypes,
        ).toJson(),
      });

      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 3,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoPage(theme),
                  _buildSkillsPage(theme),
                  _buildPreferencesPage(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _isLoading ? null : _nextPage,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_currentPage < 2 ? 'Continue' : 'Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Tell us about yourself', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'This helps us match you with the best jobs.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _headlineController,
              decoration: const InputDecoration(
                labelText: 'Professional Headline',
                hintText: 'e.g. Senior Flutter Developer',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Professional Summary',
                hintText: 'Brief overview of your experience and goals...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Your Skills', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Add your key skills for better job matching.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      labelText: 'Add a skill',
                      hintText: 'e.g. Flutter, Python, AWS',
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills
                  .map((skill) => Chip(
                        label: Text(skill),
                        onDeleted: () =>
                            setState(() => _skills.remove(skill)),
                      ))
                  .toList(),
            ),
            if (_skills.isEmpty) ...[
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Add at least 3 skills for best results',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
      _skillController.clear();
    }
  }

  Widget _buildPreferencesPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Job Preferences', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'What kind of jobs are you looking for?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _roleController,
                    decoration: const InputDecoration(
                      labelText: 'Target Roles',
                      hintText: 'e.g. Software Engineer',
                    ),
                    onFieldSubmitted: (_) => _addRole(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addRole,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _targetRoles
                  .map((r) => Chip(
                        label: Text(r),
                        onDeleted: () =>
                            setState(() => _targetRoles.remove(r)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Locations',
                      hintText: 'e.g. San Francisco',
                    ),
                    onFieldSubmitted: (_) => _addLocation(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addLocation,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _locations
                  .map((l) => Chip(
                        label: Text(l),
                        onDeleted: () =>
                            setState(() => _locations.remove(l)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text('Work Style', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.remoteOptions
                  .map((opt) => FilterChip(
                        label: Text(opt),
                        selected: _selectedRemote.contains(opt),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedRemote.add(opt);
                            } else {
                              _selectedRemote.remove(opt);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text('Job Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.jobTypes
                  .map((type) => FilterChip(
                        label: Text(type),
                        selected: _selectedJobTypes.contains(type),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedJobTypes.add(type);
                            } else {
                              _selectedJobTypes.remove(type);
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _addRole() {
    final role = _roleController.text.trim();
    if (role.isNotEmpty && !_targetRoles.contains(role)) {
      setState(() => _targetRoles.add(role));
      _roleController.clear();
    }
  }

  void _addLocation() {
    final loc = _locationController.text.trim();
    if (loc.isNotEmpty && !_locations.contains(loc)) {
      setState(() => _locations.add(loc));
      _locationController.clear();
    }
  }
}
