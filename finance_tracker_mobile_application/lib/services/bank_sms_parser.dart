import '../models/parsed_transaction.dart';

class BankSmsParser {
  // Skip messages that are NOT expenses
  static final _skipPatterns = RegExp(
    r'\b(credited|OTP|One Time Password|Password|declined|reward|reversal)\b',
    caseSensitive: false,
  );

  // Must contain a debit/purchase trigger to be considered
  static final _expenseTriggers = RegExp(
    r'\b(charged for|withdrawn|Cash WD|debited|Purchase|Withdrawal|transacted)\b',
    caseSensitive: false,
  );

  // BDT amount: handles BDT2,850.00 / BDT 500 / BDT 172.5
  static final _amountRegex = RegExp(
    r'BDT\s*([\d,]+(?:\.\d*)?)',
    caseSensitive: false,
  );

  // Card number: Card#8320 or Card# *0234 or Card 461989*7066
  static final _cardRegex = RegExp(
    r'[Cc]ard[# ]+\*?(\d{4,})',
  );

  // Date patterns
  static final _dateNumeric = RegExp(
    r'\b(\d{2})[/-](\d{2})[/-](\d{2,4})\b',
  );
  static final _dateText = RegExp(
    r'\b(\d{1,2})[-\s]([A-Za-z]{3})[-\s](\d{2,4})\b',
  );

  static const _monthMap = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  ParsedTransaction? parse(String body, String senderId) {
    // Skip non-expense messages
    if (_skipPatterns.hasMatch(body)) return null;
    if (!_expenseTriggers.hasMatch(body)) return null;

    final amount = _extractAmount(body);
    if (amount == null || amount <= 0) return null;

    final merchant = _extractMerchant(body);
    final card = _extractCard(body);
    final date = _extractDate(body) ?? DateTime.now();
    final category = _mapCategory(merchant);

    final description = card != null
        ? '$merchant (Card $card)'
        : merchant;

    return ParsedTransaction(
      amount: amount,
      merchant: merchant,
      description: description,
      date: date,
      category: category,
      rawSms: body,
      senderId: senderId,
    );
  }

  double? _extractAmount(String body) {
    // The transaction amount always appears before the balance — take the first match.
    final m = _amountRegex.firstMatch(body);
    if (m == null) return null;
    return double.tryParse(m.group(1)!.replaceAll(',', ''));
  }

  String _extractMerchant(String body) {
    // UCB / Prime Bank: "charged for BDT... at MERCHANT on"
    // Prime Bank card: "transacted BDT... at MERCHANT on"
    var m = RegExp(
      r'(?:charged for|transacted)\s+BDT[\d,.\s]+at\s+(.+?)(?:\s+on\s|\s+\d{2}[/\-])',
      caseSensitive: false,
    ).firstMatch(body);
    if (m != null) return _clean(m.group(1)!);

    // UCB ATM withdrawal: "withdrawn fm Card... at LOCATION. Avl"
    m = RegExp(
      r'withdrawn\s+fm\s+.+?\s+at\s+(.+?)[\.\,]',
      caseSensitive: false,
    ).firstMatch(body);
    if (m != null) return _clean(m.group(1)!);

    // EBL ATM: "Cash WD BDT... from LOCATION ."
    m = RegExp(
      r'Cash WD\s+BDT[\d,.\s]+from\s+(.+?)(?:\s*\.|Card)',
      caseSensitive: false,
    ).firstMatch(body);
    if (m != null) return _clean(m.group(1)!);

    // EBL debit: "is debited with BDT... as DESCRIPTION on"
    m = RegExp(
      r'debited with\s+BDT[\d,.\s]+as\s+(.+?)(?:\s+on\s)',
      caseSensitive: false,
    ).firstMatch(body);
    if (m != null) return _clean(m.group(1)!);

    // Jamuna: "Purchase/Withdrawal BDT... from MERCHANT, using"
    m = RegExp(
      r'(?:Purchase|Withdrawal)\s+BDT[\d,.\s]+from\s+(.+?)(?:,\s*using|\s+using)',
      caseSensitive: false,
    ).firstMatch(body);
    if (m != null) return _clean(m.group(1)!);

    // Generic: "debited from a/c" — no merchant
    if (RegExp(r'debited from a/c', caseSensitive: false).hasMatch(body)) {
      return 'Bank Debit';
    }

    return 'Bank Transaction';
  }

