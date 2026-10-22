import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});
  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final recipient = TextEditingController();
  final amount = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    recipient.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final stars = int.tryParse(amount.text);
    if (stars == null || stars <= 0 || recipient.text.trim().isEmpty) {
      return showAppMessage(
        context,
        'Enter a username and a valid Stars amount.',
        error: true,
      );
    }
    final store = AppStoreScope.of(context);
    setState(() => busy = true);
    try {
      await store.wallet.transfer(recipient.text.trim(), stars);
      await store.refresh();
      if (mounted) {
        showAppMessage(context, 'Transfer completed.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showAppMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const StarHeader(title: 'Send Stars', showBack: true),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Recipient username'),
              const SizedBox(height: 8),
              TextField(
                controller: recipient,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'player_handle',
                ),
              ),
              const SizedBox(height: 17),
              const SectionLabel('Stars to send'),
              const SizedBox(height: 8),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.stars_rounded),
                  hintText: 'Amount',
                ),
              ),
              const SizedBox(height: 17),
              Text(
                'Available: ${AppStoreScope.of(context).user?['balance'] ?? 0} Stars',
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              const SizedBox(height: 14),
              GoldButton(
                label: 'REVIEW AND SEND',
                onPressed: send,
                icon: Icons.send_rounded,
                busy: busy,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Transfers are applied by the server as one transaction and recorded in the Stars ledger.',
          style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.5),
        ),
      ],
    ),
  );
}
