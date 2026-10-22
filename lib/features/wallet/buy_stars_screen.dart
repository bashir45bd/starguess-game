import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app.dart';
import '../../core/app_store.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class BuyStarsScreen extends StatefulWidget {
  const BuyStarsScreen({super.key});

  @override
  State<BuyStarsScreen> createState() => _BuyStarsScreenState();
}

class _BuyStarsScreenState extends State<BuyStarsScreen> {
  final _phone = TextEditingController();
  String? _pendingPayment;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _buy(Map<String, dynamic> package) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final store = AppStoreScope.of(context);
      final payment = await store.wallet.startPayment(
        toInt(package['package_id']),
        _phone.text.trim(),
      );
      final uri = Uri.tryParse(payment['checkout_url']?.toString() ?? '');
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        throw Exception('The secure checkout link is invalid.');
      }
      _pendingPayment = payment['payment_id']?.toString();
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw Exception('Could not open the payment page.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete checkout, then return here.')),
      );
      await _waitForPayment(store);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _waitForPayment(AppStore store) async {
    final id = _pendingPayment;
    if (id == null) return;
    for (var attempt = 0; attempt < 40 && mounted; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 3));
      try {
        final status = await store.wallet.paymentStatus(id);
        if (status['status'] == 'SUCCESS') {
          _pendingPayment = null;
          await store.refresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment verified. Stars added.')),
            );
          }
          return;
        }
        if (status['status'] == 'FAILED' || status['status'] == 'CANCELLED') {
          _pendingPayment = null;
          return;
        }
      } catch (_) {
        // A temporary connectivity failure leaves the server-side payment pending.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return Scaffold(
      appBar: const StarHeader(title: 'Stars Store', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/images/store_stars_vault_1791401352917_min.jpg',
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Choose a Stars package',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Secure checkout by SSLCommerz. Stars are added after server verification.',
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Bangladesh mobile number',
              hintText: '01XXXXXXXXX',
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          const SizedBox(height: 10),
          if (_pendingPayment != null)
            OutlinedButton.icon(
              onPressed: () async {
                final id = _pendingPayment;
                if (id == null) return;
                try {
                  final status = await store.wallet.paymentStatus(id);
                  if (status['status'] == 'SUCCESS') {
                    _pendingPayment = null;
                    await store.refresh();
                    if (mounted) setState(() {});
                  }
                } catch (_) {}
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Check pending payment'),
            ),
          for (final package in store.packages)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.gold,
                  size: 28,
                ),
                title: Text(
                  '${package['name']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  '${package['stars']} Stars${toInt(package['bonus_stars']) > 0 ? ' + ${package['bonus_stars']} bonus' : ''}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 9),
                ),
                trailing: FilledButton(
                  onPressed: _busy ? null : () => _buy(package),
                  child: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '${(toDouble(package['price_cents']) / 100).toStringAsFixed(2)} ${package['currency']}',
                        ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'The payment provider returns to StarGuess after checkout. Keep the app open briefly while the verified result syncs.',
            style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.5),
          ),
        ],
      ),
    );
  }
}
