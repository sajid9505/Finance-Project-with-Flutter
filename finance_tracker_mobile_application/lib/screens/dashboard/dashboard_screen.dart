import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import 'balance_card.dart';
import '../../models/budget.dart';
import '../../models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/drain_provider.dart';
import '../../providers/forecast_provider.dart';
import '../../providers/split_provider.dart';
import '../../services/drain_service.dart';
import '../../services/ocr_service.dart';
import '../expenses/add_expense_sheet.dart';
import '../drains/silent_drains_screen.dart';
import '../forecast/forecast_screen.dart';
import '../splits/splits_screen.dart';
import '../breakdown/spending_breakdown_screen.dart';

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
    final budget = ref.watch(budgetProvider).value;
    final categoryTypes = ref.watch(categoryTypesProvider).value ?? kDefaultEssentialMap;
    final fmt = ref.watch(currencyFormatProvider);

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
          final thisMonthExpenses = expenses
              .where((e) => e.date.month == now.month && e.date.year == now.year)
              .toList();
          final totalThisMonth =
              thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
          final recurringTotal = thisMonthExpenses
              .where((e) => e.isRecurring)
              .fold(0.0, (sum, e) => sum + e.amount);
          final oneOffTotal = totalThisMonth - recurringTotal;
          final drains = drainsAsync.value ?? [];

          // Budget over-budget check
          final isOverBudget = _isOverBudget(budget, expenses, now, categoryTypes);

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting(),
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400)),
                              Text(_firstName(user?.displayName, user?.email),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
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
                        isOverBudget: isOverBudget,
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    children: [
                      // ── Scan Receipt card ────────────────────────────
                      _ScanReceiptCard(expenses: expenses),
                      const SizedBox(height: 12),

                      // ── Daily reflection card ────────────────────────
                      if (budget != null &&
                          budget.categoryBudgets.keys.any(
                              (c) => categoryTypes[c] != true)) ...[
                        _DailyReflectionCard(
                          budget: budget,
                          expenses: expenses,
                          categoryTypes: categoryTypes,
                          fmt: fmt,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Insight banners ──────────────────────────────
                      if (drains.isNotEmpty)
                        _InsightBanner(
                          icon: Icons.warning_amber_rounded,
                          color: Colors.orange,
                          text:
                              '${drains.length} silent drain${drains.length == 1 ? '' : 's'} · ${fmt.format(DrainService.totalMonthlyCost(drains))}/mo',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SilentDrainsScreen())),
                        ),
                      if (forecast.any((m) => m.entries.isNotEmpty)) ...[
                        if (drains.isNotEmpty) const SizedBox(height: 10),
                        _InsightBanner(
                          icon: Icons.insights_outlined,
                          color: Colors.blue,
                          text:
                              'Next month forecast · ${fmt.format(forecast.first.total)}',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ForecastScreen())),
                        ),
                      ],
                      if (totalOutstanding > 0 && !splitsDismissed) ...[
                        if (drains.isNotEmpty ||
                            forecast.any((m) => m.entries.isNotEmpty))
                          const SizedBox(height: 10),
                        _InsightBanner(
                          icon: Icons.people_outline,
                          color: Colors.purple,
                          text:
                              '${fmt.format(totalOutstanding)} outstanding from splits',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SplitsScreen())),
                          onDismiss: () => ref
                              .read(_splitsDismissedProvider.notifier)
                              .state = true,
                        ),
                      ],

                      // ── Spending breakdown banner ────────────────────
                      if (thisMonthExpenses.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _InsightBanner(
                          icon: Icons.pie_chart_outline,
                          color: kTeal,
                          text: 'View essentials vs non-essentials breakdown',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SpendingBreakdownScreen())),
                        ),
                      ],

                      // ── Expense list ─────────────────────────────────
                      if (expenses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Column(
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
                              Text('Tap + to add your first expense',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                        )
                      else ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Text('Recent Expenses',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800)),
                        ),
                        ...expenses.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ExpenseTile(expense: e, fmt: fmt),
                            )),
                      ],
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

  bool _isOverBudget(Budget? budget, List<Expense> expenses, DateTime now,
      Map<String, bool> categoryTypes) {
    if (budget == null || !budget.hasCategoryBudgets) return false;
    final daysInPeriod = budget.period == 'weekly'
        ? 7.0
        : DateTime(now.year, now.month + 1, 0).day.toDouble();
    for (final entry in budget.categoryBudgets.entries) {
      // Only daily-track non-essential categories
      if (categoryTypes[entry.key] == true) continue;
      final dailyAllowance = entry.value / daysInPeriod;
      final todaySpent = expenses
          .where((e) =>
              e.category == entry.key &&
              e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day)
          .fold(0.0, (s, e) => s + e.amount);
      if (todaySpent > dailyAllowance) return true;
    }
    return false;
  }
}

