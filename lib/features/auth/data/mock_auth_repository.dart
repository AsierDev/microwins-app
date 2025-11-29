import 'dart:async';
import '../domain/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<String?>.broadcast();
  String? _currentUser;

  MockAuthRepository() {
    // Simulate initial auth state check
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.add(null);
    });
  }

  @override
  Stream<String?> get authStateChanges => _controller.stream;

  @override
  String? get currentUser => _currentUser;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = 'mock_user_id';
    _controller.add(_currentUser);
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = 'mock_user_id';
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = 'mock_user_id';
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInAnonymously() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = 'mock_anon_id';
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Mock implementation - just simulate a delay
    await Future<void>.delayed(const Duration(seconds: 1));
    // In a real implementation, this would send an email
  }
}
