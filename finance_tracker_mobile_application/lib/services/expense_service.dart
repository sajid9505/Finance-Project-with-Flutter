import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _expensesRef(String userId) {
    return _db.collection('users').doc(userId).collection('expenses');
  }

  Stream<List<Expense>> watchExpenses(String userId) {
    return _expensesRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Expense.fromFirestore).toList());
  }

  Future<void> addExpense(String userId, Expense expense) async {
    await _expensesRef(userId).add(expense.toFirestore());
  }

  Future<void> updateExpense(String userId, Expense expense) async {
    await _expensesRef(userId).doc(expense.id).update(expense.toFirestore());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _expensesRef(userId).doc(expenseId).delete();
  }
}
