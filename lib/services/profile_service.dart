import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_board/models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore;

  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromJson({...doc.data()!, 'uid': uid});
  }

  Stream<UserProfile?> profileStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromJson({...doc.data()!, 'uid': uid});
    });
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update({
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateSkills(String uid, List<String> skills) async {
    await updateProfile(uid, {'skills': skills});
  }

  Future<void> addExperience(String uid, WorkExperience experience) async {
    await _usersRef.doc(uid).update({
      'experience': FieldValue.arrayUnion([experience.toJson()]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateExperience(
      String uid, List<WorkExperience> experiences) async {
    await updateProfile(
        uid, {'experience': experiences.map((e) => e.toJson()).toList()});
  }

  Future<void> addEducation(String uid, Education education) async {
    await _usersRef.doc(uid).update({
      'education': FieldValue.arrayUnion([education.toJson()]),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateEducation(String uid, List<Education> educations) async {
    await updateProfile(
        uid, {'education': educations.map((e) => e.toJson()).toList()});
  }

  Future<void> updatePreferences(
      String uid, JobPreferences preferences) async {
    await updateProfile(uid, {'preferences': preferences.toJson()});
  }

  Future<void> updateGamification(
      String uid, GamificationData gamification) async {
    await updateProfile(uid, {'gamification': gamification.toJson()});
  }
}
