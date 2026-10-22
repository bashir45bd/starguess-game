import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';
import '../history/game_history_screen.dart';
import '../info/help_screen.dart';
import '../info/legal_screen.dart';
import '../info/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final user = store.user ?? {};
    final played = toInt(user['games_played']);
    final won = toInt(user['games_won']);
    final winRate = played == 0 ? 0 : (won * 100 / played).round();
    return Scaffold(
      appBar: const StarHeader(title: 'Player Profile'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.gold.withValues(alpha: .12),
                  child: Text(
                    '${user['username'] ?? 'S'}'.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '@${user['username'] ?? 'player'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user['email'] ?? ''}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  children: [
                    Chip(
                      avatar: const Icon(
                        Icons.stars,
                        color: AppColors.gold,
                        size: 14,
                      ),
                      label: Text(
                        '${user['rating'] ?? 1000} ELO',
                        style: const TextStyle(fontSize: 9),
                      ),
                      side: const BorderSide(color: AppColors.border),
                      backgroundColor: AppColors.surfaceRaised,
                    ),
                    Chip(
                      avatar: const Icon(
                        Icons.local_fire_department,
                        color: AppColors.indigo,
                        size: 14,
                      ),
                      label: Text(
                        '${user['win_streak'] ?? 0} streak',
                        style: const TextStyle(fontSize: 9),
                      ),
                      side: const BorderSide(color: AppColors.border),
                      backgroundColor: AppColors.surfaceRaised,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(child: _Stat('WIN RATE', '$winRate%', AppColors.gold)),
              const SizedBox(width: 8),
              Expanded(child: _Stat('DUELS WON', '$won', AppColors.green)),
              const SizedBox(width: 8),
              Expanded(child: _Stat('PLAYED', '$played', Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          if (user['referral_code'] != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surface, Color(0xFF271A0B)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: .25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Invite friends and earn Stars',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        '+25 each',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Share your referral code with new players.',
                    style: TextStyle(color: AppColors.muted, fontSize: 9),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    '${user['referral_code']}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          _Link(
            icon: Icons.history,
            title: 'Match history',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GameHistoryScreen()),
            ),
          ),
          _Link(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          _Link(
            icon: Icons.help_outline,
            title: 'Game rules and support',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            ),
          ),
          _Link(
            icon: Icons.description_outlined,
            title: 'Terms of service',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalScreen(privacy: false),
              ),
            ),
          ),
          _Link(
            icon: Icons.lock_outline,
            title: 'Privacy policy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalScreen(privacy: true),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                await store.signOut();
              } catch (e) {
                if (context.mounted) {
                  showAppMessage(context, e.toString(), error: true);
                }
              }
            },
            icon: const Icon(Icons.logout, size: 16),
            label: const Text(
              'SIGN OUT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFDA4AF),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 7,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
      ],
    ),
  );
}

class _Link extends StatelessWidget {
  const _Link({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 7),
    child: ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(icon, color: AppColors.muted, size: 18),
      title: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.muted,
        size: 17,
      ),
    ),
  );
}
