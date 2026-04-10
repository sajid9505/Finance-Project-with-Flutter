import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class DataPrivacyScreen extends ConsumerWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(title: const Text('Data & Privacy')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // Data statement
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.privacy_tip_outlined,
                            color: kTeal, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('How We Handle Your Data',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DataPoint(
                    icon: Icons.cloud_outlined,
                    text:
                        'Your expenses are stored securely in Firestore, tied to your account only. No one else can access your data.',
                  ),
                  const SizedBox(height: 12),
                  _DataPoint(
                    icon: Icons.phone_android_outlined,
                    text:
                        'Receipt images are stored locally on your device only and are never uploaded to any server.',
                  ),
                  const SizedBox(height: 12),
                  _DataPoint(
                    icon: Icons.block_outlined,
                    text:
                        'We do not share your data with any third parties or use it for advertising.',
                  ),
                  const SizedBox(height: 12),
                  _DataPoint(
                    icon: Icons.lock_outlined,
                    text:
                        'Authentication is handled by Firebase Auth. Your password is never stored in plain text.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delete account
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: ListTile(
                onTap: () => _confirmDeleteAccount(context, ref),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_forever_outlined,
                      color: Colors.red, size: 20),
                ),
                title: const Text('Delete Account',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red)),
                subtitle: Text('Permanently delete your account and all data',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                trailing: Icon(Icons.chevron_right,
                    size: 18, color: Colors.grey.shade400),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account?'),
        content: const Text(
            'This will permanently delete your account and all your expense data. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      // Delete all Firestore user data
      final db = FirebaseFirestore.instance;
      final userDoc = db.collection('users').doc(user.uid);

      // Delete expenses subcollection
      final expenses =
          await userDoc.collection('expenses').get();
      for (final doc in expenses.docs) {
        await doc.reference.delete();
      }

      // Delete dismissed drains subcollection
      final dismissed =
          await userDoc.collection('dismissedDrains').get();
      for (final doc in dismissed.docs) {
        await doc.reference.delete();
      }

      // Delete user doc
      await userDoc.delete();

      // Delete Firebase Auth account
      await user.delete();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to delete account. You may need to sign in again first. Error: $e'),
          ),
        );
      }
    }
  }
}

class _DataPoint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DataPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: kTeal),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5)),
        ),
      ],
    );
  }
}
