import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final tx = AppStoreScope.of(context).transactions;
    return Scaffold(
      appBar: const StarHeader(title: 'Star Transactions', showBack: true),
      body: tx.isEmpty
          ? const Center(
              child: Text(
                'No transactions yet.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in tx)
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.amber,
                      ),
                      title: Text(
                        '${item['type']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      subtitle: Text(
                        '${item['created_at'] ?? ''}\n${item['notes'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        '${item['amount']}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
