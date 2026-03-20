import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:job_board/models/job.dart';
import 'package:job_board/models/user_profile.dart';

class JobService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  JobService({FirebaseFirestore? firestore, FirebaseFunctions? functions})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get _jobsRef =>
      _firestore.collection('jobs');

  Future<List<Job>> getJobs({
    String? query,
    String? location,
    String? jobType,
    String? remote,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> ref = _jobsRef.orderBy('postedAt', descending: true);

    if (jobType != null && jobType.isNotEmpty) {
      ref = ref.where('jobType', isEqualTo: jobType);
    }
    if (remote != null && remote.isNotEmpty) {
      ref = ref.where('remote', isEqualTo: remote);
    }
    if (startAfter != null) {
      ref = ref.startAfterDocument(startAfter);
    }

    ref = ref.limit(limit);
    final snapshot = await ref.get();
    return snapshot.docs
        .map((doc) => Job.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Job?> getJob(String jobId) async {
    final doc = await _jobsRef.doc(jobId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Job.fromJson({...doc.data()!, 'id': doc.id});
  }

  Stream<List<Job>> jobsStream({int limit = 50}) {
    return _jobsRef
        .orderBy('postedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Job.fromJson({...doc.data(), 'id': doc.id}))
            .toList())
        .handleError((error) {
      // Return empty list on Firestore errors (missing index, permissions, etc.)
      return <Job>[];
    });
  }

  Future<void> triggerCrawl(JobPreferences preferences) async {
    try {
      await _functions.httpsCallable('crawlJobs').call({
        'roles': preferences.targetRoles,
        'locations': preferences.locations,
        'jobTypes': preferences.jobTypes,
        'remote': preferences.remotePreference,
      });
    } catch (_) {
      // If Cloud Functions aren't deployed, seed demo data
      await _seedDemoJobs(preferences);
    }
  }

  static int calculateMatchScore(Job job, UserProfile profile) {
    int score = 0;
    int maxScore = 0;

    // Title match (30 points)
    maxScore += 30;
    for (final role in profile.preferences.targetRoles) {
      if (job.title.toLowerCase().contains(role.toLowerCase())) {
        score += 30;
        break;
      }
    }

    // Skills match (30 points)
    maxScore += 30;
    if (profile.skills.isNotEmpty && job.requirements.isNotEmpty) {
      final matchedSkills = profile.skills
          .where((skill) => job.requirements.any(
              (req) => req.toLowerCase().contains(skill.toLowerCase())))
          .length;
      score += ((matchedSkills / profile.skills.length) * 30).round();
    }

    // Location match (15 points)
    maxScore += 15;
    if (profile.preferences.locations.isNotEmpty) {
      for (final loc in profile.preferences.locations) {
        if (job.location.toLowerCase().contains(loc.toLowerCase())) {
          score += 15;
          break;
        }
      }
    } else {
      score += 15; // No location pref = any location OK
    }

    // Remote match (10 points)
    maxScore += 10;
    if (profile.preferences.remotePreference.isNotEmpty) {
      if (profile.preferences.remotePreference.contains(job.remote)) {
        score += 10;
      }
    } else {
      score += 10;
    }

    // Job type match (10 points)
    maxScore += 10;
    if (profile.preferences.jobTypes.isNotEmpty) {
      if (profile.preferences.jobTypes.contains(job.jobType)) {
        score += 10;
      }
    } else {
      score += 10;
    }

    // Salary match (5 points)
    maxScore += 5;
    if (profile.preferences.salaryMin != null && job.salaryMax != null) {
      if (job.salaryMax! >= profile.preferences.salaryMin!) {
        score += 5;
      }
    } else {
      score += 5;
    }

    if (maxScore == 0) return 0;
    return ((score / maxScore) * 100).round().clamp(0, 100);
  }

  Future<void> _seedDemoJobs(JobPreferences preferences) async {
    final demoJobs = _generateDemoJobs(preferences);
    final batch = _firestore.batch();
    for (final job in demoJobs) {
      batch.set(_jobsRef.doc(job.id), job.toJson());
    }
    await batch.commit();
  }

  List<Job> _generateDemoJobs(JobPreferences preferences) {
    final roles = preferences.targetRoles.isNotEmpty
        ? preferences.targetRoles
        : ['Software Engineer'];
    final locations = preferences.locations.isNotEmpty
        ? preferences.locations
        : ['San Francisco, CA', 'New York, NY', 'Remote'];

    final companies = [
      ('TechFlow', 'https://ui-avatars.com/api/?name=TechFlow&background=6C5CE7&color=fff'),
      ('DataVault', 'https://ui-avatars.com/api/?name=DataVault&background=00CEC9&color=fff'),
      ('CloudNine', 'https://ui-avatars.com/api/?name=CloudNine&background=FD79A8&color=fff'),
      ('NeuralNet AI', 'https://ui-avatars.com/api/?name=NN&background=E17055&color=fff'),
      ('GreenStack', 'https://ui-avatars.com/api/?name=GS&background=00B894&color=fff'),
      ('ByteBridge', 'https://ui-avatars.com/api/?name=BB&background=0984E3&color=fff'),
      ('PixelForge', 'https://ui-avatars.com/api/?name=PF&background=D63031&color=fff'),
      ('Quantum Labs', 'https://ui-avatars.com/api/?name=QL&background=6C5CE7&color=fff'),
      ('SwiftScale', 'https://ui-avatars.com/api/?name=SS&background=FDCB6E&color=000'),
      ('InnovateCo', 'https://ui-avatars.com/api/?name=IC&background=00CEC9&color=fff'),
    ];

    final descriptions = [
      'We are looking for a talented {role} to join our growing team. You will work on cutting-edge projects that impact millions of users. We value creativity, collaboration, and continuous learning.',
      'Join our engineering team as a {role}. You\'ll be responsible for designing, developing, and maintaining scalable systems. We offer competitive compensation, equity, and great benefits.',
      'Exciting opportunity for a {role} to help build the future of {domain}. You\'ll collaborate with cross-functional teams and have the autonomy to drive technical decisions.',
      'We\'re seeking an experienced {role} to lead key initiatives. This role involves architecting solutions, mentoring team members, and contributing to our technical roadmap.',
      'As a {role}, you\'ll be at the forefront of innovation. Work with the latest technologies, tackle complex challenges, and grow your career in a supportive environment.',
    ];

    final skillSets = [
      ['Python', 'Machine Learning', 'TensorFlow', 'SQL', 'Docker'],
      ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git'],
      ['React', 'TypeScript', 'Node.js', 'GraphQL', 'AWS'],
      ['Java', 'Spring Boot', 'Kubernetes', 'Microservices', 'PostgreSQL'],
      ['Go', 'gRPC', 'Redis', 'Terraform', 'CI/CD'],
      ['Swift', 'iOS', 'UIKit', 'SwiftUI', 'Core Data'],
      ['Rust', 'WebAssembly', 'Systems Programming', 'Linux', 'C++'],
    ];

    final remoteOpts = ['Remote', 'Hybrid', 'On-site'];
    final jobTypeOpts = ['Full-time', 'Full-time', 'Full-time', 'Contract', 'Part-time'];
    final domains = ['fintech', 'healthtech', 'edtech', 'AI/ML', 'cloud infrastructure', 'developer tools', 'e-commerce'];

    final jobs = <Job>[];
    for (int i = 0; i < 20; i++) {
      final company = companies[i % companies.length];
      final role = roles[i % roles.length];
      final location = locations[i % locations.length];
      final descTemplate = descriptions[i % descriptions.length];
      final skills = skillSets[i % skillSets.length];
      final domain = domains[i % domains.length];

      jobs.add(Job(
        id: 'demo_job_${i + 1}',
        title: '${['Senior ', '', 'Staff ', 'Lead ', ''][i % 5]}$role',
        company: company.$1,
        location: location,
        description: descTemplate
            .replaceAll('{role}', role)
            .replaceAll('{domain}', domain),
        salaryMin: 80000 + (i * 10000),
        salaryMax: 120000 + (i * 15000),
        currency: 'USD',
        jobType: jobTypeOpts[i % jobTypeOpts.length],
        remote: remoteOpts[i % remoteOpts.length],
        source: 'demo',
        sourceUrl: 'https://example.com/jobs/${i + 1}',
        companyLogo: company.$2,
        requirements: skills,
        tags: [role.toLowerCase(), domain, location.toLowerCase()],
        postedAt: DateTime.now().subtract(Duration(days: i)),
      ));
    }

    return jobs;
  }
}
