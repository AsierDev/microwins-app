import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Incorrect email or password';
        case 'invalid-email':
          return 'Invalid email format';
        case 'email-already-in-use':
          return 'This email is already in use';
        case 'weak-password':
          return 'Password must be at least 6 characters';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        case 'network-request-failed':
          return 'Connection error. Check your internet';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'operation-not-allowed':
          return 'Operation not allowed';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
