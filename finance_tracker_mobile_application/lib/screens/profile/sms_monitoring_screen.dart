import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../models/bank_sender.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bank_sms_provider.dart';
import '../../services/bank_sms_service.dart';

class SmsMonitoringScreen extends ConsumerStatefulWidget {
  const SmsMonitoringScreen({super.key});

  @override
  ConsumerState<SmsMonitoringScreen> createState() =>
      _SmsMonitoringScreenState();
}

class _SmsMonitoringScreenState extends ConsumerState<SmsMonitoringScreen> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    BankSmsService.isEnabled().then((v) {
      if (mounted) setState(() => _enabled = v);
    });
  }

  Future<void> _toggleEnabled(bool value) async {
    if (value) {
      // Show rationale before Android's generic "send and view" dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('SMS Access'),
          content: const Text(
            'WhereItWent needs permission to receive incoming SMS so it can '
            'detect bank transaction alerts and log them automatically.\n\n'
            'Android\'s permission dialog will say "send and view SMS", '
            'this is standard wording for all SMS permissions. '
            'This app cannot send messages.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kTeal, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final sms = await Permission.sms.request();
      if (!sms.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('SMS permission is required to monitor bank messages.'),
          ));
        }
        return;
      }
      await Permission.notification.request();
    }
    await BankSmsService.setEnabled(value);
    if (mounted) setState(() => _enabled = value);
  }

  Future<void> _addSender(String senderId, String label) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(bankSenderServiceProvider).addSender(
          user.uid,
          BankSender(senderId: senderId, label: label),
        );
  }

  Future<void> _removeSender(String senderId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(bankSenderServiceProvider).removeSender(user.uid, senderId);
  }

  void _showAddCustomDialog() {
    final idController = TextEditingController();
    final labelController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bank Sender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Sender ID',
                hintText: 'e.g. VM-UCBL',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g. UCB Bank',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kTeal, foregroundColor: Colors.white),
            onPressed: () {
              final id = idController.text.trim();
              final label = labelController.text.trim();
              if (id.isNotEmpty && label.isNotEmpty) {
                _addSender(id, label);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sendersAsync = ref.watch(bankSendersProvider);
    final senders = sendersAsync.value ?? [];
    final activeSenderIds = senders.map((s) => s.senderId).toSet();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('SMS Monitoring')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Enable toggle card
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Auto-log bank transactions',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            'Reads bank SMS messages and logs purchases automatically.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _enabled,
                      onChanged: _toggleEnabled,
                      activeColor: kTeal,
                    ),
                  ],
                ),
                if (_enabled) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: kTeal),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Only SMS from senders you add below will be processed. OTPs and credits are always ignored.',
                            style: TextStyle(fontSize: 11, color: kTeal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // My Banks section
          _SectionLabel(label: 'My Banks', trailing: TextButton.icon(
            onPressed: _showAddCustomDialog,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Custom'),
            style: TextButton.styleFrom(foregroundColor: kTeal),
          )),
          const SizedBox(height: 8),

          if (senders.isEmpty)
            _Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'No senders added yet.\nAdd from the list below or use a custom sender ID.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ),
              ),
            )
          else
            _Card(
              child: Column(
                children: senders.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.sms_outlined,
                              size: 18, color: kTeal),
                        ),
                        title: Text(s.label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                        subtitle: Text(s.senderId,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 18, color: Colors.red.shade300),
                          onPressed: () => _removeSender(s.senderId),
                        ),
                      ),
                      if (i < senders.length - 1)
                        Divider(
                            height: 1,
                            indent: 52,
                            color: Colors.grey.shade100),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // Common BD banks quick-add
          _SectionLabel(label: 'Common BD Banks', trailing: null),
          const SizedBox(height: 4),
          Text(
            'Tap + to add any of these to your monitoring list.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),

          ...kCommonBdBankSenders.map((preset) {
            final isAdded = activeSenderIds.contains(preset.senderId);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAdded ? kTeal.withValues(alpha: 0.4) : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                title: Text(preset.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: Text(preset.senderId,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                trailing: isAdded
                    ? Icon(Icons.check_circle, color: kTeal, size: 22)
                    : IconButton(
                        icon: Icon(Icons.add_circle_outline,
                            color: kTeal, size: 22),
                        onPressed: () =>
                            _addSender(preset.senderId, preset.label),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const _SectionLabel({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.grey.shade800)),
        if (trailing != null) trailing!,
      ],
    );
  }
}
