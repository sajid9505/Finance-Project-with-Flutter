import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bank_sender.dart';
import '../providers/auth_provider.dart';
import '../services/bank_sender_service.dart';

final bankSenderServiceProvider =
    Provider<BankSenderService>((ref) => BankSenderService());

final bankSendersProvider = StreamProvider<List<BankSender>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.read(bankSenderServiceProvider).watchSenders(user.uid);
});
