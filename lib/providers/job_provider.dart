import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/providers/profile_provider.dart';
import 'package:job_board/services/job_service.dart';

final jobServiceProvider = Provider<JobService>((ref) => JobService());

final jobsStreamProvider = StreamProvider<List<Job>>((ref) {
  return ref.watch(jobServiceProvider).jobsStream();
});

final jobsWithScoresProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobsStreamProvider).value ?? [];
  final profile = ref.watch(profileProvider);
  if (profile == null) return jobs;

  return jobs.map((job) {
    final score = JobService.calculateMatchScore(job, profile);
    return job.copyWith(matchScore: score);
  }).toList()
    ..sort((a, b) => b.matchScore.compareTo(a.matchScore));
});

final jobFilterProvider = StateProvider<JobFilter>((ref) => const JobFilter());

final filteredJobsProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobsWithScoresProvider);
  final filter = ref.watch(jobFilterProvider);
  return filter.apply(jobs);
});

class JobFilter {
  final String? query;
  final String? jobType;
  final String? remote;
  final int? minMatch;
  final String sortBy;

  const JobFilter({
    this.query,
    this.jobType,
    this.remote,
    this.minMatch,
    this.sortBy = 'match',
  });

  List<Job> apply(List<Job> jobs) {
    var filtered = jobs.toList();

    if (query != null && query!.isNotEmpty) {
      final q = query!.toLowerCase();
      filtered = filtered.where((job) {
        return job.title.toLowerCase().contains(q) ||
            job.company.toLowerCase().contains(q) ||
            job.location.toLowerCase().contains(q) ||
            job.tags.any((t) => t.contains(q));
      }).toList();
    }

    if (jobType != null && jobType!.isNotEmpty) {
      filtered = filtered.where((job) => job.jobType == jobType).toList();
    }

    if (remote != null && remote!.isNotEmpty) {
      filtered = filtered.where((job) => job.remote == remote).toList();
    }

    if (minMatch != null) {
      filtered =
          filtered.where((job) => job.matchScore >= minMatch!).toList();
    }

    switch (sortBy) {
      case 'match':
        filtered.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      case 'date':
        filtered.sort((a, b) =>
            (b.postedAt ?? DateTime(2000)).compareTo(a.postedAt ?? DateTime(2000)));
      case 'salary':
        filtered.sort(
            (a, b) => (b.salaryMax ?? 0).compareTo(a.salaryMax ?? 0));
      case 'company':
        filtered.sort((a, b) => a.company.compareTo(b.company));
    }

    return filtered;
  }

  JobFilter copyWith({
    String? query,
    String? jobType,
    String? remote,
    int? minMatch,
    String? sortBy,
  }) {
    return JobFilter(
      query: query ?? this.query,
      jobType: jobType ?? this.jobType,
      remote: remote ?? this.remote,
      minMatch: minMatch ?? this.minMatch,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
