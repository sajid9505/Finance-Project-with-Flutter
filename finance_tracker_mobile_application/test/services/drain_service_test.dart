import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_mobile_application/models/expense.dart';
import 'package:finance_tracker_mobile_application/services/drain_service.dart';

Expense _expense({
  required String id,
  required double amount,
  required String? interval,
}) {
  final now = DateTime.now();
  return Expense(
    id: id,
    amount: amount,
    category: 'Other',
    description: 'Test',
    date: now,
    isRecurring: true,
    recurrenceInterval: interval,
    createdAt: now,
  );
}

void main() {
  // ─── DrainService.toMonthlyAmount ─────────────────────────────────────────

  group('DrainService.toMonthlyAmount', () {
    test('monthly: amount unchanged', () {
      expect(DrainService.toMonthlyAmount(_expense(id: '1', amount: 500.0, interval: 'monthly')), 500.0);
    });

    test('weekly: amount × 52 / 12', () {
      expect(
        DrainService.toMonthlyAmount(_expense(id: '2', amount: 100.0, interval: 'weekly')),
        closeTo(100.0 * 52 / 12, 0.001),
      );
    });

    test('fortnightly: amount × 26 / 12', () {
      expect(
        DrainService.toMonthlyAmount(_expense(id: '3', amount: 200.0, interval: 'fortnightly')),
        closeTo(200.0 * 26 / 12, 0.001),
      );
    });

    test('null interval treated as monthly', () {
      expect(DrainService.toMonthlyAmount(_expense(id: '4', amount: 300.0, interval: null)), 300.0);
    });

    test('unknown interval treated as monthly', () {
      expect(DrainService.toMonthlyAmount(_expense(id: '5', amount: 400.0, interval: 'quarterly')), 400.0);
    });

    test('zero amount stays zero for all intervals', () {
      expect(DrainService.toMonthlyAmount(_expense(id: 'z1', amount: 0.0, interval: 'weekly')), 0.0);
      expect(DrainService.toMonthlyAmount(_expense(id: 'z2', amount: 0.0, interval: 'fortnightly')), 0.0);
      expect(DrainService.toMonthlyAmount(_expense(id: 'z3', amount: 0.0, interval: 'monthly')), 0.0);
    });

    test('weekly is more than monthly for same base amount', () {
      final monthly = DrainService.toMonthlyAmount(_expense(id: 'm', amount: 1000.0, interval: 'monthly'));
      final weekly = DrainService.toMonthlyAmount(_expense(id: 'w', amount: 1000.0, interval: 'weekly'));
      expect(weekly, greaterThan(monthly));
    });

    test('weekly is more than fortnightly for same base amount', () {
      final weekly = DrainService.toMonthlyAmount(_expense(id: 'w', amount: 500.0, interval: 'weekly'));
      final fortnightly = DrainService.toMonthlyAmount(_expense(id: 'f', amount: 500.0, interval: 'fortnightly'));
      expect(weekly, greaterThan(fortnightly));
    });
  });

  // ─── DrainService.totalMonthlyCost ────────────────────────────────────────

  group('DrainService.totalMonthlyCost', () {
    test('returns 0 for an empty list', () {
      expect(DrainService.totalMonthlyCost([]), 0.0);
    });

    test('sums monthly equivalents for a single expense', () {
      expect(DrainService.totalMonthlyCost([
        _expense(id: '1', amount: 1000.0, interval: 'monthly'),
      ]), 1000.0);
    });

    test('sums two monthly expenses', () {
      expect(DrainService.totalMonthlyCost([
        _expense(id: '1', amount: 1000.0, interval: 'monthly'),
        _expense(id: '2', amount: 500.0, interval: 'monthly'),
      ]), 1500.0);
    });

    test('converts weekly before summing', () {
      final total = DrainService.totalMonthlyCost([
        _expense(id: '1', amount: 100.0, interval: 'weekly'),
        _expense(id: '2', amount: 200.0, interval: 'fortnightly'),
      ]);
      expect(total, closeTo((100.0 * 52 / 12) + (200.0 * 26 / 12), 0.01));
    });

    test('mixes all three intervals correctly', () {
      final total = DrainService.totalMonthlyCost([
        _expense(id: '1', amount: 1000.0, interval: 'monthly'),
        _expense(id: '2', amount: 50.0, interval: 'weekly'),
        _expense(id: '3', amount: 300.0, interval: 'fortnightly'),
      ]);
      final expected = 1000.0 + (50.0 * 52 / 12) + (300.0 * 26 / 12);
      expect(total, closeTo(expected, 0.01));
    });
  });
}
