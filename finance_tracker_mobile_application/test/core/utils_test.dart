import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_mobile_application/core/utils.dart';

void main() {
  group('friendlyAuthError', () {
    test('user-not-found', () {
      expect(
        friendlyAuthError('user-not-found'),
        'No account found for this email.',
      );
    });

    test('wrong-password', () {
      expect(friendlyAuthError('wrong-password'), 'Incorrect password.');
    });

    test('email-already-in-use', () {
      expect(
        friendlyAuthError('email-already-in-use'),
        'An account already exists for this email.',
      );
    });

    test('invalid-email', () {
      expect(friendlyAuthError('invalid-email'), 'Invalid email address.');
    });

    test('weak-password', () {
      expect(friendlyAuthError('weak-password'), 'Password is too weak.');
    });

    test('too-many-requests', () {
      expect(
        friendlyAuthError('too-many-requests'),
        'Too many attempts. Try again later.',
      );
    });

    test('operation-not-allowed', () {
      expect(
        friendlyAuthError('operation-not-allowed'),
        'Email/password sign-in is not enabled in Firebase.',
      );
    });

    test('CONFIGURATION_NOT_FOUND', () {
      expect(
        friendlyAuthError('CONFIGURATION_NOT_FOUND'),
        'Email/password sign-in is not enabled in Firebase.',
      );
    });

    test('unknown error is returned unchanged', () {
      const raw = 'some-unexpected-error';
      expect(friendlyAuthError(raw), raw);
    });

    test('Firebase error message containing known code is matched', () {
      expect(
        friendlyAuthError('[firebase_auth/wrong-password] The password is invalid.'),
        'Incorrect password.',
      );
    });

    test('Firebase error message containing user-not-found is matched', () {
      expect(
        friendlyAuthError('[firebase_auth/user-not-found] There is no user record.'),
        'No account found for this email.',
      );
    });

    test('empty string is returned unchanged', () {
      expect(friendlyAuthError(''), '');
    });
  });
}
