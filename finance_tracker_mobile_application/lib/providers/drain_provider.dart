import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/drain_service.dart';
import 'expense_provider.dart';
import 'auth_provider.dart';

final drainServiceProvider = Provider<DrainService>((ref) => DrainService());

/// Provides active (non-dismissed) silent drains derived from the expense stream
final silentDrainsProvider = FutureProvider.autoDispose<List<Expense>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];

  final expensesAsync = ref.watch(expensesProvider);
  final allExpenses = expensesAsync.value ?? [];

  return ref.read(drainServiceProvider).getActiveDrains(user.uid, allExpenses);
});
