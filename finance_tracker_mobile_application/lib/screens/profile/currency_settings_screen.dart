import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/currency_service.dart';

class CurrencySettingsScreen extends ConsumerWidget {
  const CurrencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSymbol = ref.watch(currencySymbolProvider).value ?? '\$';

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Currency')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kSupportedCurrencies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final currency = kSupportedCurrencies[i];
          final symbol = currency['symbol']!;
          final isSelected = symbol == currentSymbol;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _select(context, ref, symbol, currency['code']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? kTeal : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kTeal.withValues(alpha: 0.12)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? kTeal : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency['label']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currency['code']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: kTeal, size: 22),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _select(
      BuildContext context, WidgetRef ref, String symbol, String code) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref
        .read(currencyServiceProvider)
        .setCurrency(user.uid, symbol, code);
    if (context.mounted) Navigator.pop(context);
  }
}
