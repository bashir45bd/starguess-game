import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';
import '../match/private_match_screen.dart';
import '../match/quick_match_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool claiming = false;

  Future<void> claimReward() async {
    final store = AppStoreScope.of(context);
    setState(() => claiming = true);
    try {
      final result = await store.auth.api.post('/user/daily-rewards/claim');
      await store.refresh();
      if (mounted) {
        showAppMessage(
          context,
          'You claimed ${result['data']['reward']} Stars!',
        );
      }
    } catch (e) {
      if (mounted) showAppMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => claiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final user = store.user ?? {};
    final claimToday =
        user['last_daily_claim'] == null ||
        user['last_daily_claim'].toString().substring(0, 10) !=
            DateTime.now().toUtc().toIso8601String().substring(0, 10);
    return Scaffold(
      appBar: const StarHeader(),
      body: RefreshIndicator(
        onRefresh: store.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/game_hero_banner_1791401330601_min.jpg',
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xE6030712)],
                          stops: [0.12, 1],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIVE COMPETITIVE SEASON · SERVER VERIFIED',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.gold,
                              letterSpacing: .8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Predict. Deduce.\nOutsmart.',
                            style: TextStyle(
                              fontSize: 22,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Cryptographically secured 1v1 duels with Stars rewards.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _LaunchCard(
                    primary: true,
                    icon: Icons.sports_mma_rounded,
                    title: 'QUICK MATCH',
                    subtitle: 'Fast 1v1 duel finder',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuickMatchScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LaunchCard(
                    icon: Icons.people_alt_outlined,
                    title: 'PRIVATE ROOM',
                    subtitle: 'Challenge a friend',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivateMatchScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/daily_reward_chest_1791401340815_min.jpg',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Star Reward',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          claimToday
                              ? 'Ready to claim · Keep your streak.'
                              : 'Claimed today · Streak protected.',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: claimToday && !claiming ? claimReward : null,
                    child: Text(
                      claiming
                          ? '…'
                          : claimToday
                          ? 'Claim'
                          : 'Claimed',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 21),
            const SectionLabel('Game modes'),
            const SizedBox(height: 9),
            for (var i = 0; i < store.modes.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ModeCard(
                  index: i + 1,
                  mode: store.modes[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuickMatchScreen(
                        initialModeId: store.modes[i]['mode_id'] == null
                            ? null
                            : toInt(store.modes[i]['mode_id']),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickStat(
                    label: 'GAMES',
                    value: '${user['games_played'] ?? 0}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickStat(
                    label: 'WINS',
                    value: '${user['games_won'] ?? 0}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickStat(
                    label: 'STARS',
                    value: '${user['balance'] ?? 0}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                try {
                  await store.signOut();
                } catch (e) {
                  if (context.mounted) {
                    showAppMessage(context, e.toString(), error: true);
                  }
                }
              },
              icon: const Icon(Icons.logout, size: 15),
              label: const Text('Sign out', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool primary;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(17),
    child: Container(
      height: 102,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: primary
            ? const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: primary ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: primary ? AppColors.gold : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 21,
            color: primary ? AppColors.background : AppColors.indigo,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: primary ? AppColors.background : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: primary ? Colors.black54 : AppColors.muted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.index,
    required this.mode,
    required this.onTap,
  });
  final int index;
  final Map<String, dynamic> mode;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${mode['name']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mode['slug'] == 'reverse-1v1'
                      ? 'Opponent chooses · You deduce'
                      : 'Host chooses · Opponent deduces',
                  style: const TextStyle(color: AppColors.muted, fontSize: 9),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
        ],
      ),
    ),
  );
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 8,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );
}
