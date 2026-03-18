import 'package:equatable/equatable.dart';

enum ContentTone { professional, enthusiastic, casual }

class CoverLetter extends Equatable {
  final String id;
  final String userId;
  final String jobId;
  final String content;
  final ContentTone tone;
  final int? atsScore;
  final int version;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CoverLetter({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.content,
    this.tone = ContentTone.professional,
    this.atsScore,
    this.version = 1,
    required this.createdAt,
    this.updatedAt,
  });

  factory CoverLetter.fromJson(Map<String, dynamic> json) {
    return CoverLetter(
      id: json['id'] as String,
      userId: json['userId'] as String,
      jobId: json['jobId'] as String,
      content: json['content'] as String? ?? '',
      tone: ContentTone.values.firstWhere(
        (t) => t.name == json['tone'],
        orElse: () => ContentTone.professional,
      ),
      atsScore: json['atsScore'] as int?,
      version: json['version'] as int? ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'jobId': jobId,
        'content': content,
        'tone': tone.name,
        'atsScore': atsScore,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  CoverLetter copyWith({
    String? id,
    String? userId,
    String? jobId,
    String? content,
    ContentTone? tone,
    int? atsScore,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CoverLetter(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobId: jobId ?? this.jobId,
      content: content ?? this.content,
      tone: tone ?? this.tone,
      atsScore: atsScore ?? this.atsScore,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, jobId, version];
}

class IntroMessage extends Equatable {
  final String id;
  final String userId;
  final String jobId;
  final String content;
  final ContentTone tone;
  final String platform;
  final DateTime createdAt;

  const IntroMessage({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.content,
    this.tone = ContentTone.professional,
    this.platform = 'LinkedIn',
    required this.createdAt,
  });

  factory IntroMessage.fromJson(Map<String, dynamic> json) {
    return IntroMessage(
      id: json['id'] as String,
      userId: json['userId'] as String,
      jobId: json['jobId'] as String,
      content: json['content'] as String? ?? '',
      tone: ContentTone.values.firstWhere(
        (t) => t.name == json['tone'],
        orElse: () => ContentTone.professional,
      ),
      platform: json['platform'] as String? ?? 'LinkedIn',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'jobId': jobId,
        'content': content,
        'tone': tone.name,
        'platform': platform,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, userId, jobId, platform];
}
