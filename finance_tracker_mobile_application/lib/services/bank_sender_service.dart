import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bank_sender.dart';

class BankSenderService {
  static const _prefsKey = 'sms_senders';

  DocumentReference _settingsRef(String uid) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('settings')
      .doc('bankSenders');

  Stream<List<BankSender>> watchSenders(String uid) {
    return _settingsRef(uid).snapshots().map((snap) {
      if (!snap.exists) return [];
      final data = snap.data() as Map<String, dynamic>;
      final list = data['senders'] as List<dynamic>? ?? [];
      return list
          .map((e) => BankSender.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Future<void> addSender(String uid, BankSender sender) async {
    final ref = _settingsRef(uid);
    await ref.set({
      'senders': FieldValue.arrayUnion([sender.toMap()])
    }, SetOptions(merge: true));
    await _syncToPrefs(uid);
  }

  Future<void> removeSender(String uid, String senderId) async {
    final snap = await _settingsRef(uid).get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    final list = (data['senders'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((e) => e['senderId'] != senderId)
        .toList();
    await _settingsRef(uid).set({'senders': list});
    await _syncToPrefs(uid);
  }

  Future<void> _syncToPrefs(String uid) async {
    final snap = await _settingsRef(uid).get();
    if (!snap.exists) return;
    final data = snap.data() as Map<String, dynamic>;
    final ids = (data['senders'] as List<dynamic>? ?? [])
        .map((e) => (e as Map)['senderId'] as String)
        .toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, ids);
  }

  /// Called on login to sync the allowlist to SharedPreferences for the native receiver.
  Future<void> syncOnLogin(String uid) => _syncToPrefs(uid);
}
