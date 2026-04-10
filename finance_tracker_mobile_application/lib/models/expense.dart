import 'package:cloud_firestore/cloud_firestore.dart';

class SplitPerson {
  final String name;
  final double amount;
  final bool settled;

  SplitPerson({
    required this.name,
    required this.amount,
    this.settled = false,
  });

  SplitPerson copyWith({String? name, double? amount, bool? settled}) {
    return SplitPerson(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      settled: settled ?? this.settled,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'amount': amount,
        'settled': settled,
      };

  factory SplitPerson.fromMap(Map<String, dynamic> map) => SplitPerson(
        name: map['name'] as String,
        amount: (map['amount'] as num).toDouble(),
        settled: map['settled'] as bool? ?? false,
      );
}

class Expense {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final bool isRecurring;
  final String? recurrenceInterval; // 'weekly', 'fortnightly', 'monthly'
  final DateTime createdAt;
  final bool isSplit;
  final List<SplitPerson> splits;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.isRecurring = false,
    this.recurrenceInterval,
    required this.createdAt,
    this.isSplit = false,
    this.splits = const [],
  });

  double get totalOwed => splits
      .where((s) => !s.settled)
      .fold(0.0, (sum, s) => sum + s.amount);

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      description: data['description'] as String,
      date: (data['date'] as Timestamp).toDate(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurrenceInterval: data['recurrenceInterval'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isSplit: data['isSplit'] as bool? ?? false,
      splits: (data['splits'] as List<dynamic>? ?? [])
          .map((s) => SplitPerson.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
      'recurrenceInterval': recurrenceInterval,
      'createdAt': Timestamp.fromDate(createdAt),
      'isSplit': isSplit,
      'splits': splits.map((s) => s.toMap()).toList(),
    };
  }
}

const List<String> kExpenseCategories = [
  'Food & Dining',
  'Transport',
  'Housing',
  'Utilities',
  'Entertainment',
  'Health',
  'Shopping',
  'Subscriptions',
  'Other',
];
