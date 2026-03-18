import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_board/core/constants/app_constants.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _summaryController;
  final _skillController = TextEditingController();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();

  late List<String> _skills;
  late List<String> _targetRoles;
  late List<String> _locations;
  late List<String> _remotePrefs;
  late List<String> _jobTypes;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initFromProfile(UserProfile profile) {
    if (_initialized) return;
    _nameController = TextEditingController(text: profile.name ?? '');
    _headlineController = TextEditingController(text: profile.headline ?? '');
    _summaryController = TextEditingController(text: profile.summary ?? '');
    _skills = List.from(profile.skills);
    _targetRoles = List.from(profile.preferences.targetRoles);
    _locations = List.from(profile.preferences.locations);
    _remotePrefs = List.from(profile.preferences.remotePreference);
    _jobTypes = List.from(profile.preferences.jobTypes);
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(profileServiceProvider).updateProfile(user.uid, {
        'name': _nameController.text.trim(),
        'headline': _headlineController.text.trim(),
        'summary': _summaryController.text.trim(),
        'skills': _skills,
        'preferences': JobPreferences(
          targetRoles: _targetRoles,
          locations: _locations,
          remotePreference: _remotePrefs,
          jobTypes: _jobTypes,
        ).toJson(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _initFromProfile(profile);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Basic Info', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _headlineController,
              decoration: const InputDecoration(
                labelText: 'Headline',
                hintText: 'e.g. Senior Flutter Developer',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _summaryController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Summary',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Text('Skills', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(hintText: 'Add a skill'),
                    onSubmitted: (_) => _addItem(
                        _skillController, _skills),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () =>
                      _addItem(_skillController, _skills),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills
                  .map((s) => Chip(
                        label: Text(s),
                        onDeleted: () => setState(() => _skills.remove(s)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text('Job Preferences', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roleController,
                    decoration:
                        const InputDecoration(hintText: 'Add target role'),
                    onSubmitted: (_) =>
                        _addItem(_roleController, _targetRoles),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () =>
                      _addItem(_roleController, _targetRoles),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration:
                        const InputDecoration(hintText: 'Add location'),
                    onSubmitted: (_) =>
                        _addItem(_locationController, _locations),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () =>
                      _addItem(_locationController, _locations),
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
            const SizedBox(height: 16),
            Text('Work Style', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.remoteOptions
                  .map((o) => FilterChip(
                        label: Text(o),
                        selected: _remotePrefs.contains(o),
                        onSelected: (s) => setState(() {
                          s ? _remotePrefs.add(o) : _remotePrefs.remove(o);
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text('Job Types', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.jobTypes
                  .map((t) => FilterChip(
                        label: Text(t),
                        selected: _jobTypes.contains(t),
                        onSelected: (s) => setState(() {
                          s ? _jobTypes.add(t) : _jobTypes.remove(t);
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _addItem(TextEditingController controller, List<String> list) {
    final value = controller.text.trim();
    if (value.isNotEmpty && !list.contains(value)) {
      setState(() => list.add(value));
      controller.clear();
    }
  }
}