// ─── Scan Receipt Card ────────────────────────────────────────────────────────

class _ScanReceiptCard extends ConsumerStatefulWidget {
  final List<Expense> expenses;
  const _ScanReceiptCard({required this.expenses});

  @override
  ConsumerState<_ScanReceiptCard> createState() => _ScanReceiptCardState();
}

class _ScanReceiptCardState extends ConsumerState<_ScanReceiptCard> {
  bool _isScanning = false;

  Future<void> _scan(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() => _isScanning = true);
    final ocr = OcrService();
    try {
      final data = await ocr.scanReceipt(File(picked.path));
      if (!mounted) return;

      // Pre-fill expense from OCR then open sheet
      final prefilled = Expense(
        id: '',
        amount: data.amount ?? 0,
        category: data.category ?? kExpenseCategories.first,
        description: data.description ?? '',
        date: data.date ?? DateTime.now(),
        isRecurring: false,
        createdAt: DateTime.now(),
        isSplit: false,
        splits: const [],
      );

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => AddExpenseSheet(prefilled: prefilled),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
    } finally {
      ocr.dispose();
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _scan(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _scan(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isScanning ? null : _showOptions,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kTeal, kTealDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: kTeal.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isScanning
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.document_scanner_outlined,
                      color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Scan a Receipt',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    _isScanning
                        ? 'Extracting details...'
                        : 'Instantly log expenses from a photo',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7), size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Daily Reflection Card ────────────────────────────────────────────────────

class _DailyReflectionCard extends StatelessWidget {
  final Budget budget;
  final List<Expense> expenses;
  final Map<String, bool> categoryTypes;
  final NumberFormat fmt;

  const _DailyReflectionCard({
    required this.budget,
    required this.expenses,
    required this.categoryTypes,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInPeriod = budget.period == 'weekly'
        ? 7.0
        : DateTime(now.year, now.month + 1, 0).day.toDouble();
    final periodLabel = budget.period == 'weekly' ? 'wk' : 'mo';

    // Today's spend per category
    final todayByCategory = <String, double>{};
    for (final e in expenses) {
      if (e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day) {
        todayByCategory[e.category] =
            (todayByCategory[e.category] ?? 0) + e.amount;
      }
    }

    // Only daily-track non-essential categories
    final catEntries = budget.categoryBudgets.entries
        .where((e) => categoryTypes[e.key] != true)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Overall status: any category over its daily allowance?
    final anyOver = catEntries.any((entry) {
      final dailyAllowance = entry.value / daysInPeriod;
      return (todayByCategory[entry.key] ?? 0) > dailyAllowance;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Daily Spending",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: anyOver
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  anyOver ? 'Over limit' : 'On track',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: anyOver
                          ? Colors.red.shade700
                          : Colors.green.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Per-category rows ────────────────────────────────────────
          ...catEntries.map((entry) {
            final category = entry.key;
            final periodBudget = entry.value;
            final dailyAllowance = periodBudget / daysInPeriod;
            final todaySpent = todayByCategory[category] ?? 0;
            final isOver = todaySpent > dailyAllowance;
            final fraction = dailyAllowance > 0
                ? (todaySpent / dailyAllowance).clamp(0.0, 1.0)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _categoryColor(category)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(_categoryIcon(category),
                            color: _categoryColor(category), size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(category,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800)),
                      ),
                      if (isOver)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.warning_amber_rounded,
                              size: 13, color: Colors.red.shade400),
                        ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 12,
                              color: isOver
                                  ? Colors.red.shade600
                                  : Colors.grey.shade600),
                          children: [
                            TextSpan(
                              text: fmt.format(todaySpent),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isOver
                                      ? Colors.red.shade600
                                      : Colors.black87),
                            ),
                            TextSpan(
                              text:
                                  ' / ${fmt.format(dailyAllowance)}/day',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 5,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOver
                              ? Colors.red.shade400
                              : _categoryColor(category)
                                  .withOpacity(0.65)),
                    ),
                  ),
                  if (isOver) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${fmt.format(todaySpent - dailyAllowance)} over today\'s allowance',
                      style: TextStyle(
                          fontSize: 11, color: Colors.red.shade400),
                    ),
                  ],
                ],
              ),
            );
          }),

          // ── Period reminder ──────────────────────────────────────────
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Daily allowances based on your $periodLabel budget ÷ days in period',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':  return Icons.restaurant_outlined;
      case 'Grocery':        return Icons.local_grocery_store_outlined;
      case 'Transport':      return Icons.directions_car_outlined;
      case 'Housing':        return Icons.home_outlined;
      case 'Utilities':      return Icons.bolt_outlined;
      case 'Entertainment':  return Icons.movie_outlined;
      case 'Health':         return Icons.favorite_outline;
      case 'Shopping':       return Icons.shopping_bag_outlined;
      case 'Subscriptions':  return Icons.subscriptions_outlined;
      default:               return Icons.receipt_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Food & Dining':  return Colors.orange;
      case 'Grocery':        return Colors.green;
      case 'Transport':      return Colors.blue;
      case 'Housing':        return Colors.brown;
      case 'Utilities':      return Colors.yellow.shade700;
      case 'Entertainment':  return Colors.purple;
      case 'Health':         return Colors.red;
      case 'Shopping':       return Colors.pink;
      case 'Subscriptions':  return kTeal;
      default:               return Colors.grey;
    }
  }
}

