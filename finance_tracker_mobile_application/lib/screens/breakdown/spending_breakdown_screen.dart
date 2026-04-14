import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/currency_provider.dart';
import '../../models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';

class SpendingBreakdownScreen extends ConsumerWidget {
  const SpendingBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final categoryTypes = ref.watch(categoryTypesProvider).value ?? kDefaultEssentialMap;
    final fmt = ref.watch(currencyFormatProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Spending Breakdown')),
      body: expensesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (expenses) {
          final now = DateTime.now();
          final thisMonth = expenses.where(
              (e) => e.date.month == now.month && e.date.year == now.year).toList();

          double essentialTotal = 0;
          double nonEssentialTotal = 0;
          final Map<String, double> categoryTotals = {};

          for (final e in thisMonth) {
            categoryTotals[e.category] =
                (categoryTotals[e.category] ?? 0) + e.amount;
            if (categoryTypes[e.category] ?? false) {
              essentialTotal += e.amount;
            } else {
              nonEssentialTotal += e.amount;
            }
          }

          final grandTotal = essentialTotal + nonEssentialTotal;
          final essentialFraction =
              grandTotal > 0 ? essentialTotal / grandTotal : 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Split summary card
              _SplitSummaryCard(
                essentialTotal: essentialTotal,
                nonEssentialTotal: nonEssentialTotal,
                essentialFraction: essentialFraction,
                fmt: fmt,
              ),
              const SizedBox(height: 20),

              // Essential section
              _SectionHeader(
                  label: 'Essentials',
                  total: essentialTotal,
                  color: kTeal,
                  fmt: fmt),
              const SizedBox(height: 8),
              ...kExpenseCategories
                  .where((c) => categoryTypes[c] == true)
                  .map((c) => _CategoryRow(
                        category: c,
                        amount: categoryTotals[c] ?? 0,
                        isEssential: true,
                        grandTotal: grandTotal,
                        onToggle: () => _toggle(context, ref, c, false),
                        fmt: fmt,
                      )),

              const SizedBox(height: 20),

              // Non-essential section
              _SectionHeader(
                  label: 'Non-Essentials',
                  total: nonEssentialTotal,
                  color: Colors.orange,
                  fmt: fmt),
              const SizedBox(height: 8),
              ...kExpenseCategories
                  .where((c) => categoryTypes[c] == false)
                  .map((c) => _CategoryRow(
                        category: c,
                        amount: categoryTotals[c] ?? 0,
                        isEssential: false,
                        grandTotal: grandTotal,
                        onToggle: () => _toggle(context, ref, c, true),
                        fmt: fmt,
                      )),

              const SizedBox(height: 16),
              Text(
                'Tap a category to move it between sections.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggle(
      BuildContext context, WidgetRef ref, String category, bool makeEssential) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref
        .read(categoryServiceProvider)
        .setCategoryType(user.uid, category, makeEssential);
  }
}

class _SplitSummaryCard extends StatelessWidget {
  final double essentialTotal;
  final double nonEssentialTotal;
  final double essentialFraction;
  final NumberFormat fmt;

  const _SplitSummaryCard({
    required this.essentialTotal,
    required this.nonEssentialTotal,
    required this.essentialFraction,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This Month',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          // Split bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Flexible(
                  flex: (essentialFraction * 100).round().clamp(1, 99),
                  child: Container(height: 14, color: kTeal),
                ),
                Flexible(
                  flex:
                      ((1 - essentialFraction) * 100).round().clamp(1, 99),
                  child:
                      Container(height: 14, color: Colors.orange.shade300),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  color: kTeal,
                  label: 'Essentials',
                  amount: essentialTotal,
                  percent: essentialFraction,
                  fmt: fmt,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  color: Colors.orange,
                  label: 'Non-Essentials',
                  amount: nonEssentialTotal,
                  percent: 1 - essentialFraction,
                  alignRight: true,
                  fmt: fmt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;
  final double percent;
  final bool alignRight;
  final NumberFormat fmt;

  const _SummaryItem({
    required this.color,
    required this.label,
    required this.amount,
    required this.percent,
    required this.fmt,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
                width: 10, height: 10, color: color,
                margin: EdgeInsets.only(
                    right: alignRight ? 0 : 6, left: alignRight ? 6 : 0)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(fmt.format(amount),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color)),
        Text('${(percent * 100).toStringAsFixed(0)}%',
            style:
                const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final double total;
  final Color color;
  final NumberFormat fmt;

  const _SectionHeader(
      {required this.label, required this.total, required this.color, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.grey.shade800)),
          ],
        ),
        Text(fmt.format(total),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color)),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final bool isEssential;
  final double grandTotal;
  final VoidCallback onToggle;
  final NumberFormat fmt;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.isEssential,
    required this.grandTotal,
    required this.onToggle,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = grandTotal > 0 ? (amount / grandTotal).clamp(0.0, 1.0) : 0.0;
    final color = isEssential ? kTeal : Colors.orange;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(category,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                ),
                Text(
                  amount > 0 ? fmt.format(amount) : '—',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: amount > 0 ? Colors.black87 : Colors.grey),
                ),
                const SizedBox(width: 8),
                Icon(
                  isEssential
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            if (amount > 0) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 4,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      color.withOpacity(0.6)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
