import '../models/expense.dart';

class MonthForecast {
  final DateTime month; // first day of the month
  final List<ForecastEntry> entries;

  MonthForecast({required this.month, required this.entries});

  double get total => entries.fold(0.0, (sum, e) => sum + e.amount);
}

class ForecastEntry {
  final String description;
  final String category;
  final double amount;
  final String recurrenceInterval;

  ForecastEntry({
    required this.description,
    required this.category,
    required this.amount,
    required this.recurrenceInterval,
  });
}

class ForecastService {
  /// Projects the next 3 months of spending based on recurring expenses.
  /// Each recurring expense is converted to its monthly equivalent amount.
  List<MonthForecast> forecast(List<Expense> allExpenses) {
    final recurring = allExpenses.where((e) => e.isRecurring).toList();
    final now = DateTime.now();

    return List.generate(3, (i) {
      final month = DateTime(now.year, now.month + i + 1, 1);
      final entries = recurring.map((e) {
        return ForecastEntry(
          description: e.description,
          category: e.category,
          amount: _toMonthlyAmount(e),
          recurrenceInterval: e.recurrenceInterval ?? 'monthly',
        );
      }).toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      return MonthForecast(month: month, entries: entries);
    });
  }

  static double _toMonthlyAmount(Expense e) {
    switch (e.recurrenceInterval) {
      case 'weekly':
        return e.amount * 52 / 12;
      case 'fortnightly':
        return e.amount * 26 / 12;
      case 'monthly':
      default:
        return e.amount;
    }
  }
}