// ─── Insight Banner ───────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
  final NumberFormat fmt;
  const _ExpenseTile({required this.expense, required this.fmt});

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: _categoryColor(expense.category).withOpacity(0.12),
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
                              style:
                                  TextStyle(color: Colors.grey.shade400)),
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
                              style:
                                  TextStyle(color: Colors.grey.shade400)),
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
                    '- ${fmt.format(expense.amount)}',
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
      case 'Food & Dining':    return Icons.restaurant_outlined;
      case 'Grocery':          return Icons.local_grocery_store_outlined;
      case 'Transport':        return Icons.directions_car_outlined;
      case 'Housing':          return Icons.home_outlined;
      case 'Utilities':        return Icons.bolt_outlined;
      case 'Entertainment':    return Icons.movie_outlined;
      case 'Health':           return Icons.favorite_outline;
      case 'Shopping':         return Icons.shopping_bag_outlined;
      case 'Subscriptions':    return Icons.subscriptions_outlined;
      default:                 return Icons.receipt_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Food & Dining':    return Colors.orange;
      case 'Grocery':          return Colors.green;
      case 'Transport':        return Colors.blue;
      case 'Housing':          return Colors.brown;
      case 'Utilities':        return Colors.yellow.shade700;
      case 'Entertainment':    return Colors.purple;
      case 'Health':           return Colors.red;
      case 'Shopping':         return Colors.pink;
      case 'Subscriptions':    return kTeal;
      default:                 return Colors.grey;
    }
  }
}
