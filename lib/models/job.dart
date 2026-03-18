import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final int? salaryMin;
  final int? salaryMax;
  final String? currency;
  final String jobType;
  final String remote;
  final String source;
  final String? sourceUrl;
  final String? companyLogo;
  final String? companyUrl;
  final List<String> requirements;
  final List<String> tags;
  final DateTime? postedAt;
  final DateTime? expiresAt;
  final int matchScore;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    this.salaryMin,
    this.salaryMax,
    this.currency = 'USD',
    this.jobType = 'Full-time',
    this.remote = 'On-site',
    this.source = 'manual',
    this.sourceUrl,
    this.companyLogo,
    this.companyUrl,
    this.requirements = const [],
    this.tags = const [],
    this.postedAt,
    this.expiresAt,
    this.matchScore = 0,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      salaryMin: json['salaryMin'] as int?,
      salaryMax: json['salaryMax'] as int?,
      currency: json['currency'] as String? ?? 'USD',
      jobType: json['jobType'] as String? ?? 'Full-time',
      remote: json['remote'] as String? ?? 'On-site',
      source: json['source'] as String? ?? 'manual',
      sourceUrl: json['sourceUrl'] as String?,
      companyLogo: json['companyLogo'] as String?,
      companyUrl: json['companyUrl'] as String?,
      requirements: List<String>.from(json['requirements'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      postedAt: json['postedAt'] != null
          ? DateTime.tryParse(json['postedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      matchScore: json['matchScore'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'location': location,
        'description': description,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'currency': currency,
        'jobType': jobType,
        'remote': remote,
        'source': source,
        'sourceUrl': sourceUrl,
        'companyLogo': companyLogo,
        'companyUrl': companyUrl,
        'requirements': requirements,
        'tags': tags,
        'postedAt': postedAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'matchScore': matchScore,
      };

  String get salaryRange {
    if (salaryMin == null && salaryMax == null) return 'Not specified';
    final cur = currency ?? 'USD';
    if (salaryMin != null && salaryMax != null) {
      return '\$$salaryMin - \$$salaryMax $cur';
    }
    if (salaryMin != null) return 'From \$$salaryMin $cur';
    return 'Up to \$$salaryMax $cur';
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? description,
    int? salaryMin,
    int? salaryMax,
    String? currency,
    String? jobType,
    String? remote,
    String? source,
    String? sourceUrl,
    String? companyLogo,
    String? companyUrl,
    List<String>? requirements,
    List<String>? tags,
    DateTime? postedAt,
    DateTime? expiresAt,
    int? matchScore,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      description: description ?? this.description,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      currency: currency ?? this.currency,
      jobType: jobType ?? this.jobType,
      remote: remote ?? this.remote,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      companyLogo: companyLogo ?? this.companyLogo,
      companyUrl: companyUrl ?? this.companyUrl,
      requirements: requirements ?? this.requirements,
      tags: tags ?? this.tags,
      postedAt: postedAt ?? this.postedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      matchScore: matchScore ?? this.matchScore,
    );
  }

  @override
  List<Object?> get props => [id, title, company, location, source];
}
