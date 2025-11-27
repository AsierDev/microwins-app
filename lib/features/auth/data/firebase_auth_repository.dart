import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<String?> get authStateChanges => _firebaseAuth.authStateChanges().map((user) => user?.uid);

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

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

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
    await _clearUserIdFromWorkManager();
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
}
