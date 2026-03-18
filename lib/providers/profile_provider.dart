import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/services/profile_service.dart';

final profileServiceProvider =
    Provider<ProfileService>((ref) => ProfileService());

final profileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(profileServiceProvider).profileStream(user.uid);
});

final profileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(profileStreamProvider).value;
});
