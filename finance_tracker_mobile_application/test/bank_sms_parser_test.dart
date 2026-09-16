import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_mobile_application/services/bank_sms_parser.dart';

void main() {
  final parser = BankSmsParser();
  const sender = 'VM-UCBL';

  // ─── SKIP CASES ────────────────────────────────────────────────────────────

  group('Messages that should be ignored', () {
    test('OTP messages are skipped', () {
      const otp =
          'One Time Password (OTP) for your Card#8320 transaction is 5328. '
          'Use this OTP to complete the trxn. The OTP will valid for 5 min. '
          'Do not share OTP with anyone.';
      expect(parser.parse(otp, sender), isNull);
    });

    test('Credit messages are skipped', () {
      const credit =
          'Your A/C (***0569) has been credited BDT 40,000.00 for ATM Bill Payment / FT. '
          'Avl Bal: BDT 2,53,316.86 @ 09:40 AM. For query: 16419';
      expect(parser.parse(credit, sender), isNull);
    });

    test('Declined transactions are skipped', () {
      const declined =
          'Your transaction using Card # 461989*7066 has been declined due to Bad CVV2. '
          'For more information please contact with us. Helpline- 16742. JBL Cards.';
      expect(parser.parse(declined, sender), isNull);
    });

    test('Credit card payment credit is skipped', () {
      const credit =
          'Dear Cardholder, BDT 11,429.00 has been credited to your credit card *0234 '
          'on 02-Jul-2025 13:35. Helpline 16218';
      expect(parser.parse(credit, 'AD-PRIMEBD'), isNull);
    });

    test('EBL fund transfer credit is skipped', () {
      const credit =
          'AC 127***770 is credited with BDT 4000 as Fund Transfer from bKash Account '
          'on 03-JUN-24 11:53:24 AM Balance is BDT 4559.04 Thanks. EBL Helpline 16230';
      expect(parser.parse(credit, 'AD-EBL'), isNull);
    });
  });

  // ─── AMOUNT EXTRACTION ────────────────────────────────────────────────────

  group('Amount extraction', () {
    test('UCB — no space, comma separator: BDT2,850.00', () {
      const sms =
          'Your UCB Debit Card#8320 (CL ID:699644) has been charged for BDT2,850.00 '
          'at TEXMART on 07/07/25 13:16. For query: Call:16419.';
      final tx = parser.parse(sms, sender);
      expect(tx?.amount, equals(2850.0));
    });

    test('UCB ATM — no space, large amount: BDT15,000.00', () {
      const sms =
          'BDT15,000.00 withdrawn fm Card#8320 (CL ID:699644) on 22/06/25 13:42 '
          'at UCBL ATM. Avl Bal:204150.58.';
      final tx = parser.parse(sms, sender);
      expect(tx?.amount, equals(15000.0));
    });

    test('Prime Bank — space, no comma: BDT 4000.00', () {
      const sms =
          'You have transacted BDT 4000.00 at AB FASHION INTERNATIONALD on '
          '05/07/2025 19:56:49 using Card# *0234. Balance: 100000.50. Helpline 16218';
      final tx = parser.parse(sms, 'AD-PRIMEBD');
      expect(tx?.amount, equals(4000.0));
    });

    test('Prime Bank — small debit: BDT200.00', () {
      const sms =
          'Dear Customer, BDT200.00 has been debited from a/c 211821****900 on 14/07/2025. '
          'Your current balance is BDT28.29';
      final tx = parser.parse(sms, 'AD-PRIMEBD');
      expect(tx?.amount, equals(200.0));
    });

    test('EBL — decimal without trailing zero: BDT 172.5', () {
      const sms =
          'AC 127***770 is debited with BDT 172.5 as Debit Card Annual Fee '
          'on 10-APR-23 03:50:10 PM Balance is BDT 15194.99 Thanks. EBL Helpline 16230';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx?.amount, equals(172.5));
    });

    test('EBL ATM — no decimal: BDT500', () {
      const sms =
          'Cash WD BDT500 from BANANI, DHAKA DHAKA . Card 452017**8515 '
          'on 15-Nov-22 06:03:35 PM BST.Your A/C 127**5770 Balance BDT 867.49. EBL Helpline 16230';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx?.amount, equals(500.0));
    });

    test('Jamuna — comma separator: BDT 1,000.00', () {
      const sms =
          'Thanks for Withdrawal BDT 1,000.00 from  UTTARA RABINDRA SHARANI C, '
          'using JBL Debit Card 461989*7066 on 20/06/23 08:05 am. Balance BDT 14,935.27.';
      final tx = parser.parse(sms, 'JBL-CARDS');
      expect(tx?.amount, equals(1000.0));
    });
  });

  // ─── MERCHANT EXTRACTION ──────────────────────────────────────────────────

  group('Merchant extraction', () {
    test('UCB purchase extracts merchant from "charged for ... at MERCHANT"', () {
      const sms =
          'Your UCB Debit Card#8320 (CL ID:699644) has been charged for BDT2,850.00 '
          'at TEXMART on 07/07/25 13:16. For query: Call:16419.';
      final tx = parser.parse(sms, sender);
      expect(tx?.merchant, equals('TEXMART'));
    });

    test('Prime Bank card extracts merchant from "transacted ... at MERCHANT"', () {
      const sms =
          'You have transacted BDT 4000.00 at AB FASHION INTERNATIONALD on '
          '05/07/2025 19:56:49 using Card# *0234. Balance: 100000.50. Helpline 16218';
      final tx = parser.parse(sms, 'AD-PRIMEBD');
      expect(tx?.merchant, equals('AB FASHION INTERNATIONALD'));
    });

    test('Prime Bank account debit returns "Bank Debit"', () {
      const sms =
          'Dear Customer, BDT200.00 has been debited from a/c 211821****900 on 14/07/2025. '
          'Your current balance is BDT28.29';
      final tx = parser.parse(sms, 'AD-PRIMEBD');
      expect(tx?.merchant, equals('Bank Debit'));
    });

    test('EBL debit extracts description after "as"', () {
      const sms =
          'AC 127***770 is debited with BDT 172.5 as Debit Card Annual Fee '
          'on 10-APR-23 03:50:10 PM Balance is BDT 15194.99 Thanks. EBL Helpline 16230';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx?.merchant, equals('Debit Card Annual Fee'));
    });

    test('Jamuna purchase extracts merchant from "Purchase ... from MERCHANT, using"', () {
      const sms =
          'Thanks for Purchase BDT 660.00 from NORTH END- GULSHAN-2 DHAKA, '
          'using JBL Debit Card 461989*7066 on 07/06/23 03:53 pm. Balance BDT.';
      final tx = parser.parse(sms, 'JBL-CARDS');
      expect(tx?.merchant, equals('NORTH END- GULSHAN-2 DHAKA'));
    });

    test('EBL ATM withdrawal extracts location from "Cash WD ... from LOCATION"', () {
      const sms =
          'Cash WD BDT500 from BANANI, DHAKA DHAKA . Card 452017**8515 '
          'on 15-Nov-22 06:03:35 PM BST. Your A/C 127**5770 Balance BDT 867.49.';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx?.merchant, isNotEmpty);
    });
  });

  // ─── DATE EXTRACTION ──────────────────────────────────────────────────────

  group('Date extraction', () {
    test('dd/mm/yy format: 07/07/25 → July 7, 2025', () {
      const sms =
          'Your UCB Debit Card#8320 has been charged for BDT2,850.00 at TEXMART '
          'on 07/07/25 13:16.';
      final tx = parser.parse(sms, sender);
      expect(tx?.date.year, equals(2025));
      expect(tx?.date.month, equals(7));
      expect(tx?.date.day, equals(7));
    });

    test('dd/mm/yyyy format: 14/07/2025 → July 14, 2025', () {
      const sms =
          'Dear Customer, BDT200.00 has been debited from a/c 211821****900 on 14/07/2025.';
      final tx = parser.parse(sms, 'AD-PRIMEBD');
      expect(tx?.date.year, equals(2025));
      expect(tx?.date.month, equals(7));
      expect(tx?.date.day, equals(14));
    });

    test('dd-MMM-yy format: 10-APR-23 → April 10, 2023', () {
      const sms =
          'AC 127***770 is debited with BDT 172.5 as Debit Card Annual Fee '
          'on 10-APR-23 03:50:10 PM Balance is BDT 15194.99.';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx?.date.year, equals(2023));
      expect(tx?.date.month, equals(4));
      expect(tx?.date.day, equals(10));
    });

    test('dd-Nov-yy format: 15-Nov-22 → November 15, 2022', () {
      const sms =
          'Cash WD BDT500 from BANANI, DHAKA DHAKA . Card 452017**8515 '
          'on 15-Nov-22 06:03:35 PM BST.';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx?.date.year, equals(2022));
      expect(tx?.date.month, equals(11));
      expect(tx?.date.day, equals(15));
    });

    test('Missing date falls back to today', () {
      const sms = 'BDT 500.00 has been debited from your account.';
      final tx = parser.parse(sms, sender);
      final today = DateTime.now();
      expect(tx?.date.year, equals(today.year));
      expect(tx?.date.month, equals(today.month));
    });
  });

  // ─── CARD NUMBER ──────────────────────────────────────────────────────────

  group('Card number extraction', () {
    test('UCB Card#8320 → description includes "Card 8320"', () {
      const sms =
          'Your UCB Debit Card#8320 (CL ID:699644) has been charged for BDT2,850.00 '
          'at TEXMART on 07/07/25 13:16.';
      final tx = parser.parse(sms, sender);
      expect(tx?.description, contains('8320'));
    });

    test('Prime Bank Card# *0234 → description includes "0234"', () {
      const sms =
          'You have transacted BDT 4000.00 at AB FASHION INTERNATIONALD on '
          '05/07/2025 using Card# *0234. Balance: 100000.50.';
      final tx = parser.parse(sms, 'AD-PRIMEBD');
      expect(tx?.description, contains('0234'));
    });
  });

  // ─── CATEGORY MAPPING ────────────────────────────────────────────────────

  group('Category mapping', () {
    test('TEXMART → Shopping', () {
      const sms =
          'Your UCB Debit Card#8320 has been charged for BDT2,850.00 at TEXMART on 07/07/25.';
      final tx = parser.parse(sms, sender);
      expect(tx?.category, equals('Shopping'));
    });

    test('ATM withdrawal → Other', () {
      const sms =
          'BDT15,000.00 withdrawn fm Card#8320 on 22/06/25 13:42 at UCBL ATM. Avl Bal:204150.58.';
      final tx = parser.parse(sms, sender);
      expect(tx?.category, equals('Other'));
    });

    test('NORTH END (restaurant) → Food & Dining', () {
      const sms =
          'Thanks for Purchase BDT 660.00 from NORTH END- GULSHAN-2 DHAKA, '
          'using JBL Debit Card 461989*7066 on 07/06/23 03:53 pm.';
      final tx = parser.parse(sms, 'JBL-CARDS');
      expect(tx?.category, equals('Food & Dining'));
    });

    test('bKash payment → Other', () {
      const sms =
          'Thanks for Purchase BDT 750.00 from bKash 16247, '
          'using JBL Debit Card 461989*7066 on 16/06/23 09:16 pm.';
      final tx = parser.parse(sms, 'JBL-CARDS');
      expect(tx?.category, equals('Other'));
    });

    test('Annual fee (no merchant keyword) → Other', () {
      const sms =
          'AC 127***770 is debited with BDT 172.5 as Debit Card Annual Fee '
          'on 10-APR-23. Balance is BDT 15194.99.';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx?.category, equals('Other'));
    });
  });

  // ─── FULL REAL SMS SAMPLES ───────────────────────────────────────────────

  group('Full real-world SMS samples', () {
    test('UCB debit card purchase at TEXMART', () {
      const sms =
          'Your UCB Debit Card#8320 (CL ID:699644) has been charged for BDT2,850.00 '
          'at TEXMART on 07/07/25 13:16. For query: Call:16419.';
      final tx = parser.parse(sms, 'VM-UCBL');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(2850.0));
      expect(tx.merchant, equals('TEXMART'));
      expect(tx.date, equals(DateTime(2025, 7, 7)));
    });

    test('UCB ATM withdrawal', () {
      const sms =
          'BDT15,000.00 withdrawn fm Card#8320 (CL ID:699644) on 22/06/25 13:42 '
          'at UCBL ATM. Avl Bal:204150.58. Use UCB Cash Recycler to deposit 24/7.';
      final tx = parser.parse(sms, 'VM-UCBL');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(15000.0));
      expect(tx.category, equals('Other'));
    });

    test('Prime Bank card transaction at AB FASHION', () {
      const sms =
          'You have transacted BDT 4000.00 at AB FASHION INTERNATIONALD on '
          '05/07/2025 19:56:49 using Card# *0234. Balance: 100000.50. Helpline 16218';
      final tx = parser.parse(sms, 'AD-PRIMEBD');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(4000.0));
      expect(tx.merchant, equals('AB FASHION INTERNATIONALD'));
      expect(tx.category, equals('Shopping'));
    });

    test('Prime Bank account debit (no merchant)', () {
      const sms =
          'Dear Customer, BDT1817.00 has been debited from a/c 211821****900 '
          'on 10/07/2025. Your current balance is BDT5,273.29';
      final tx = parser.parse(sms, 'AD-PRIMEBD');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(1817.0));
      expect(tx.merchant, equals('Bank Debit'));
    });

    test('EBL debit card annual fee', () {
      const sms =
          'AC 127***770 is debited with BDT 172.5 as Debit Card Annual Fee '
          'on 10-APR-23 03:50:10 PM Balance is BDT 15194.99 Thanks. EBL Helpline 16230';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(172.5));
      expect(tx.merchant, equals('Debit Card Annual Fee'));
      expect(tx.date, equals(DateTime(2023, 4, 10)));
    });

    test('EBL ATM cash withdrawal', () {
      const sms =
          'Cash WD BDT500 from BANANI, DHAKA DHAKA . Card 452017**8515 '
          'on 15-Nov-22 06:03:35 PM BST.Your A/C 127**5770 Balance BDT 867.49. EBL Helpline 16230';
      final tx = parser.parse(sms, 'AD-EBL');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(500.0));
      expect(tx.date, equals(DateTime(2022, 11, 15)));
    });

    test('Jamuna Bank purchase at NORTH END', () {
      const sms =
          'Thanks for Purchase BDT 660.00 from NORTH END- GULSHAN-2 DHAKA, '
          'using JBL Debit Card 461989*7066 on 07/06/23 03:53 pm. Balance BDT. '
          'Thank you for being with us. Helpline- 16742. JBL Cards.';
      final tx = parser.parse(sms, 'JBL-CARDS');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(660.0));
      expect(tx.merchant, equals('NORTH END- GULSHAN-2 DHAKA'));
      expect(tx.category, equals('Food & Dining'));
    });

    test('Jamuna Bank ATM withdrawal', () {
      const sms =
          'Thanks for Withdrawal BDT 1,000.00 from  UTTARA RABINDRA SHARANI C, '
          'using JBL Debit Card 461989*7066 on 20/06/23 08:05 am. Balance BDT 14,935.27. '
          'Thank you for being with us. Helpline- 16742. JBL Cards.';
      final tx = parser.parse(sms, 'JBL-CARDS');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(1000.0));
      expect(tx.date, equals(DateTime(2023, 6, 20)));
    });

    test('Jamuna Bank bKash payment', () {
      const sms =
          'Thanks for Purchase BDT 750.00 from bKash 16247, '
          'using JBL Debit Card 461989*7066 on 16/06/23 09:16 pm. Balance BDT. '
          'Thank you for being with us. Helpline- 16742. JBL Cards.';
      final tx = parser.parse(sms, 'JBL-CARDS');
      expect(tx, isNotNull);
      expect(tx!.amount, equals(750.0));
      expect(tx.category, equals('Other'));
    });
  });
}
