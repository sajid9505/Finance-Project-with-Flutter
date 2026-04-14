import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/currency_provider.dart';
import '../../models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/split_provider.dart';

class SplitsScreen extends ConsumerWidget {
  const SplitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outstanding = ref.watch(outstandingSplitsProvider);
    final total = ref.watch(totalOutstandingProvider);
    final fmt = ref.watch(currencyFormatProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Bill Splits')),
      body: outstanding.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No outstanding splits',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Everyone is settled up!',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Outstanding',
                              style: TextStyle(
                                  color: Colors.blue.shade700, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            fmt.format(total),
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.account_balance_wallet_outlined,
                          size: 40, color: Colors.blue.shade400),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: outstanding.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _SplitExpenseCard(split: outstanding[i]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SplitExpenseCard extends ConsumerWidget {
  final OutstandingSplit split;
  const _SplitExpenseCard({required this.split});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = split.expense;
    final fmt = ref.watch(currencyFormatProvider);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(expense.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Text(
                  fmt.format(split.totalOwed),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${expense.category} · Total: ${fmt.format(expense.amount)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 20),
            ...expense.splits.map((person) => _PersonRow(
                  person: person,
                  expense: expense,
                  ref: ref,
                  fmt: fmt,
                )),
          ],
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final SplitPerson person;
  final Expense expense;
  final WidgetRef ref;
  final NumberFormat fmt;

  const _PersonRow({
    required this.person,
    required this.expense,
    required this.ref,
    required this.fmt,
  });

  Future<void> _toggleSettled(BuildContext context) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final updatedSplits = expense.splits.map((s) {
      if (s.name == person.name) return s.copyWith(settled: !s.settled);
      return s;
    }).toList();

    final updatedExpense = Expense(
      id: expense.id,
      amount: expense.amount,
      category: expense.category,
      description: expense.description,
      date: expense.date,
      isRecurring: expense.isRecurring,
      recurrenceInterval: expense.recurrenceInterval,
      createdAt: expense.createdAt,
      isSplit: expense.isSplit,
      splits: updatedSplits,
    );

    await ref.read(expenseServiceProvider).updateExpense(user.uid, updatedExpense);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: person.settled
                ? Colors.green.shade100
                : Colors.blue.shade100,
            child: Text(
              person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: person.settled
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  person.settled ? 'Settled' : 'Owes ${fmt.format(person.amount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: person.settled ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _toggleSettled(context),
            style: TextButton.styleFrom(
              foregroundColor: person.settled ? Colors.grey : Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(person.settled ? 'Unsettle' : 'Mark Settled'),
          ),
        ],
      ),
    );
  }
}
