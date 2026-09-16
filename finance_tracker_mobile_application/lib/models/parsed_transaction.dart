class ParsedTransaction {
  final double amount;
  final String merchant;
  final String description;
  final DateTime date;
  final String category;
  final String rawSms;
  final String senderId;

  const ParsedTransaction({
    required this.amount,
    required this.merchant,
    required this.description,
    required this.date,
    required this.category,
    required this.rawSms,
    required this.senderId,
  });
}
