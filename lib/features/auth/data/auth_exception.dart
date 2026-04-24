import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  factory AuthException.fromFirebase(Object error) {
    if (error is FirebaseAuthException) {
      return AuthException(_messageFor(error.code));
    }
    return const AuthException('Something went wrong. Try again.');
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address looks malformed.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        return 'Authentication failed. Try again.';
    }
  }

  @override
  String toString() => message;
}
