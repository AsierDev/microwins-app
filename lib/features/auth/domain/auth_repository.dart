abstract class AuthRepository {
  Stream<String?> get authStateChanges;
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signUpWithEmailAndPassword(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInAnonymously();
  Future<void> signOut();
  String? get currentUser;
  Future<void> deleteAccount();
}
