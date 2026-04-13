import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';
import 'auth_provider.dart';

final budgetServiceProvider =
    Provider<BudgetService>((ref) => BudgetService());

final budgetProvider = StreamProvider<Budget?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.read(budgetServiceProvider).watchBudget(user.uid);
});
