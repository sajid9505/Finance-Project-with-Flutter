import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_mobile_application/models/bank_sender.dart';

void main() {
  // ─── BankSender.toMap ─────────────────────────────────────────────────────

  group('BankSender.toMap', () {
    test('serializes senderId and label', () {
      const s = BankSender(senderId: 'VM-UCBL', label: 'UCB Bank');
      expect(s.toMap(), {'senderId': 'VM-UCBL', 'label': 'UCB Bank'});
    });
  });

  // ─── BankSender.fromMap ───────────────────────────────────────────────────

  group('BankSender.fromMap', () {
    test('parses senderId and label', () {
      final s = BankSender.fromMap({'senderId': 'AD-PRIMEBD', 'label': 'Prime Bank'});
      expect(s.senderId, 'AD-PRIMEBD');
      expect(s.label, 'Prime Bank');
    });

    test('round-trips toMap → fromMap', () {
      const original = BankSender(senderId: 'AD-EBL', label: 'Eastern Bank (EBL)');
      final copy = BankSender.fromMap(original.toMap());
      expect(copy.senderId, original.senderId);
      expect(copy.label, original.label);
    });
  });

  // ─── kCommonBdBankSenders ─────────────────────────────────────────────────

  group('kCommonBdBankSenders', () {
    test('contains 12 preset banks', () {
      expect(kCommonBdBankSenders.length, 12);
    });

    test('all sender IDs are unique', () {
      final ids = kCommonBdBankSenders.map((s) => s.senderId).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('contains UCB Bank (VM-UCBL)', () {
      expect(kCommonBdBankSenders.any((s) => s.senderId == 'VM-UCBL'), true);
    });

    test('contains Prime Bank (AD-PRIMEBD)', () {
      expect(kCommonBdBankSenders.any((s) => s.senderId == 'AD-PRIMEBD'), true);
    });

    test('contains EBL (AD-EBL)', () {
      expect(kCommonBdBankSenders.any((s) => s.senderId == 'AD-EBL'), true);
    });

    test('contains Jamuna Bank (JBL-CARDS)', () {
      expect(kCommonBdBankSenders.any((s) => s.senderId == 'JBL-CARDS'), true);
    });

    test('contains bKash (VM-bKash)', () {
      expect(kCommonBdBankSenders.any((s) => s.senderId == 'VM-bKash'), true);
    });

    test('all senders have non-empty labels', () {
      for (final s in kCommonBdBankSenders) {
        expect(s.label.isNotEmpty, true,
            reason: '${s.senderId} has an empty label');
      }
    });

    test('all senders have non-empty sender IDs', () {
      for (final s in kCommonBdBankSenders) {
        expect(s.senderId.isNotEmpty, true);
      }
    });
  });
}
