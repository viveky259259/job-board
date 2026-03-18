import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_board/models/subscription.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore;

  SubscriptionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _subRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('settings').doc('subscription');

  Future<UserSubscription> getSubscription(String userId) async {
    final doc = await _subRef(userId).get();
    if (!doc.exists || doc.data() == null) return UserSubscription.free();
    return UserSubscription.fromJson(doc.data()!);
  }

  Stream<UserSubscription> subscriptionStream(String userId) {
    return _subRef(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return UserSubscription.free();
      return UserSubscription.fromJson(doc.data()!);
    });
  }

  Future<void> saveSubscription(String userId, UserSubscription sub) async {
    await _subRef(userId).set(sub.toJson());
  }

  Future<void> upgradeTo(
    String userId,
    SubscriptionTier tier, {
    bool yearly = false,
  }) async {
    final now = DateTime.now();
    final end = yearly
        ? now.add(const Duration(days: 365))
        : DateTime(now.year, now.month + 1, now.day);

    final current = await getSubscription(userId);
    final updated = current.copyWith(
      tier: tier,
      startDate: now,
      endDate: end,
      isYearly: yearly,
    );
    await saveSubscription(userId, updated);
  }

  Future<void> cancelSubscription(String userId) async {
    final current = await getSubscription(userId);
    final updated = current.copyWith(tier: SubscriptionTier.free);
    await saveSubscription(userId, updated);
  }

  Future<UserSubscription> incrementUsage(
    String userId,
    String usageType,
  ) async {
    final sub = await getSubscription(userId);
    final currentMonth = UsageLimits.forCurrentMonth().monthKey;

    UsageLimits usage = sub.usage;
    if (usage.monthKey != currentMonth) {
      usage = UsageLimits.forCurrentMonth();
    }

    switch (usageType) {
      case 'coverLetter':
        usage = usage.incrementCoverLetters();
      case 'introMessage':
        usage = usage.incrementIntroMessages();
      case 'resumeAnalysis':
        usage = usage.incrementResumeAnalyses();
      case 'interviewPrep':
        usage = usage.incrementInterviewPreps();
    }

    final updated = sub.copyWith(usage: usage);
    await saveSubscription(userId, updated);
    return updated;
  }
}
