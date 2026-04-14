import 'package:cloud_firestore/cloud_firestore.dart';

const List<Map<String, String>> kSupportedCurrencies = [
  {'code': 'USD', 'symbol': '\$', 'label': 'US Dollar'},
  {'code': 'BDT', 'symbol': '৳', 'label': 'Bangladeshi Taka'},
  {'code': 'AUD', 'symbol': 'A\$', 'label': 'Australian Dollar'},
  {'code': 'GBP', 'symbol': '£', 'label': 'British Pound'},
  {'code': 'EUR', 'symbol': '€', 'label': 'Euro'},
  {'code': 'CAD', 'symbol': 'C\$', 'label': 'Canadian Dollar'},
  {'code': 'SGD', 'symbol': 'S\$', 'label': 'Singapore Dollar'},
  {'code': 'INR', 'symbol': '₹', 'label': 'Indian Rupee'},
];

class CurrencyService {
  final _db = FirebaseFirestore.instance;

  Stream<String> watchCurrencySymbol(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('currency')
        .snapshots()
        .map((snap) {
      if (!snap.exists) return '\$';
      return snap.data()?['symbol'] as String? ?? '\$';
    });
  }

  Future<void> setCurrency(
      String uid, String symbol, String code) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('currency')
        .set({'symbol': symbol, 'code': code});
  }
}
