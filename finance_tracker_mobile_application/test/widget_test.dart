import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_mobile_application/models/expense.dart';
import 'package:finance_tracker_mobile_application/models/budget.dart';

// Helper: wraps a widget in a minimal MaterialApp for testing
Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  // ─── Expense category list widget ─────────────────────────────────────────

  group('kExpenseCategories ListView', () {
    testWidgets('renders all 10 category names', (tester) async {
      await tester.pumpWidget(_wrap(
        ListView(
          children: kExpenseCategories
              .map((c) => ListTile(title: Text(c)))
              .toList(),
        ),
      ));

      for (final category in kExpenseCategories) {
        expect(find.text(category), findsOneWidget,
            reason: '$category should appear in the list');
      }
    });
  });

  // ─── SplitPerson chip display ──────────────────────────────────────────────

  group('SplitPerson display widget', () {
    testWidgets('shows unsettled person name and amount', (tester) async {
      final person = SplitPerson(name: 'Alice', amount: 300.0, settled: false);
      await tester.pumpWidget(_wrap(
        Row(children: [
          Text(person.name),
          Text(person.amount.toStringAsFixed(2)),
          if (!person.settled) const Icon(Icons.pending),
        ]),
      ));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('300.00'), findsOneWidget);
      expect(find.byIcon(Icons.pending), findsOneWidget);
    });

    testWidgets('settled person shows check icon instead of pending', (tester) async {
      final person = SplitPerson(name: 'Bob', amount: 150.0, settled: true);
      await tester.pumpWidget(_wrap(
        Row(children: [
          Text(person.name),
          if (person.settled)
            const Icon(Icons.check_circle)
          else
            const Icon(Icons.pending),
        ]),
      ));

      expect(find.text('Bob'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.pending), findsNothing);
    });
  });

  // ─── Budget period label ───────────────────────────────────────────────────

  group('Budget period label widget', () {
    testWidgets('shows "Monthly Budget" for monthly period', (tester) async {
      const budget = Budget(period: 'monthly', categoryBudgets: {'Grocery': 5000.0});
      final label = '${budget.period[0].toUpperCase()}${budget.period.substring(1)} Budget';

      await tester.pumpWidget(_wrap(Text(label)));
      expect(find.text('Monthly Budget'), findsOneWidget);
    });

    testWidgets('shows "Weekly Budget" for weekly period', (tester) async {
      const budget = Budget(period: 'weekly');
      final label = '${budget.period[0].toUpperCase()}${budget.period.substring(1)} Budget';

      await tester.pumpWidget(_wrap(Text(label)));
      expect(find.text('Weekly Budget'), findsOneWidget);
    });

    testWidgets('budget with no categories shows empty state text', (tester) async {
      const budget = Budget(period: 'monthly');
      await tester.pumpWidget(_wrap(
        budget.hasCategoryBudgets
            ? const Text('Has budgets')
            : const Text('No category limits set'),
      ));
      expect(find.text('No category limits set'), findsOneWidget);
    });

    testWidgets('budget with categories does not show empty state', (tester) async {
      const budget = Budget(period: 'monthly', categoryBudgets: {'Grocery': 3000.0});
      await tester.pumpWidget(_wrap(
        budget.hasCategoryBudgets
            ? const Text('Has budgets')
            : const Text('No category limits set'),
      ));
      expect(find.text('Has budgets'), findsOneWidget);
      expect(find.text('No category limits set'), findsNothing);
    });
  });

  // ─── Expense split total display ──────────────────────────────────────────

  group('Expense totalOwed display', () {
    testWidgets('shows correct owed amount for unsettled splits', (tester) async {
      final now = DateTime.now();
      final expense = Expense(
        id: 'e1',
        amount: 1000.0,
        category: 'Food & Dining',
        description: 'Group dinner',
        date: now,
        createdAt: now,
        isSplit: true,
        splits: [
          SplitPerson(name: 'Alice', amount: 300.0, settled: false),
          SplitPerson(name: 'Bob', amount: 200.0, settled: true),
        ],
      );

      await tester.pumpWidget(_wrap(
        Text('Owed: BDT ${expense.totalOwed.toStringAsFixed(2)}'),
      ));

      expect(find.text('Owed: BDT 300.00'), findsOneWidget);
    });

    testWidgets('shows zero when all splits settled', (tester) async {
      final now = DateTime.now();
      final expense = Expense(
        id: 'e2',
        amount: 500.0,
        category: 'Food & Dining',
        description: 'Lunch',
        date: now,
        createdAt: now,
        isSplit: true,
        splits: [SplitPerson(name: 'Charlie', amount: 500.0, settled: true)],
      );

      await tester.pumpWidget(_wrap(
        expense.totalOwed > 0
            ? Text('Owed: BDT ${expense.totalOwed.toStringAsFixed(2)}')
            : const Text('All settled'),
      ));

      expect(find.text('All settled'), findsOneWidget);
    });
  });
}
