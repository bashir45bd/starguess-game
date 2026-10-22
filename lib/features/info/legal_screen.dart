import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.privacy});
  final bool privacy;
  @override
  Widget build(BuildContext context) {
    final sections = privacy
        ? const [
            (
              '1. Data collected',
              'Account email and username, wallet ledger entries, game events, and technical session metadata needed to run the service and resolve disputes.',
            ),
            (
              '2. Game and financial records',
              'Game history and Stars transactions are retained for integrity, accounting, fraud prevention, and support review.',
            ),
            (
              '3. Data access',
              'Administrators may access records according to assigned permissions. Sensitive administrative actions are logged.',
            ),
            (
              '4. Contact',
              'Add the platform privacy contact before publishing this policy.',
            ),
          ]
        : const [
            (
              '1. Skill-based play',
              'The game is a number deduction activity. The server determines game state, guess results, and outcomes.',
            ),
            (
              '2. Virtual Stars',
              'Stars are in-game virtual credits. No cash-out or real-money redemption is supported.',
            ),
            (
              '3. Fair play',
              'Attempts to exploit, automate, or manipulate the game or wallet may lead to account restrictions.',
            ),
            (
              '4. Match stakes and commission',
              'The entry stake, prize pool, and commission are displayed before joining and applied by the backend.',
            ),
            (
              '5. Operator details',
              'Replace this section with the approved business, jurisdiction, and support contact details before release.',
            ),
          ];
    return Scaffold(
      appBar: StarHeader(
        title: privacy ? 'Privacy Policy' : 'Terms of Service',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.$1.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    section.$2,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
