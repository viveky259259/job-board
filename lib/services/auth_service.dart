import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:job_board/models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- Email ---

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      try {
        await _createUserProfile(credential.user!);
      } catch (_) {
        // Profile creation is non-critical; the user is already authenticated.
        // Profile will be created on next launch if it doesn't exist.
      }
    }
    return credential;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // --- Google ---

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');

    final credential = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);

    if (credential.user != null) {
      try {
        await _createUserProfile(credential.user!);
      } catch (_) {}
    }
    return credential;
  }

  // --- GitHub ---

  Future<UserCredential> signInWithGitHub() async {
    final provider = GithubAuthProvider();
    provider.addScope('read:user');
    provider.addScope('user:email');

    final credential = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);

    if (credential.user != null) {
      try {
        await _createUserProfile(credential.user!);
      } catch (_) {}
    }
    return credential;
  }

  // --- Common ---

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> _createUserProfile(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(profile.toJson());
    }
  }
}
