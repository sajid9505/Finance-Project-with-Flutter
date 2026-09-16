import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_mobile_application/models/budget.dart';

void main() {
  // ─── Budget.fromFirestore ─────────────────────────────────────────────────

  group('Budget.fromFirestore', () {
    test('parses period and categoryBudgets', () {
      final b = Budget.fromFirestore({
        'period': 'weekly',
        'categoryBudgets': {'Food & Dining': 500.0, 'Grocery': 800.0},
      });
      expect(b.period, 'weekly');
      expect(b.categoryBudgets['Food & Dining'], 500.0);
      expect(b.categoryBudgets['Grocery'], 800.0);
    });

    test('defaults period to monthly when absent', () {
      final b = Budget.fromFirestore({});
      expect(b.period, 'monthly');
    });

    test('defaults categoryBudgets to empty when absent', () {
      final b = Budget.fromFirestore({'period': 'monthly'});
      expect(b.categoryBudgets, isEmpty);
    });

    test('converts integer budget values to double', () {
      final b = Budget.fromFirestore({
        'period': 'monthly',
        'categoryBudgets': {'Transport': 300},
      });
      expect(b.categoryBudgets['Transport'], isA<double>());
      expect(b.categoryBudgets['Transport'], 300.0);
    });

    test('handles multiple category budgets', () {
      final b = Budget.fromFirestore({
        'period': 'monthly',
        'categoryBudgets': {
          'Grocery': 5000.0,
          'Transport': 2000.0,
          'Health': 1000.0,
        },
      });
      expect(b.categoryBudgets.length, 3);
      expect(b.categoryBudgets['Health'], 1000.0);
    });
  });

  // ─── Budget.toFirestore ───────────────────────────────────────────────────

  group('Budget.toFirestore', () {
    test('serializes period and categoryBudgets', () {
      const b = Budget(
        period: 'monthly',
        categoryBudgets: {'Food & Dining': 1000.0},
      );
      final m = b.toFirestore();
      expect(m['period'], 'monthly');
      expect((m['categoryBudgets'] as Map)['Food & Dining'], 1000.0);
    });

    test('serializes empty budgets', () {
      const b = Budget(period: 'weekly');
      final m = b.toFirestore();
      expect(m['period'], 'weekly');
      expect(m['categoryBudgets'], isEmpty);
    });

    test('round-trips toFirestore → fromFirestore', () {
      const original = Budget(
        period: 'monthly',
        categoryBudgets: {'Grocery': 3000.0, 'Transport': 1500.0},
      );
      final roundTripped = Budget.fromFirestore(original.toFirestore());
      expect(roundTripped.period, original.period);
      expect(roundTripped.categoryBudgets, original.categoryBudgets);
    });
  });

  // ─── Budget.hasCategoryBudgets ────────────────────────────────────────────

  group('Budget.hasCategoryBudgets', () {
    test('false when no categories set', () {
      const b = Budget(period: 'monthly');
      expect(b.hasCategoryBudgets, false);
    });

    test('true when at least one category set', () {
      const b = Budget(period: 'monthly', categoryBudgets: {'Grocery': 500.0});
      expect(b.hasCategoryBudgets, true);
    });
  });

  // ─── Budget.copyWith ──────────────────────────────────────────────────────

  group('Budget.copyWith', () {
    test('overrides period', () {
      const b = Budget(period: 'monthly');
      expect(b.copyWith(period: 'weekly').period, 'weekly');
    });

    test('overrides categoryBudgets', () {
      const b = Budget(
        period: 'monthly',
        categoryBudgets: {'Grocery': 500.0},
      );
      final c = b.copyWith(categoryBudgets: {'Transport': 300.0});
      expect(c.categoryBudgets, {'Transport': 300.0});
      expect(c.categoryBudgets.containsKey('Grocery'), false);
    });

    test('preserves unchanged fields when called with no args', () {
      const b = Budget(
        period: 'weekly',
        categoryBudgets: {'Health': 200.0},
      );
      final c = b.copyWith();
      expect(c.period, 'weekly');
      expect(c.categoryBudgets['Health'], 200.0);
    });
  });
}
