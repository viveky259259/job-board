import 'package:cloud_functions/cloud_functions.dart';
import 'package:job_board/models/cover_letter.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class AiService {
  final FirebaseFunctions _functions;

  AiService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<CoverLetter> generateCoverLetter({
    required Job job,
    required UserProfile profile,
    ContentTone tone = ContentTone.professional,
  }) async {
    try {
      final result =
          await _functions.httpsCallable('generateCoverLetter').call({
        'jobTitle': job.title,
        'jobCompany': job.company,
        'jobDescription': job.description,
        'jobRequirements': job.requirements,
        'userName': profile.name,
        'userHeadline': profile.headline,
        'userSummary': profile.summary,
        'userSkills': profile.skills,
        'userExperience':
            profile.experience.map((e) => e.toJson()).toList(),
        'tone': tone.name,
      });

      return CoverLetter(
        id: const Uuid().v4(),
        userId: profile.uid,
        jobId: job.id,
        content: result.data['content'] as String,
        tone: tone,
        atsScore: result.data['atsScore'] as int?,
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return _generateLocalCoverLetter(
          job: job, profile: profile, tone: tone);
    }
  }

  Future<IntroMessage> generateIntroMessage({
    required Job job,
    required UserProfile profile,
    ContentTone tone = ContentTone.professional,
    String platform = 'LinkedIn',
  }) async {
    try {
      final result =
          await _functions.httpsCallable('generateIntroMessage').call({
        'jobTitle': job.title,
        'jobCompany': job.company,
        'jobDescription': job.description,
        'userName': profile.name,
        'userHeadline': profile.headline,
        'userSkills': profile.skills,
        'tone': tone.name,
        'platform': platform,
      });

      return IntroMessage(
        id: const Uuid().v4(),
        userId: profile.uid,
        jobId: job.id,
        content: result.data['content'] as String,
        tone: tone,
        platform: platform,
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return _generateLocalIntroMessage(
          job: job, profile: profile, tone: tone, platform: platform);
    }
  }

  CoverLetter _generateLocalCoverLetter({
    required Job job,
    required UserProfile profile,
    required ContentTone tone,
  }) {
    final name = profile.name ?? 'Job Applicant';
    final headline = profile.headline ?? 'Professional';
    final skills =
        profile.skills.isNotEmpty ? profile.skills.take(5).join(', ') : 'various skills';
    final experience = profile.experience.isNotEmpty
        ? profile.experience.first
        : null;

    String greeting;
    String closing;
    switch (tone) {
      case ContentTone.enthusiastic:
        greeting = "I'm thrilled to apply for the ${job.title} position at ${job.company}!";
        closing = "I'm incredibly excited about this opportunity and would love to bring my passion and expertise to your team!";
      case ContentTone.casual:
        greeting = "I came across the ${job.title} role at ${job.company} and it really caught my eye.";
        closing = "I'd love to chat more about how I can contribute to the team. Looking forward to connecting!";
      case ContentTone.professional:
        greeting = "I am writing to express my strong interest in the ${job.title} position at ${job.company}.";
        closing = "I am confident that my experience and skills make me a strong candidate for this role. I look forward to the opportunity to discuss how I can contribute to your team.";
    }

    final experienceSection = experience != null
        ? "\n\nIn my role as ${experience.title} at ${experience.company}, I developed strong expertise in $skills. ${experience.description ?? ''}"
        : "\n\nWith expertise in $skills, I have developed a strong foundation that aligns well with this role's requirements.";

    final requirementsSection = job.requirements.isNotEmpty
        ? "\n\nI noticed you're looking for experience with ${job.requirements.take(3).join(', ')}. I have hands-on experience with these technologies and am confident in my ability to hit the ground running."
        : '';

    final content = '''Dear Hiring Manager,

$greeting

As a $headline, I bring a proven track record of delivering high-quality results.$experienceSection$requirementsSection

$closing

Best regards,
$name''';

    final matchedReqs = job.requirements
        .where((req) => profile.skills
            .any((s) => req.toLowerCase().contains(s.toLowerCase())))
        .length;
    final atsScore = job.requirements.isNotEmpty
        ? ((matchedReqs / job.requirements.length) * 100).round().clamp(0, 100)
        : 75;

    return CoverLetter(
      id: const Uuid().v4(),
      userId: profile.uid,
      jobId: job.id,
      content: content,
      tone: tone,
      atsScore: atsScore,
      createdAt: DateTime.now(),
    );
  }

  IntroMessage _generateLocalIntroMessage({
    required Job job,
    required UserProfile profile,
    required ContentTone tone,
    required String platform,
  }) {
    final name = profile.name ?? 'there';
    final headline = profile.headline ?? 'a professional';
    final topSkill =
        profile.skills.isNotEmpty ? profile.skills.first : 'software development';

    String content;
    switch (tone) {
      case ContentTone.enthusiastic:
        content =
            "Hi! I'm $name, $headline with a passion for $topSkill. I just saw the ${job.title} opening at ${job.company} and I'm really excited about it! I'd love to learn more about the role and share how my background could be a great fit. Would you be open to a quick chat?";
      case ContentTone.casual:
        content =
            "Hey! I'm $name — $headline. Noticed the ${job.title} role at ${job.company} and thought my background in $topSkill could be a solid match. Would love to connect and learn more about the team!";
      case ContentTone.professional:
        content =
            "Hello, I'm $name, $headline. I noticed the ${job.title} position at ${job.company} and believe my experience in $topSkill aligns well with your team's needs. I would appreciate the opportunity to connect and learn more about this role. Thank you for your time.";
    }

    return IntroMessage(
      id: const Uuid().v4(),
      userId: profile.uid,
      jobId: job.id,
      content: content,
      tone: tone,
      platform: platform,
      createdAt: DateTime.now(),
    );
  }
}