  String? _extractCard(String body) {
    final m = _cardRegex.firstMatch(body);
    if (m == null) return null;
    final digits = m.group(1)!;
    // Return last 4 digits only
    return digits.length > 4 ? digits.substring(digits.length - 4) : digits;
  }

  DateTime? _extractDate(String body) {
    // Try dd/mm/yy or dd/mm/yyyy
    var m = _dateNumeric.firstMatch(body);
    if (m != null) {
      final day = int.parse(m.group(1)!);
      final month = int.parse(m.group(2)!);
      var year = int.parse(m.group(3)!);
      if (year < 100) year += 2000;
      try {
        return DateTime(year, month, day);
      } catch (_) {}
    }

    // Try dd-MMM-yy or dd-MMM-yyyy
    m = _dateText.firstMatch(body);
    if (m != null) {
      final day = int.parse(m.group(1)!);
      final monthStr = m.group(2)!.toLowerCase().substring(0, 3);
      var year = int.parse(m.group(3)!);
      if (year < 100) year += 2000;
      final month = _monthMap[monthStr];
      if (month != null) {
        try {
          return DateTime(year, month, day);
        } catch (_) {}
      }
    }

    return null;
  }

  String _mapCategory(String merchant) {
    final m = merchant.toUpperCase();

    // Cash / ATM
    if (RegExp(r'\bATM\b|CASH WD|CASH RECYCLER').hasMatch(m)) return 'Other';

    // Mobile financial services
    if (RegExp(r'\b(BKASH|NAGAD|ROCKET|MFS)\b').hasMatch(m)) return 'Other';

    // Grocery / supermarkets
    if (RegExp(r'\b(SHWAPNO|MEENA BAZAR|AGORA|UNIMART|SUPERSTORE|SUPER SHOP|GROCERY|LAVENDER)\b').hasMatch(m)) {
      return 'Grocery';
    }

    // Food & dining
    if (RegExp(r'\b(RESTAURANT|CAFE|COFFEE|FOOD|DINING|NORTH END|KFC|PIZZA|BURGER|BIRYANI|KITCHEN)\b').hasMatch(m)) {
      return 'Food & Dining';
    }

    // Shopping / fashion
    if (RegExp(r'\b(FASHION|CLOTHING|BOUTIQUE|TEXMART|DARAZ|SHOPNO|MALL|STORE|SHOP)\b').hasMatch(m)) {
      return 'Shopping';
    }

    // Health
    if (RegExp(r'\b(PHARMACY|HOSPITAL|CLINIC|HEALTH|MEDICAL|DRUG|DIAGNOSTIC)\b').hasMatch(m)) {
      return 'Health';
    }

    // Transport
    if (RegExp(r'\b(UBER|PATHAO|SHOHOZ|FUEL|PETROL|CNG|TRANSPORT|BUS|RAIL)\b').hasMatch(m)) {
      return 'Transport';
    }

    // Telecom / subscriptions
    if (RegExp(r'\b(GRAMEENPHONE|ROBI|BANGLALINK|AIRTEL|TELETALK|TELECOM)\b').hasMatch(m)) {
      return 'Subscriptions';
    }

    // Utilities
    if (RegExp(r'\b(ELECTRICITY|WASA|GAS|BILL|DESCO|DPDC|BGDCL|TITAS)\b').hasMatch(m)) {
      return 'Utilities';
    }

    return 'Other';
  }

  String _clean(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ');
}
