import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_mobile_application/models/expense.dart';
import 'package:finance_tracker_mobile_application/services/forecast_service.dart';

Expense _recurring({
  required String id,
  required double amount,
  required String? interval,
  String description = 'Test',
  String category = 'Subscriptions',
}) {
  final now = DateTime.now();
  return Expense(
    id: id,
    amount: amount,
    category: category,
    description: description,
    date: now,
    isRecurring: true,
    recurrenceInterval: interval,
    createdAt: now,
  );
}

Expense _oneOff({required String id, required double amount}) {
  final now = DateTime.now();
  return Expense(
    id: id,
    amount: amount,
    category: 'Other',
    description: 'One-off',
    date: now,
    isRecurring: false,
    createdAt: now,
  );
}

void main() {
  final service = ForecastService();

  // ─── forecast() shape ────────────────────────────────────────────────────

  group('ForecastService.forecast – structure', () {
    test('always returns exactly 3 months', () {
      expect(service.forecast([]).length, 3);
    });

    test('first month is the next calendar month', () {
      final now = DateTime.now();
      final expected = DateTime(now.year, now.month + 1, 1);
      expect(service.forecast([]).first.month, expected);
    });

    test('months are on the 1st of consecutive months', () {
      final months = service.forecast([]).map((f) => f.month).toList();
      for (int i = 0; i < 2; i++) {
        expect(months[i + 1].isAfter(months[i]), true);
        expect(months[i].day, 1);
      }
    });
  });

  // ─── expense filtering ────────────────────────────────────────────────────

  group('ForecastService.forecast – expense filtering', () {
    test('non-recurring expenses are excluded', () {
      final forecasts = service.forecast([
        _oneOff(id: 'o1', amount: 5000.0),
        _oneOff(id: 'o2', amount: 3000.0),
      ]);
      for (final f in forecasts) {
        expect(f.entries, isEmpty);
        expect(f.total, 0.0);
      }
    });

    test('recurring expenses appear in all 3 months', () {
      final forecasts = service.forecast([
        _recurring(id: 'r1', amount: 1000.0, interval: 'monthly'),
      ]);
      for (final f in forecasts) {
        expect(f.entries.length, 1);
      }
    });

    test('mix of recurring and one-off: only recurring included', () {
      final forecasts = service.forecast([
        _oneOff(id: 'o1', amount: 9999.0),
        _recurring(id: 'r1', amount: 500.0, interval: 'monthly'),
      ]);
      for (final f in forecasts) {
        expect(f.entries.length, 1);
        expect(f.entries.first.amount, 500.0);
      }
    });
  });

  // ─── amount conversion ───────────────────────────────────────────────────

  group('ForecastService.forecast – amount conversion', () {
    test('monthly expense: amount unchanged', () {
      final entry = service.forecast([
        _recurring(id: 'r1', amount: 1000.0, interval: 'monthly'),
      ]).first.entries.first;
      expect(entry.amount, 1000.0);
    });

    test('weekly expense: amount × 52 / 12', () {
      final entry = service.forecast([
        _recurring(id: 'r1', amount: 100.0, interval: 'weekly'),
      ]).first.entries.first;
      expect(entry.amount, closeTo(100.0 * 52 / 12, 0.001));
    });

    test('fortnightly expense: amount × 26 / 12', () {
      final entry = service.forecast([
        _recurring(id: 'r1', amount: 200.0, interval: 'fortnightly'),
      ]).first.entries.first;
      expect(entry.amount, closeTo(200.0 * 26 / 12, 0.001));
    });

    test('null interval treated as monthly', () {
      final entry = service.forecast([
        _recurring(id: 'r1', amount: 500.0, interval: null),
      ]).first.entries.first;
      expect(entry.amount, 500.0);
    });
  });

  // ─── sorting and totals ──────────────────────────────────────────────────

  group('ForecastService.forecast – sorting and totals', () {
    test('entries sorted descending by amount', () {
      final amounts = service.forecast([
        _recurring(id: 'r1', amount: 300.0, interval: 'monthly'),
        _recurring(id: 'r2', amount: 1000.0, interval: 'monthly'),
        _recurring(id: 'r3', amount: 150.0, interval: 'monthly'),
      ]).first.entries.map((e) => e.amount).toList();
      expect(amounts, [1000.0, 300.0, 150.0]);
    });

    test('MonthForecast.total is the sum of entry amounts', () {
      final forecast = service.forecast([
        _recurring(id: 'r1', amount: 1000.0, interval: 'monthly'),
        _recurring(id: 'r2', amount: 500.0, interval: 'monthly'),
      ]).first;
      expect(forecast.total, 1500.0);
    });

    test('total is 0 when no recurring expenses', () {
      expect(service.forecast([]).first.total, 0.0);
    });
  });

  // ─── ForecastEntry fields ────────────────────────────────────────────────

  group('ForecastEntry fields', () {
    test('carries correct description and category', () {
      final entry = service.forecast([
        _recurring(
          id: 'r1', amount: 800.0, interval: 'monthly',
          description: 'Spotify', category: 'Subscriptions',
        ),
      ]).first.entries.first;
      expect(entry.description, 'Spotify');
      expect(entry.category, 'Subscriptions');
    });

    test('carries recurrenceInterval from expense', () {
      final entry = service.forecast([
        _recurring(id: 'r1', amount: 200.0, interval: 'weekly'),
      ]).first.entries.first;
      expect(entry.recurrenceInterval, 'weekly');
    });

    test('null interval produces "monthly" in entry', () {
      final entry = service.forecast([
        _recurring(id: 'r1', amount: 200.0, interval: null),
      ]).first.entries.first;
      expect(entry.recurrenceInterval, 'monthly');
    });
  });
}
