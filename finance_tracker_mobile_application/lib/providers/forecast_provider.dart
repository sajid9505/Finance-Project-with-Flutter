import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/forecast_service.dart';
import 'expense_provider.dart';

final forecastServiceProvider = Provider<ForecastService>((ref) => ForecastService());

final forecastProvider = Provider<List<MonthForecast>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  return ref.read(forecastServiceProvider).forecast(expenses);
});
