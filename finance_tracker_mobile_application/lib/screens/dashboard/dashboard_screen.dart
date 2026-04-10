import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import 'balance_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/drain_provider.dart';
import '../../providers/forecast_provider.dart';
import '../../providers/split_provider.dart';
import '../../services/drain_service.dart';
import '../../models/expense.dart';
import '../expenses/add_expense_sheet.dart';
import '../drains/silent_drains_screen.dart';
import '../forecast/forecast_screen.dart';
import '../splits/splits_screen.dart';

final _splitsDismissedProvider = StateProvider<bool>((ref) => false);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _firstName(String? displayName, String? email) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.split(' ').first;
    }
    if (email != null) return email.split('@').first;
    return 'there';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final drainsAsync = ref.watch(silentDrainsProvider);
    final forecast = ref.watch(forecastProvider);
    final totalOutstanding = ref.watch(totalOutstandingProvider);
    final splitsDismissed = ref.watch(_splitsDismissedProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: kTeal,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const AddExpenseSheet(),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      body: expensesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          final now = DateTime.now();
          final thisMonthExpenses = expenses.where(
              (e) => e.date.month == now.month && e.date.year == now.year);
          final totalThisMonth =
              thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
          final recurringTotal = thisMonthExpenses
              .where((e) => e.isRecurring)
              .fold(0.0, (sum, e) => sum + e.amount);
          final oneOffTotal = totalThisMonth - recurringTotal;
          final drains = drainsAsync.value ?? [];

          return Column(
            children: [
              // ── Teal header ──────────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                _firstName(
                                    user?.displayName, user?.email),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      BalanceCard(
                        totalThisMonth: totalThisMonth,
                        oneOffTotal: oneOffTotal,
                        recurringTotal: recurringTotal,
                        allExpenses: expenses,
                      ),
                    ],
                  ),
                ),
              ),

              // ── White bottom area ─────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: kBackground,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: expenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: kTeal.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.receipt_long_outlined,
                                    size: 48,
                                    color: kTeal),
                              ),
                              const SizedBox(height: 16),
                              const Text('No expenses yet',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87)),
                              const SizedBox(height: 6),
                              Text(
                                'Tap + to add your first expense',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                          children: [
                            // Insight banners
                            if (drains.isNotEmpty)
                              _InsightBanner(
                                icon: Icons.warning_amber_rounded,
                                color: Colors.orange,
                                text:
                                    '${drains.length} silent drain${drains.length == 1 ? '' : 's'} · ${currencyFormat.format(DrainService.totalMonthlyCost(drains))}/mo',
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SilentDrainsScreen())),
                              ),
                            if (forecast
                                .any((m) => m.entries.isNotEmpty)) ...[
                              if (drains.isNotEmpty)
                                const SizedBox(height: 10),
                              _InsightBanner(
                                icon: Icons.insights_outlined,
                                color: Colors.blue,
                                text:
                                    'Next month forecast · ${currencyFormat.format(forecast.first.total)}',
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ForecastScreen())),
                              ),
                            ],
                            if (totalOutstanding > 0 &&
                                !splitsDismissed) ...[
                              if (drains.isNotEmpty ||
                                  forecast.any((m) => m.entries.isNotEmpty))
                                const SizedBox(height: 10),
                              _InsightBanner(
                                icon: Icons.people_outline,
                                color: Colors.purple,
                                text:
                                    '${currencyFormat.format(totalOutstanding)} outstanding from splits',
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const SplitsScreen())),
                                onDismiss: () => ref
                                    .read(_splitsDismissedProvider.notifier)
                                    .state = true,
                              ),
                            ],

                            // Expense list
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, bottom: 10),
                              child: Text('Recent Expenses',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade800)),
                            ),
                            ...expenses.map((e) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: _ExpenseTile(expense: e),
                                )),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Stat item inside balance card ──────────────────────────────────────────

// ─── Insight Banner ──────────────────────────────────────────────────────────

class _InsightBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const _InsightBanner({
    required this.icon,
    required this.color,
    required this.text,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800)),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close,
                    size: 16, color: Colors.grey.shade400),
              )
            else
              Icon(Icons.chevron_right,
                  size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Tile ─────────────────────────────────────────────────────────────

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
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete expense?'),
          content: Text('Remove "${expense.description}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
      onDismissed: (_) async {
        final user = ref.read(authServiceProvider).currentUser;
        if (user != null) {
          await ref
              .read(expenseServiceProvider)
              .deleteExpense(user.uid, expense.id);
        }
      },
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => AddExpenseSheet(expense: expense),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      _categoryColor(expense.category).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _categoryIcon(expense.category),
                  color: _categoryColor(expense.category),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.description,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(expense.category,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                        if (expense.isRecurring) ...[
                          Text(' · ',
                              style: TextStyle(
                                  color: Colors.grey.shade400)),
                          Icon(Icons.repeat,
                              size: 11,
                              color: Colors.grey.shade400),
                          const SizedBox(width: 2),
                          Text(expense.recurrenceInterval ?? '',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400)),
                        ],
                        if (expense.isSplit) ...[
                          Text(' · ',
                              style: TextStyle(
                                  color: Colors.grey.shade400)),
                          Icon(Icons.people_outline,
                              size: 11,
                              color: Colors.grey.shade400),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '- ${currencyFormat.format(expense.amount)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('dd MMM').format(expense.date),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food & Dining': return Icons.restaurant_outlined;
      case 'Grocery': return Icons.local_grocery_store_outlined;
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

  Color _categoryColor(String category) {
    switch (category) {
      case 'Food & Dining': return Colors.orange;
      case 'Grocery': return Colors.green;
      case 'Transport': return Colors.blue;
      case 'Housing': return Colors.brown;
      case 'Utilities': return Colors.yellow.shade700;
      case 'Entertainment': return Colors.purple;
      case 'Health': return Colors.red;
      case 'Shopping': return Colors.pink;
      case 'Subscriptions': return kTeal;
      default: return Colors.grey;
    }
  }
}
