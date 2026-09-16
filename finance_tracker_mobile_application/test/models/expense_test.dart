import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_mobile_application/models/expense.dart';

void main() {
  // ─── SplitPerson ───────────────────────────────────────────────────────────

  group('SplitPerson.toMap', () {
    test('serializes name, amount, and settled', () {
      final p = SplitPerson(name: 'Alice', amount: 500.0, settled: true);
      expect(p.toMap(), {'name': 'Alice', 'amount': 500.0, 'settled': true});
    });

    test('default settled is false', () {
      final p = SplitPerson(name: 'Bob', amount: 200.0);
      expect(p.toMap()['settled'], false);
    });
  });

  group('SplitPerson.fromMap', () {
    test('parses all fields', () {
      final p = SplitPerson.fromMap({'name': 'Charlie', 'amount': 350.0, 'settled': true});
      expect(p.name, 'Charlie');
      expect(p.amount, 350.0);
      expect(p.settled, true);
    });

    test('defaults settled to false when absent', () {
      final p = SplitPerson.fromMap({'name': 'Dave', 'amount': 100.0});
      expect(p.settled, false);
    });

    test('converts integer amount to double', () {
      final p = SplitPerson.fromMap({'name': 'Eve', 'amount': 250, 'settled': false});
      expect(p.amount, isA<double>());
      expect(p.amount, 250.0);
    });

    test('round-trips toMap → fromMap', () {
      final original = SplitPerson(name: 'Frank', amount: 600.0, settled: true);
      final copy = SplitPerson.fromMap(original.toMap());
      expect(copy.name, original.name);
      expect(copy.amount, original.amount);
      expect(copy.settled, original.settled);
    });
  });

  group('SplitPerson.copyWith', () {
    test('overrides specified fields', () {
      final p = SplitPerson(name: 'Grace', amount: 400.0, settled: false);
      final c = p.copyWith(settled: true, amount: 200.0);
      expect(c.name, 'Grace');
      expect(c.amount, 200.0);
      expect(c.settled, true);
    });

    test('preserves unspecified fields', () {
      final p = SplitPerson(name: 'Hank', amount: 700.0, settled: true);
      final c = p.copyWith(name: 'Ivy');
      expect(c.amount, 700.0);
      expect(c.settled, true);
    });
  });

  // ─── Expense.totalOwed ────────────────────────────────────────────────────

  group('Expense.totalOwed', () {
    final now = DateTime.now();

    test('sums all unsettled splits', () {
      final e = Expense(
        id: '1', amount: 1000.0, category: 'Food & Dining',
        description: 'Dinner', date: now, createdAt: now, isSplit: true,
        splits: [
          SplitPerson(name: 'A', amount: 300.0, settled: false),
          SplitPerson(name: 'B', amount: 200.0, settled: false),
        ],
      );
      expect(e.totalOwed, 500.0);
    });

    test('excludes settled splits from sum', () {
      final e = Expense(
        id: '2', amount: 1000.0, category: 'Food & Dining',
        description: 'Dinner', date: now, createdAt: now, isSplit: true,
        splits: [
          SplitPerson(name: 'A', amount: 300.0, settled: true),
          SplitPerson(name: 'B', amount: 200.0, settled: false),
        ],
      );
      expect(e.totalOwed, 200.0);
    });

    test('returns 0 when all splits are settled', () {
      final e = Expense(
        id: '3', amount: 500.0, category: 'Food & Dining',
        description: 'Lunch', date: now, createdAt: now, isSplit: true,
        splits: [SplitPerson(name: 'A', amount: 250.0, settled: true)],
      );
      expect(e.totalOwed, 0.0);
    });

    test('returns 0 when there are no splits', () {
      final e = Expense(
        id: '4', amount: 500.0, category: 'Grocery',
        description: 'Supermarket', date: now, createdAt: now,
      );
      expect(e.totalOwed, 0.0);
    });
  });

  // ─── Expense.toFirestore ─────────────────────────────────────────────────

  group('Expense.toFirestore', () {
    final date = DateTime(2025, 6, 15, 12, 0);
    final createdAt = DateTime(2025, 6, 10);

    test('serializes scalar fields', () {
      final e = Expense(
        id: 'abc', amount: 1200.0, category: 'Shopping',
        description: 'Clothes', date: date, createdAt: createdAt,
      );
      final m = e.toFirestore();
      expect(m['amount'], 1200.0);
      expect(m['category'], 'Shopping');
      expect(m['description'], 'Clothes');
      expect(m['isRecurring'], false);
      expect(m['isSplit'], false);
      expect(m['recurrenceInterval'], isNull);
    });

    test('date and createdAt are stored as Timestamps', () {
      final e = Expense(
        id: 'abc', amount: 100.0, category: 'Other',
        description: 'Test', date: date, createdAt: createdAt,
      );
      final m = e.toFirestore();
      expect(m['date'], isA<Timestamp>());
      expect(m['createdAt'], isA<Timestamp>());
    });

    test('Timestamp preserves the original date value', () {
      final e = Expense(
        id: 'abc', amount: 100.0, category: 'Other',
        description: 'Test', date: date, createdAt: createdAt,
      );
      final m = e.toFirestore();
      expect((m['date'] as Timestamp).toDate(), date);
      expect((m['createdAt'] as Timestamp).toDate(), createdAt);
    });

    test('splits are serialized to list of maps', () {
      final e = Expense(
        id: 's1', amount: 600.0, category: 'Food & Dining',
        description: 'Dinner', date: date, createdAt: createdAt, isSplit: true,
        splits: [SplitPerson(name: 'Alice', amount: 300.0, settled: false)],
      );
      final m = e.toFirestore();
      expect(m['isSplit'], true);
      final splits = m['splits'] as List;
      expect(splits.length, 1);
      expect(splits.first['name'], 'Alice');
      expect(splits.first['amount'], 300.0);
    });

    test('recurring expense serializes interval', () {
      final e = Expense(
        id: 'r1', amount: 800.0, category: 'Subscriptions',
        description: 'Netflix', date: date, createdAt: createdAt,
        isRecurring: true, recurrenceInterval: 'monthly',
      );
      final m = e.toFirestore();
      expect(m['isRecurring'], true);
      expect(m['recurrenceInterval'], 'monthly');
    });

    test('empty splits list is stored as empty list', () {
      final e = Expense(
        id: 'x1', amount: 50.0, category: 'Other',
        description: 'Misc', date: date, createdAt: createdAt,
      );
      expect(e.toFirestore()['splits'], isEmpty);
    });
  });

  // ─── kExpenseCategories ──────────────────────────────────────────────────

  group('kExpenseCategories', () {
    test('has exactly 10 categories', () {
      expect(kExpenseCategories.length, 10);
    });

    test('contains all expected categories', () {
      expect(kExpenseCategories, containsAll([
        'Food & Dining', 'Grocery', 'Transport', 'Housing', 'Utilities',
        'Entertainment', 'Health', 'Shopping', 'Subscriptions', 'Other',
      ]));
    });

    test('has no duplicates', () {
      expect(kExpenseCategories.toSet().length, kExpenseCategories.length);
    });
  });

  // ─── kDefaultEssentialMap ────────────────────────────────────────────────

  group('kDefaultEssentialMap', () {
    test('essential categories are true', () {
      for (final cat in ['Grocery', 'Transport', 'Housing', 'Utilities', 'Health']) {
        expect(kDefaultEssentialMap[cat], true, reason: '$cat should be essential');
      }
    });

    test('non-essential categories are false', () {
      for (final cat in ['Food & Dining', 'Entertainment', 'Shopping', 'Subscriptions', 'Other']) {
        expect(kDefaultEssentialMap[cat], false, reason: '$cat should be non-essential');
      }
    });

    test('every category in kExpenseCategories has an entry', () {
      for (final cat in kExpenseCategories) {
        expect(kDefaultEssentialMap.containsKey(cat), true,
            reason: '$cat missing from kDefaultEssentialMap');
      }
    });
  });
}
