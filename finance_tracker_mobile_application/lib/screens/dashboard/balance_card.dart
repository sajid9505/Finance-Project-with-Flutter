import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/expense.dart';

class BalanceCard extends StatefulWidget {
  final double totalThisMonth;
  final double oneOffTotal;
  final double recurringTotal;
  final List<Expense> allExpenses;
  final bool isOverBudget;

  const BalanceCard({
    super.key,
    required this.totalThisMonth,
    required this.oneOffTotal,
    required this.recurringTotal,
    required this.allExpenses,
    this.isOverBudget = false,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // flip back: reverse
      }
    });

    _animation.addListener(() {
      // Switch content at midpoint
      if (_controller.value >= 0.5 && !_showBack) {
        setState(() => _showBack = true);
      } else if (_controller.value < 0.5 && _showBack) {
        setState(() => _showBack = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value),
          child: _showBack
              ? _BackCard(
                  allExpenses: widget.allExpenses,
                  onFlip: _flip,
                )
              : _FrontCard(
                  totalThisMonth: widget.totalThisMonth,
                  oneOffTotal: widget.oneOffTotal,
                  recurringTotal: widget.recurringTotal,
                  isOverBudget: widget.isOverBudget,
                  onFlip: _flip,
                ),
        );
      },
    );
  }
}

// ─── Front ───────────────────────────────────────────────────────────────────

class _FrontCard extends StatelessWidget {
  final double totalThisMonth;
  final double oneOffTotal;
  final double recurringTotal;
  final bool isOverBudget;
  final VoidCallback onFlip;

  const _FrontCard({
    required this.totalThisMonth,
    required this.oneOffTotal,
    required this.recurringTotal,
    required this.onFlip,
    this.isOverBudget = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOverBudget
            ? Colors.red.withOpacity(0.25)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isOverBudget
                ? Colors.red.withOpacity(0.5)
                : Colors.white.withOpacity(0.12),
            width: isOverBudget ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Total Spent',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  if (isOverBudget)
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orangeAccent, size: 16)
                  else
                    const Icon(Icons.keyboard_arrow_up,
                        color: Colors.white70, size: 18),
                ],
              ),
              GestureDetector(
                onTap: onFlip,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.more_horiz,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalThisMonth),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5),
          ),
          if (isOverBudget) ...[
            const SizedBox(height: 4),
            const Text('Over budget',
                style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.arrow_downward,
                  label: 'One-time',
                  amount: currencyFormat.format(oneOffTotal),
                ),
              ),
              Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.2)),
              Expanded(
                child: _StatItem(
                  icon: Icons.arrow_upward,
                  label: 'Recurring',
                  amount: currencyFormat.format(recurringTotal),
                  alignRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Back ────────────────────────────────────────────────────────────────────

class _BackCard extends StatelessWidget {
  final List<Expense> allExpenses;
  final VoidCallback onFlip;

  const _BackCard({required this.allExpenses, required this.onFlip});

  Map<int, double> _monthlyTotals() {
    final now = DateTime.now();
    final totals = <int, double>{};
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = month.year * 12 + month.month;
      totals[key] = 0;
    }
    for (final e in allExpenses) {
      final key = e.date.year * 12 + e.date.month;
      if (totals.containsKey(key)) {
        totals[key] = (totals[key] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totals = _monthlyTotals();
    final entries = totals.entries.toList();
    final maxVal =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withOpacity(0.12), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Last 12 Months',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: onFlip,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: maxVal <= 0 ? 100 : maxVal * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          Colors.white.withOpacity(0.85),
                      getTooltipItem: (group, _, rod, __) {
                        final key = entries[group.x].key;
                        final month = DateTime(key ~/ 12, key % 12);
                        return BarTooltipItem(
                          '${DateFormat('MMM').format(month)}\n\$${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(
                              color: kTealDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox();
                          }
                          final key = entries[idx].key;
                          final month = DateTime(key ~/ 12, key % 12);
                          final isCurrentMonth =
                              month.month == now.month &&
                                  month.year == now.year;
                          return Text(
                            DateFormat('MMM').format(month),
                            style: TextStyle(
                              color: isCurrentMonth
                                  ? Colors.white
                                  : Colors.white54,
                              fontSize: 9,
                              fontWeight: isCurrentMonth
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        },
                        reservedSize: 18,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: entries.asMap().entries.map((e) {
                    final idx = e.key;
                    final amount = e.value.value;
                    final key = e.value.key;
                    final month = DateTime(key ~/ 12, key % 12);
                    final isCurrentMonth = month.month == now.month &&
                        month.year == now.year;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: amount <= 0 ? 0.5 : amount,
                          color: isCurrentMonth
                              ? Colors.white
                              : Colors.white.withOpacity(0.45),
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

// ─── Shared stat item ────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final bool alignRight;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.amount,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: alignRight ? 16 : 0, right: alignRight ? 0 : 16),
      child: Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: alignRight
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(amount,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
