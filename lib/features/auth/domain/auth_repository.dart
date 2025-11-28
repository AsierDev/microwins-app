abstract class AuthRepository {
  Stream<String?> get authStateChanges;
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signUpWithEmailAndPassword(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInAnonymously();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  String? get currentUser;
  Future<void> deleteAccount();
}
