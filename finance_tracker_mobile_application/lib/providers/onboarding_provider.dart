import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Emits true once the current user has completed onboarding.
final onboardingCompleteProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(true); // not our concern when logged out
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.data()?['onboardingCompleted'] == true);
});

Future<void> markOnboardingComplete(String uid) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({'onboardingCompleted': true}, SetOptions(merge: true));
}
