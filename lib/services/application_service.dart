import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_board/models/application.dart';
import 'package:uuid/uuid.dart';

class ApplicationService {
  final FirebaseFirestore _firestore;

  ApplicationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _applicationsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('applications');

  Future<Application> saveJob({
    required String userId,
    required String jobId,
    required String jobTitle,
    required String company,
    int matchScore = 0,
  }) async {
    final existing = await _applicationsRef(userId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return Application.fromJson(
          {...existing.docs.first.data(), 'id': existing.docs.first.id});
    }

    final id = const Uuid().v4();
    final app = Application(
      id: id,
      userId: userId,
      jobId: jobId,
      jobTitle: jobTitle,
      company: company,
      status: ApplicationStatus.saved,
      matchScore: matchScore,
      createdAt: DateTime.now(),
      statusUpdates: [
        StatusUpdate(
          status: ApplicationStatus.saved,
          at: DateTime.now(),
        ),
      ],
    );

    await _applicationsRef(userId).doc(id).set(app.toJson());
    return app;
  }

  Future<void> updateStatus(
    String userId,
    String applicationId,
    ApplicationStatus newStatus, {
    String? note,
  }) async {
    final ref = _applicationsRef(userId).doc(applicationId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final app = Application.fromJson({...doc.data()!, 'id': doc.id});

    final update = StatusUpdate(
      status: newStatus,
      at: DateTime.now(),
      note: note,
    );

    final updatedApp = app.copyWith(
      status: newStatus,
      statusUpdates: [...app.statusUpdates, update],
      appliedAt: newStatus == ApplicationStatus.applied
          ? DateTime.now()
          : app.appliedAt,
    );

    await ref.update(updatedApp.toJson());
  }

  Future<void> updateNotes(
      String userId, String applicationId, String notes) async {
    await _applicationsRef(userId).doc(applicationId).update({'notes': notes});
  }

  Future<void> linkCoverLetter(
      String userId, String applicationId, String coverLetterId) async {
    await _applicationsRef(userId)
        .doc(applicationId)
        .update({'coverLetterId': coverLetterId});
  }

  Future<void> deleteApplication(String userId, String applicationId) async {
    await _applicationsRef(userId).doc(applicationId).delete();
  }

  Stream<List<Application>> applicationsStream(String userId) {
    return _applicationsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Application.fromJson({...doc.data(), 'id': doc.id}))
            .toList())
        .transform(
      StreamTransformer<List<Application>, List<Application>>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) => sink.add(<Application>[]),
      ),
    );
  }

  Future<List<Application>> getApplications(String userId) async {
    final snapshot = await _applicationsRef(userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map(
            (doc) => Application.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Map<ApplicationStatus, int>> getStatusCounts(String userId) async {
    final apps = await getApplications(userId);
    final counts = <ApplicationStatus, int>{};
    for (final status in ApplicationStatus.values) {
      counts[status] = apps.where((a) => a.status == status).length;
    }
    return counts;
  }

  Future<Application?> getApplicationForJob(
      String userId, String jobId) async {
    final snapshot = await _applicationsRef(userId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Application.fromJson(
        {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
  }
}
