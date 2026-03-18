import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  saved,
  applied,
  interviewing,
  offered,
  rejected,
  ghosted;

  String get label {
    switch (this) {
      case ApplicationStatus.saved:
        return 'Saved';
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.interviewing:
        return 'Interviewing';
      case ApplicationStatus.offered:
        return 'Offered';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.ghosted:
        return 'Ghosted';
    }
  }

  String get emoji {
    switch (this) {
      case ApplicationStatus.saved:
        return '📌';
      case ApplicationStatus.applied:
        return '📨';
      case ApplicationStatus.interviewing:
        return '🎤';
      case ApplicationStatus.offered:
        return '🎉';
      case ApplicationStatus.rejected:
        return '❌';
      case ApplicationStatus.ghosted:
        return '👻';
    }
  }

  bool get isTerminal =>
      this == ApplicationStatus.offered ||
      this == ApplicationStatus.rejected ||
      this == ApplicationStatus.ghosted;
}

class StatusUpdate extends Equatable {
  final ApplicationStatus status;
  final DateTime at;
  final String? note;

  const StatusUpdate({
    required this.status,
    required this.at,
    this.note,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ApplicationStatus.saved,
      ),
      at: DateTime.parse(json['at'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'at': at.toIso8601String(),
        'note': note,
      };

  @override
  List<Object?> get props => [status, at, note];
}

class Application extends Equatable {
  final String id;
  final String userId;
  final String jobId;
  final String jobTitle;
  final String company;
  final ApplicationStatus status;
  final String? coverLetterId;
  final String? introMessageId;
  final DateTime? appliedAt;
  final List<StatusUpdate> statusUpdates;
  final String? notes;
  final int matchScore;
  final DateTime createdAt;

  const Application({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    this.status = ApplicationStatus.saved,
    this.coverLetterId,
    this.introMessageId,
    this.appliedAt,
    this.statusUpdates = const [],
    this.notes,
    this.matchScore = 0,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      userId: json['userId'] as String,
      jobId: json['jobId'] as String,
      jobTitle: json['jobTitle'] as String? ?? '',
      company: json['company'] as String? ?? '',
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ApplicationStatus.saved,
      ),
      coverLetterId: json['coverLetterId'] as String?,
      introMessageId: json['introMessageId'] as String?,
      appliedAt: json['appliedAt'] != null
          ? DateTime.tryParse(json['appliedAt'] as String)
          : null,
      statusUpdates: (json['statusUpdates'] as List<dynamic>?)
              ?.map((e) => StatusUpdate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      matchScore: json['matchScore'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'company': company,
        'status': status.name,
        'coverLetterId': coverLetterId,
        'introMessageId': introMessageId,
        'appliedAt': appliedAt?.toIso8601String(),
        'statusUpdates': statusUpdates.map((e) => e.toJson()).toList(),
        'notes': notes,
        'matchScore': matchScore,
        'createdAt': createdAt.toIso8601String(),
      };

  int get daysSinceLastUpdate {
    if (statusUpdates.isEmpty) return DateTime.now().difference(createdAt).inDays;
    return DateTime.now().difference(statusUpdates.last.at).inDays;
  }

  bool get isPossiblyGhosted =>
      status == ApplicationStatus.applied && daysSinceLastUpdate > 30;

  Application copyWith({
    String? id,
    String? userId,
    String? jobId,
    String? jobTitle,
    String? company,
    ApplicationStatus? status,
    String? coverLetterId,
    String? introMessageId,
    DateTime? appliedAt,
    List<StatusUpdate>? statusUpdates,
    String? notes,
    int? matchScore,
    DateTime? createdAt,
  }) {
    return Application(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      status: status ?? this.status,
      coverLetterId: coverLetterId ?? this.coverLetterId,
      introMessageId: introMessageId ?? this.introMessageId,
      appliedAt: appliedAt ?? this.appliedAt,
      statusUpdates: statusUpdates ?? this.statusUpdates,
      notes: notes ?? this.notes,
      matchScore: matchScore ?? this.matchScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, jobId, status];
}
