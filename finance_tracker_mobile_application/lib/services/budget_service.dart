import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget.dart';

class BudgetService {
  final _db = FirebaseFirestore.instance;

  Stream<Budget?> watchBudget(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('budget')
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Budget.fromFirestore(snap.data()!);
    });
  }

  Future<void> setBudget(String uid, Budget budget) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('budget')
        .set(budget.toFirestore());
  }
}
