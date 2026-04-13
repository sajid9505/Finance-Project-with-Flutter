class Budget {
  final String period; // 'weekly' or 'monthly'
  final Map<String, double> categoryBudgets; // category → limit

  const Budget({
    required this.period,
    this.categoryBudgets = const {},
  });

  Map<String, dynamic> toFirestore() => {
        'period': period,
        'categoryBudgets': categoryBudgets,
      };

  factory Budget.fromFirestore(Map<String, dynamic> data) => Budget(
        period: data['period'] as String? ?? 'monthly',
        categoryBudgets: data['categoryBudgets'] != null
            ? Map<String, double>.from(
                (data['categoryBudgets'] as Map)
                    .map((k, v) => MapEntry(k as String, (v as num).toDouble())),
              )
            : {},
      );

  Budget copyWith({
    String? period,
    Map<String, double>? categoryBudgets,
  }) =>
      Budget(
        period: period ?? this.period,
        categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      );

  bool get hasCategoryBudgets => categoryBudgets.isNotEmpty;
}
