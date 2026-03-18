import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/models/application.dart';
import 'package:job_board/providers/auth_provider.dart';
import 'package:job_board/services/application_service.dart';

final applicationServiceProvider =
    Provider<ApplicationService>((ref) => ApplicationService());

final applicationsStreamProvider = StreamProvider<List<Application>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(applicationServiceProvider).applicationsStream(user.uid);
});

final applicationStatsProvider =
    Provider<Map<ApplicationStatus, int>>((ref) {
  final applications = ref.watch(applicationsStreamProvider).value ?? [];
  final counts = <ApplicationStatus, int>{};
  for (final status in ApplicationStatus.values) {
    counts[status] = applications.where((a) => a.status == status).length;
  }
  return counts;
});

final totalApplicationsProvider = Provider<int>((ref) {
  final apps = ref.watch(applicationsStreamProvider).value ?? [];
  return apps
      .where((a) => a.status != ApplicationStatus.saved)
      .length;
});
