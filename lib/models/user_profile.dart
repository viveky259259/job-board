import 'package:equatable/equatable.dart';
import 'package:job_board/core/constants/app_constants.dart';

class WorkExperience extends Equatable {
  final String title;
  final String company;
  final String? startDate;
  final String? endDate;
  final String? description;

  const WorkExperience({
    required this.title,
    required this.company,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'company': company,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };

  @override
  List<Object?> get props => [title, company, startDate, endDate, description];
}

class Education extends Equatable {
  final String school;
  final String degree;
  final String? field;
  final String? year;

  const Education({
    required this.school,
    required this.degree,
    this.field,
    this.year,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      school: json['school'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      field: json['field'] as String?,
      year: json['year'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'school': school,
        'degree': degree,
        'field': field,
        'year': year,
      };

  @override
  List<Object?> get props => [school, degree, field, year];
}

class JobPreferences extends Equatable {
  final List<String> targetRoles;
  final List<String> locations;
  final int? salaryMin;
  final int? salaryMax;
  final String? currency;
  final List<String> remotePreference;
  final List<String> jobTypes;
  final String? experienceLevel;

  const JobPreferences({
    this.targetRoles = const [],
    this.locations = const [],
    this.salaryMin,
    this.salaryMax,
    this.currency = 'USD',
    this.remotePreference = const [],
    this.jobTypes = const [],
    this.experienceLevel,
  });

  factory JobPreferences.fromJson(Map<String, dynamic> json) {
    return JobPreferences(
      targetRoles: List<String>.from(json['targetRoles'] ?? []),
      locations: List<String>.from(json['locations'] ?? []),
      salaryMin: json['salaryMin'] as int?,
      salaryMax: json['salaryMax'] as int?,
      currency: json['currency'] as String? ?? 'USD',
      remotePreference: List<String>.from(json['remotePreference'] ?? []),
      jobTypes: List<String>.from(json['jobTypes'] ?? []),
      experienceLevel: json['experienceLevel'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'targetRoles': targetRoles,
        'locations': locations,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'currency': currency,
        'remotePreference': remotePreference,
        'jobTypes': jobTypes,
        'experienceLevel': experienceLevel,
      };

  bool get isConfigured => targetRoles.isNotEmpty;

  @override
  List<Object?> get props => [
        targetRoles,
        locations,
        salaryMin,
        salaryMax,
        currency,
        remotePreference,
        jobTypes,
        experienceLevel,
      ];
}

class GamificationData extends Equatable {
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final String? lastActiveDate;
  final List<String> unlockedAchievements;

  const GamificationData({
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.unlockedAchievements = const [],
  });

  factory GamificationData.fromJson(Map<String, dynamic> json) {
    return GamificationData(
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
      unlockedAchievements:
          List<String>.from(json['unlockedAchievements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'level': level,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate': lastActiveDate,
        'unlockedAchievements': unlockedAchievements,
      };

  int get xpForNextLevel {
    if (level >= AppConstants.levelThresholds.length) return 0;
    return AppConstants.levelThresholds[level] - xp;
  }

  double get levelProgress {
    if (level >= AppConstants.levelThresholds.length) return 1.0;
    final currentLevelXp =
        level > 1 ? AppConstants.levelThresholds[level - 1] : 0;
    final nextLevelXp = AppConstants.levelThresholds[level];
    final range = nextLevelXp - currentLevelXp;
    if (range <= 0) return 1.0;
    return ((xp - currentLevelXp) / range).clamp(0.0, 1.0);
  }

  String get levelName {
    final idx = (level - 1).clamp(0, AppConstants.levelNames.length - 1);
    return AppConstants.levelNames[idx];
  }

  GamificationData copyWith({
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDate,
    List<String>? unlockedAchievements,
  }) {
    return GamificationData(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [
        xp,
        level,
        currentStreak,
        longestStreak,
        lastActiveDate,
        unlockedAchievements,
      ];
}

class UserProfile extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? headline;
  final String? summary;
  final List<String> skills;
  final List<WorkExperience> experience;
  final List<Education> education;
  final JobPreferences preferences;
  final GamificationData gamification;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.photoUrl,
    this.headline,
    this.summary,
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.preferences = const JobPreferences(),
    this.gamification = const GamificationData(),
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      headline: json['headline'] as String?,
      summary: json['summary'] as String?,
      skills: List<String>.from(json['skills'] ?? []),
      experience: (json['experience'] as List<dynamic>?)
              ?.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      education: (json['education'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      preferences: json['preferences'] != null
          ? JobPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : const JobPreferences(),
      gamification: json['gamification'] != null
          ? GamificationData.fromJson(
              json['gamification'] as Map<String, dynamic>)
          : const GamificationData(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'headline': headline,
        'summary': summary,
        'skills': skills,
        'experience': experience.map((e) => e.toJson()).toList(),
        'education': education.map((e) => e.toJson()).toList(),
        'preferences': preferences.toJson(),
        'gamification': gamification.toJson(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  int get profileCompleteness {
    int score = 0;
    final weights = AppConstants.profileWeights;

    if (name != null && name!.isNotEmpty) score += weights['name']!;
    if (headline != null && headline!.isNotEmpty) score += weights['headline']!;
    if (summary != null && summary!.isNotEmpty) score += weights['summary']!;
    if (skills.isNotEmpty) score += weights['skills']!;
    if (experience.isNotEmpty) score += weights['experience']!;
    if (education.isNotEmpty) score += weights['education']!;
    if (preferences.isConfigured) score += weights['preferences']!;

    return score;
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    String? headline,
    String? summary,
    List<String>? skills,
    List<WorkExperience>? experience,
    List<Education>? education,
    JobPreferences? preferences,
    GamificationData? gamification,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      preferences: preferences ?? this.preferences,
      gamification: gamification ?? this.gamification,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        photoUrl,
        headline,
        summary,
        skills,
        experience,
        education,
        preferences,
        gamification,
      ];
}
