import 'package:firebase_auth/firebase_auth.dart';

/// بيحوّل أكواد Firebase لرسائل مفهومة للمستخدم
String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Wrong email or password.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'email-already-in-use':
      return 'An account already exists for this email.';
    case 'weak-password':
      return 'Password is too weak (use at least 6 characters).';
    case 'too-many-requests':
      return 'Too many attempts. Try again later.';
    case 'network-request-failed':
      return 'No internet connection.';
    default:
      return e.message ?? 'Authentication failed.';
  }
}
