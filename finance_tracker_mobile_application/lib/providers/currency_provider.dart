import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/currency_service.dart';
import 'auth_provider.dart';

final currencyServiceProvider =
    Provider<CurrencyService>((ref) => CurrencyService());

/// Emits the user's chosen currency symbol (e.g. '$', '৳')
final currencySymbolProvider = StreamProvider<String>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value('\$');
  return ref.read(currencyServiceProvider).watchCurrencySymbol(user.uid);
});

/// A NumberFormat built from the user's currency symbol
final currencyFormatProvider = Provider<NumberFormat>((ref) {
  final symbol = ref.watch(currencySymbolProvider).value ?? '\$';
  return NumberFormat.currency(symbol: symbol);
});
