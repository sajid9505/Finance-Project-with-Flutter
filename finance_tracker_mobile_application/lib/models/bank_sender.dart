class BankSender {
  final String senderId;
  final String label;

  const BankSender({required this.senderId, required this.label});

  Map<String, dynamic> toMap() => {'senderId': senderId, 'label': label};

  factory BankSender.fromMap(Map<String, dynamic> map) => BankSender(
        senderId: map['senderId'] as String,
        label: map['label'] as String,
      );
}

const List<BankSender> kCommonBdBankSenders = [
  BankSender(senderId: 'VM-UCBL', label: 'UCB Bank'),
  BankSender(senderId: 'AD-PRIMEBD', label: 'Prime Bank'),
  BankSender(senderId: 'AD-EBL', label: 'Eastern Bank (EBL)'),
  BankSender(senderId: 'JBL-CARDS', label: 'Jamuna Bank'),
  BankSender(senderId: 'VM-DBBL', label: 'Dutch-Bangla Bank (Rocket)'),
  BankSender(senderId: 'VM-bKash', label: 'bKash'),
  BankSender(senderId: 'VM-CITYBANK', label: 'City Bank'),
  BankSender(senderId: 'VM-BRAC', label: 'BRAC Bank'),
  BankSender(senderId: 'VM-IBBL', label: 'Islami Bank'),
  BankSender(senderId: 'VM-MTB', label: 'Mutual Trust Bank'),
  BankSender(senderId: 'VM-SCB', label: 'Standard Chartered'),
  BankSender(senderId: 'VM-HSBC', label: 'HSBC Bangladesh'),
];
