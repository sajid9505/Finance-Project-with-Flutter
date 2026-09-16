import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/parsed_transaction.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'bank_sms_expenses';
  static int _idCounter = 0;

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      _channelId,
      'Bank SMS Expenses',
      description: 'Notifications when a bank SMS expense is auto-logged',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showExpenseLogged(ParsedTransaction tx) async {
    final amountStr = 'BDT ${tx.amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

    await _plugin.show(
      _idCounter++,
      'Expense logged · $amountStr',
      '${tx.merchant} — tap to review in dashboard',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Bank SMS Expenses',
          channelDescription: 'Auto-logged from bank SMS',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
