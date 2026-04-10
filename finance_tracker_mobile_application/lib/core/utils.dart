import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(symbol: '\$');

String friendlyAuthError(String error) {
  if (error.contains('user-not-found')) return 'No account found for this email.';
  if (error.contains('wrong-password')) return 'Incorrect password.';
  if (error.contains('email-already-in-use')) return 'An account already exists for this email.';
  if (error.contains('invalid-email')) return 'Invalid email address.';
  if (error.contains('weak-password')) return 'Password is too weak.';
  if (error.contains('too-many-requests')) return 'Too many attempts. Try again later.';
  if (error.contains('operation-not-allowed') || error.contains('CONFIGURATION_NOT_FOUND')) {
    return 'Email/password sign-in is not enabled in Firebase.';
  }
  return error;
}
