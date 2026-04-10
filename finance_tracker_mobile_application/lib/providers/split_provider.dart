import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import 'expense_provider.dart';

class OutstandingSplit {
  final Expense expense;
  final List<SplitPerson> unsettled;

  OutstandingSplit({required this.expense, required this.unsettled});

  double get totalOwed =>
      unsettled.fold(0.0, (sum, s) => sum + s.amount);
}

/// All split expenses that have at least one unsettled person
final outstandingSplitsProvider = Provider<List<OutstandingSplit>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  return expenses
      .where((e) => e.isSplit && e.splits.any((s) => !s.settled))
      .map((e) => OutstandingSplit(
            expense: e,
            unsettled: e.splits.where((s) => !s.settled).toList(),
          ))
      .toList();
});

/// Total outstanding amount across all splits
final totalOutstandingProvider = Provider<double>((ref) {
  return ref
      .watch(outstandingSplitsProvider)
      .fold(0.0, (sum, s) => sum + s.totalOwed);
});
