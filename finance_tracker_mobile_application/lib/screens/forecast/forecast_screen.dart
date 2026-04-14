import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/currency_provider.dart';
import '../../providers/forecast_provider.dart';
import '../../services/forecast_service.dart';

class ForecastScreen extends ConsumerWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(forecastProvider);
    final fmt = ref.watch(currencyFormatProvider);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Spending Forecast')),
      body: months.every((m) => m.entries.isEmpty)
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insights_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No forecast available',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Add recurring expenses to see your forecast',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Based on your recurring expenses, here\'s what the next 3 months look like.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ...months.map((m) => _MonthCard(forecast: m, fmt: fmt)),
              ],
            ),
    );
  }
}

class _MonthCard extends StatefulWidget {
  final MonthForecast forecast;
  final NumberFormat fmt;
  const _MonthCard({required this.forecast, required this.fmt});

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(widget.forecast.month);
    final total = widget.forecast.total;
    final maxAmount = widget.forecast.entries.isNotEmpty
        ? widget.forecast.entries.first.amount
        : 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(monthLabel,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.forecast.entries.length} recurring charge${widget.forecast.entries.length == 1 ? '' : 's'}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.fmt.format(total),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        'projected',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: widget.forecast.entries
                    .map((e) => _ForecastEntryRow(
                          entry: e,
                          maxAmount: maxAmount,
                          fmt: widget.fmt,
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ForecastEntryRow extends StatelessWidget {
  final ForecastEntry entry;
  final double maxAmount;
  final NumberFormat fmt;

  const _ForecastEntryRow({required this.entry, required this.maxAmount, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final fraction = maxAmount > 0 ? (entry.amount / maxAmount) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(entry.description,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Text(fmt.format(entry.amount),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.recurrenceInterval,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
