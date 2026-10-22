import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final user = store.user ?? {};
    final played = toInt(user['games_played']);
    final won = toInt(user['games_won']);

    return Scaffold(
      appBar: const StarHeader(title: 'Match History', showBack: true),
      body: RefreshIndicator(
        onRefresh: store.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Competitive record'),
                        const SizedBox(height: 5),
                        Text(
                          '$won W / ${played - won} L',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SectionLabel('Stars earned'),
                      const SizedBox(height: 5),
                      Text(
                        '+${user['total_stars_won'] ?? 0} ★',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (store.gameHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  'No matches yet. Start a Quick Match to begin your record.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              )
            else
              for (final game in store.gameHistory)
                _HistoryCard(game: game, userId: user['user_id']),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.game, required this.userId});
  final Map<String, dynamic> game;
  final Object? userId;

  @override
  Widget build(BuildContext context) {
    final won = game['winner_id'] == userId;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: won
              ? AppColors.gold.withValues(alpha: .12)
              : AppColors.border,
          child: Icon(
            won ? Icons.emoji_events : Icons.sports_mma,
            color: won ? AppColors.gold : AppColors.muted,
            size: 15,
          ),
        ),
        title: Text(
          '${game['mode'] ?? '1v1 match'} · ${game['status']}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          'Range 1–${game['number_max']} · ${game['total_attempts']} attempts · ${game['created_at']}',
          style: const TextStyle(color: AppColors.muted, fontSize: 8),
        ),
        trailing: Text(
          '${won ? '+' : '-'}${won ? game['prize_amount'] : game['entry_fee']} ★',
          style: TextStyle(
            color: won ? AppColors.green : const Color(0xFFFB7185),
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
