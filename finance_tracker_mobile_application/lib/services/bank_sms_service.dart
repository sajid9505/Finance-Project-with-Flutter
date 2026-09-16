import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import 'bank_sms_parser.dart';
import 'expense_service.dart';
import 'notification_service.dart';

class BankSmsService {
  static const _channel = MethodChannel('sms/channel');
  static const _queueKey = 'sms_queue';
  static const _enabledKey = 'sms_monitoring_enabled';

  static final _parser = BankSmsParser();
  static final _expenseService = ExpenseService();

  /// Call once from main.dart after Firebase init.
  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        final args = Map<String, String>.from(call.arguments as Map);
        final body = args['body'] ?? '';
        final sender = args['sender'] ?? '';
        // uid is not available here without auth; enqueue for processing on next login
        await _enqueue(body, sender);
      }
    });
  }

  /// Process any SMS events queued while the app was closed.
  static Future<void> processPendingQueue(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return;

    List<dynamic> queue;
    try {
      queue = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      await prefs.remove(_queueKey);
      return;
    }

    for (final item in queue) {
      final map = Map<String, String>.from(item as Map);
      await _handleSms(map['body'] ?? '', map['sender'] ?? '', uid);
    }
    await prefs.remove(_queueKey);
  }

  /// Called by the foreground MethodChannel handler. Processes immediately if uid known.
  static Future<void> handleForegroundSms(
      String body, String sender, String uid) async {
    await _handleSms(body, sender, uid);
  }

  static Future<void> _handleSms(
      String body, String sender, String uid) async {
    final tx = _parser.parse(body, sender);
    if (tx == null) return;

    final expense = Expense(
      id: '',
      amount: tx.amount,
      category: tx.category,
      description: tx.description,
      date: tx.date,
      isRecurring: false,
      createdAt: DateTime.now(),
      isSplit: false,
    );

    await _expenseService.addExpense(uid, expense);
    await NotificationService.showExpenseLogged(tx);
  }

  static Future<void> _enqueue(String body, String sender) async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> queue = [];
    final raw = prefs.getString(_queueKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        queue = jsonDecode(raw) as List<dynamic>;
      } catch (_) {}
    }
    queue.add({'body': body, 'sender': sender});
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    // Inform native side to activate / deactivate
    try {
      await _channel.invokeMethod('setEnabled', value);
    } catch (_) {}
  }
}
