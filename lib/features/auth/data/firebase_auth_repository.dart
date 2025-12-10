import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../domain/auth_repository.dart';

import '../../habits/data/models/habit_model.dart';
import '../../gamification/data/models/habit_completion_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<String?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((user) => user?.uid);

  @override
  String? get currentUser => _firebaseAuth.currentUser?.uid;

  /// Save user ID to SharedPreferences for WorkManager multi-process access
  Future<void> _saveUserIdForWorkManager(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
  }

  /// Clear user ID from SharedPreferences on sign out
  Future<void> _clearUserIdFromWorkManager() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  @override
  Future<void> signInAnonymously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    if (userCredential.user != null) {
      await _saveUserIdForWorkManager(userCredential.user!.uid);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user != null) {
      await _saveUserIdForWorkManager(userCredential.user!.uid);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // User canceled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user != null) {
      await _saveUserIdForWorkManager(userCredential.user!.uid);
    }
  }

  @override
  Future<void> signOut() async {
    // 1. Clear local Hive data
    await Hive.box<HabitModel>('habits').clear();
    await Hive.box<HabitCompletionModel>('completions').clear();
    // Clear user-specific settings but preserve app-level settings (e.g., hasSeenOnboarding)
    final settingsBox = Hive.box<dynamic>('settings');
    final keysToPreserve = ['hasSeenOnboarding', 'theme_mode'];
    final keysToDelete = settingsBox.keys
        .where((key) => !keysToPreserve.contains(key))
        .toList();
    for (final key in keysToDelete) {
      await settingsBox.delete(key);
    }
    await Hive.box<dynamic>('syncQueue').clear();

    // 2. Clear WorkManager user ID
    await _clearUserIdFromWorkManager();

    // 3. Sign out from Firebase and Google
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user != null) {
      await _saveUserIdForWorkManager(userCredential.user!.uid);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    try {
      // 1. Try to delete Firestore user data (skip if no permissions or doesn't exist)
      try {
        final firestore = FirebaseFirestore.instance;
        final docRef = firestore.collection('users').doc(user.uid);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          await docRef.delete();
        }
      } catch (firestoreError) {
        // Ignore Firestore errors (e.g., permission-denied, not-found)
        // Continue with account deletion even if Firestore fails
        print('Firestore deletion skipped: $firestoreError');
      }

      // 2. Clear local Hive data
      await Hive.deleteBoxFromDisk('habits');
      await Hive.deleteBoxFromDisk('completions');
      await Hive.deleteBoxFromDisk('settings');

      // 3. Clear WorkManager user ID
      await _clearUserIdFromWorkManager();

      // 4. Delete Firebase Auth account
      await user.delete();

      // 5. Sign out from Google (if applicable)
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
