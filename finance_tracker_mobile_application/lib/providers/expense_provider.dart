import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'auth_provider.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) => ExpenseService());

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(expenseServiceProvider).watchExpenses(user.uid);
});
