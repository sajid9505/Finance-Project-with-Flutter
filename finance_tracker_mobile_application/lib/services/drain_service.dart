import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class DrainService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _dismissedRef(String userId) {
    return _db.collection('users').doc(userId).collection('dismissedDrains');
  }

  /// Returns all recurring expenses that have NOT been dismissed
  Future<List<Expense>> getActiveDrains(String userId, List<Expense> allExpenses) async {
    final dismissed = await _dismissedRef(userId).get();
    final now = DateTime.now();

    final dismissedIds = dismissed.docs
        .where((doc) {
          final until = (doc.data()['dismissedUntil'] as Timestamp).toDate();
          return until.isAfter(now);
        })
        .map((doc) => doc.id)
        .toSet();

    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return allExpenses
        .where((e) =>
            e.isRecurring &&
            !dismissedIds.contains(e.id) &&
            e.createdAt.isBefore(thirtyDaysAgo))
        .toList();
  }

  /// Dismiss a drain for 30 days
  Future<void> dismiss(String userId, String expenseId) async {
    await _dismissedRef(userId).doc(expenseId).set({
      'dismissedUntil': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
    });
  }

  /// Convert any recurring expense amount to monthly equivalent
  static double toMonthlyAmount(Expense expense) {
    switch (expense.recurrenceInterval) {
      case 'weekly':
        return expense.amount * 52 / 12;
      case 'fortnightly':
        return expense.amount * 26 / 12;
      case 'monthly':
      default:
        return expense.amount;
    }
  }

  static double totalMonthlyCost(List<Expense> drains) {
    return drains.fold(0.0, (sum, e) => sum + toMonthlyAmount(e));
  }
}
