import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/drain_provider.dart';
import '../../providers/forecast_provider.dart';
import '../../providers/split_provider.dart';
import '../../services/drain_service.dart';
import '../../models/expense.dart';
import '../auth/login_screen.dart';
import '../expenses/add_expense_sheet.dart';
import '../drains/silent_drains_screen.dart';
import '../forecast/forecast_screen.dart';
import '../splits/splits_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final drainsAsync = ref.watch(silentDrainsProvider);
    final forecast = ref.watch(forecastProvider);
    final totalOutstanding = ref.watch(totalOutstandingProvider);
    final splitsDismissed = ref.watch(_splitsDismissedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No expenses yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Tap + to add your first expense',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            );
          }

          final totalThisMonth = expenses
              .where((e) =>
                  e.date.month == DateTime.now().month &&
                  e.date.year == DateTime.now().year)
              .fold(0.0, (sum, e) => sum + e.amount);

          final drains = drainsAsync.value ?? [];

          return Column(
            children: [
              _SummaryCard(totalThisMonth: totalThisMonth),
              if (drains.isNotEmpty)
                _DrainBanner(
                  count: drains.length,
                  totalMonthly: DrainService.totalMonthlyCost(drains),
                ),
              if (forecast.any((m) => m.entries.isNotEmpty))
                _ForecastCard(nextMonthTotal: forecast.first.total),
              if (totalOutstanding > 0 && !splitsDismissed)
                _SplitsCard(
                  totalOutstanding: totalOutstanding,
                  onDismiss: () =>
                      ref.read(_splitsDismissedProvider.notifier).state = true,
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: expenses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ExpenseTile(expense: expenses[i]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => const AddExpenseSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// In-memory dismiss state — resets when app restarts (intentional, per spec)
final _splitsDismissedProvider = StateProvider<bool>((ref) => false);

class _SplitsCard extends StatelessWidget {
  final double totalOutstanding;
  final VoidCallback onDismiss;

  const _SplitsCard({required this.totalOutstanding, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SplitsScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border.all(color: Colors.blue.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.people_outline, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${currency.format(totalOutstanding)} outstanding from splits',
                style: TextStyle(
                    color: Colors.blue.shade800, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.blue.shade400, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Dismiss',
              onPressed: onDismiss,
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final double nextMonthTotal;
  const _ForecastCard({required this.nextMonthTotal});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForecastScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          border: Border.all(
              color: Theme.of(context).colorScheme.secondaryContainer),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.insights_outlined,
                color: Theme.of(context).colorScheme.secondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Next month forecast · ${currency.format(nextMonthTotal)}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}

class _DrainBanner extends StatelessWidget {
  final int count;
  final double totalMonthly;
  const _DrainBanner({required this.count, required this.totalMonthly});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SilentDrainsScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count silent drain${count == 1 ? '' : 's'} · ${currency.format(totalMonthly)}/mo',
                style: TextStyle(
                    color: Colors.orange.shade800, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.orange.shade700),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalThisMonth;
  const _SummaryCard({required this.totalThisMonth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This Month',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                NumberFormat.currency(symbol: '\$').format(totalThisMonth),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.account_balance_wallet_outlined,
              size: 40, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ],
      ),
    );
  }
}

class _ExpenseTile extends ConsumerWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete expense?'),
            content: Text('Remove "${expense.description}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        final user = ref.read(authServiceProvider).currentUser;
        if (user != null) {
          await ref.read(expenseServiceProvider).deleteExpense(user.uid, expense.id);
        }
      },
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => AddExpenseSheet(expense: expense),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(_categoryIcon(expense.category),
                  color: Theme.of(context).colorScheme.onSecondaryContainer, size: 20),
            ),
            title: Text(expense.description,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Row(
              children: [
                Text(expense.category,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (expense.isRecurring) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.repeat, size: 12, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(expense.recurrenceInterval ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(symbol: '\$').format(expense.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  DateFormat('dd MMM').format(expense.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food & Dining': return Icons.restaurant_outlined;
      case 'Transport': return Icons.directions_car_outlined;
      case 'Housing': return Icons.home_outlined;
      case 'Utilities': return Icons.bolt_outlined;
      case 'Entertainment': return Icons.movie_outlined;
      case 'Health': return Icons.favorite_outline;
      case 'Shopping': return Icons.shopping_bag_outlined;
      case 'Subscriptions': return Icons.subscriptions_outlined;
      default: return Icons.receipt_outlined;
    }
  }
}
