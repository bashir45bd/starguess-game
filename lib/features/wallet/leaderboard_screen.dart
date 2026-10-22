import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String period = 'weekly';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      await AppStoreScope.of(context).loadLeaderboard(period);
    } catch (error) {
      if (mounted) showAppMessage(context, error.toString(), error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return Scaffold(
      appBar: const StarHeader(title: 'Leaderboard'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  for (final key in ['daily', 'weekly', 'all'])
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() => period = key);
                          load();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: period == key
                                ? AppColors.gold
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            key == 'all' ? 'ALL TIME' : key.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: period == key
                                  ? AppColors.background
                                  : AppColors.muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: loading && store.leaderboard.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : RefreshIndicator(
                    onRefresh: load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        if (store.leaderboard.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 45),
                            child: Text(
                              'No leaderboard results yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        for (
                          var index = 0;
                          index < store.leaderboard.length;
                          index++
                        )
                          _RankRow(
                            rank: index + 1,
                            player: store.leaderboard[index],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.player});
  final int rank;
  final Map<String, dynamic> player;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: rank == 1
            ? AppColors.gold.withValues(alpha: .17)
            : AppColors.border,
        child: Text(
          '$rank',
          style: TextStyle(
            color: rank == 1 ? AppColors.gold : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
        ),
      ),
      title: Text(
        '${player['username']}',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      ),
      subtitle: Text(
        '${player['games_won'] ?? 0} wins · ${player['win_rate'] ?? 0}% win rate',
        style: const TextStyle(color: AppColors.muted, fontSize: 9),
      ),
      trailing: Text(
        '${player['total_stars_won'] ?? 0} ★',
        style: const TextStyle(
          color: AppColors.gold,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    ),
  );
}
