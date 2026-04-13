import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/budget.dart';
import '../../models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';

class BudgetSettingsScreen extends ConsumerStatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  ConsumerState<BudgetSettingsScreen> createState() =>
      _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends ConsumerState<BudgetSettingsScreen> {
  String _period = 'monthly';
  final Map<String, TextEditingController> _catControllers = {
    for (final c in kExpenseCategories) c: TextEditingController(),
  };
  bool _loaded = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _catControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadExisting(Budget? budget) {
    if (_loaded || budget == null) return;
    _period = budget.period;
    for (final entry in budget.categoryBudgets.entries) {
      _catControllers[entry.key]?.text =
          entry.value > 0 ? entry.value.toStringAsFixed(2) : '';
    }
    setState(() {});
    _loaded = true;
  }

  Future<void> _save() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final categoryBudgets = <String, double>{};
      for (final entry in _catControllers.entries) {
        final v = double.tryParse(entry.value.text.trim()) ?? 0;
        if (v > 0) categoryBudgets[entry.key] = v;
      }

      final budget = Budget(
        period: _period,
        categoryBudgets: categoryBudgets,
      );
      await ref.read(budgetServiceProvider).setBudget(user.uid, budget);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(budgetProvider).whenData(_loadExisting);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Budget Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          // ── Period selector ──────────────────────────────────────────
          const Text('Budget Period',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            'All category budgets reset at the start of each $_period period.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PeriodChip(
                label: 'Monthly',
                selected: _period == 'monthly',
                onTap: () => setState(() => _period = 'monthly'),
              ),
              const SizedBox(width: 10),
              _PeriodChip(
                label: 'Weekly',
                selected: _period == 'weekly',
                onTap: () => setState(() => _period = 'weekly'),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Category limits ──────────────────────────────────────────
          const Text('Category Limits',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            'Set a budget for any category. Non-essential categories (e.g. Dining, Entertainment, Shopping) will also show a daily allowance on the dashboard. Essential categories like Grocery and Housing are tracked by period total only.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),

          ...kExpenseCategories.map((category) {
            final controller = _catControllers[category]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          _categoryColor(category).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_categoryIcon(category),
                        color: _categoryColor(category), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      decoration: InputDecoration(
                        labelText: category,
                        border: const OutlineInputBorder(),
                        prefixText: '\$',
                        isDense: true,
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  controller.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Budget'),
            ),
          ),
        ),
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

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? kTeal : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
