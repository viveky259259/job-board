import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/services/gamification_service.dart';

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService(
      profileService: ref.watch(profileServiceProvider));
});

final gamificationDataProvider = Provider<GamificationData>((ref) {
  final profile = ref.watch(profileProvider);
  return profile?.gamification ?? const GamificationData();
});
