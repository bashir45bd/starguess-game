import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';
import 'buy_stars_screen.dart';
import 'transaction_history_screen.dart';
import 'transfer_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final wallet = store.walletData?['wallet'] as Map<String, dynamic>? ?? {};
    final transactions = store.transactions;
    return Scaffold(
      appBar: const StarHeader(title: 'Stars Vault & Wallet'),
      body: RefreshIndicator(
        onRefresh: store.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFBBF24),
                    Color(0xFFF59E0B),
                    Color(0xFFD97706),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: .12),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'AVAILABLE STARS BALANCE',
                          style: TextStyle(
                            color: Color(0xB3030712),
                            fontSize: 9,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.background.withValues(alpha: .7),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'LEDGER SECURED',
                        style: TextStyle(
                          color: AppColors.background.withValues(alpha: .7),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${wallet['balance'] ?? store.user?['balance'] ?? 0}',
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 39,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'STARS',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Virtual in-game credit for prediction stakes and rewards.',
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: .82),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _WalletAction(
                          title: 'Add Stars',
                          icon: Icons.add_circle_outline,
                          solid: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BuyStarsScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _WalletAction(
                          title: 'Send Stars',
                          icon: Icons.send_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TransferScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _CategoryTile(
                    'WON IN DUELS',
                    '+${wallet['won_balance'] ?? 0} ★',
                    AppColors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CategoryTile(
                    'PURCHASED',
                    '${wallet['purchased_balance'] ?? 0} ★',
                    AppColors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _CategoryTile(
                    'BONUS',
                    '${wallet['bonus_balance'] ?? 0} ★',
                    AppColors.gold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CategoryTile(
                    'TRANSFERRED',
                    '${wallet['transferred_balance'] ?? 0} ★',
                    const Color(0xFFFB923C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: SectionLabel('Recent activity')),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionHistoryScreen(),
                    ),
                  ),
                  child: const Text(
                    'View all',
                    style: TextStyle(color: AppColors.gold, fontSize: 10),
                  ),
                ),
              ],
            ),
            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'No transactions yet.',
                  style: TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              )
            else
              for (final tx in transactions.take(6))
                Card(
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.gold.withValues(alpha: .1),
                      child: const Icon(
                        Icons.stars_rounded,
                        size: 15,
                        color: AppColors.gold,
                      ),
                    ),
                    title: Text(
                      '${tx['type']}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      '${tx['created_at'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.muted,
                      ),
                    ),
                    trailing: Text(
                      '${toNum(tx['amount']) > 0 ? '+' : ''}${tx['amount']} ★',
                      style: TextStyle(
                        fontSize: 10,
                        color: toNum(tx['amount']) >= 0
                            ? AppColors.green
                            : const Color(0xFFFB7185),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.title,
    required this.icon,
    required this.onTap,
    this.solid = false,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool solid;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(
      icon,
      size: 15,
      color: solid ? AppColors.gold : AppColors.background,
    ),
    label: Text(
      title,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: solid ? Colors.white : AppColors.background,
      ),
    ),
    style: OutlinedButton.styleFrom(
      backgroundColor: solid ? AppColors.background : Colors.white24,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    ),
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(this.label, this.value, this.color);
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 8,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: 'monospace',
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
