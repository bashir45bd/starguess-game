import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int open = 0;
  final questions = const [
    (
      'How does Higher/Lower work?',
      'The server compares every guess to the secret. A smaller number returns HIGHER, a larger number returns LOWER, and a match ends the game. Players cannot set this result.',
    ),
    (
      'How is the secret protected?',
      'The server creates a salted SHA-256 commitment before guessing begins. The secret and salt are revealed only after the match ends.',
    ),
    (
      'How does the valid range change?',
      'For example, 40 → HIGHER changes the minimum to 41. Then 80 → LOWER changes the maximum to 79. The backend rejects guesses outside the current range.',
    ),
    (
      'How is the payout calculated?',
      'Both entry stakes form the pool. The configured server commission is deducted, and the winner receives the rest. Each wallet movement is recorded in the ledger.',
    ),
    (
      'Can Stars be cashed out?',
      'No cash-out feature is implemented. Stars are virtual in-game credits.',
    ),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const StarHeader(title: 'Rules & Support', showBack: true),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.indigo.withValues(alpha: .3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.indigo,
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'The backend is the authority for game state, valid guesses, results, and wallet balances.',
                  style: TextStyle(fontSize: 10, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const SectionLabel('Frequently asked questions'),
        const SizedBox(height: 8),
        for (var i = 0; i < questions.length; i++)
          Card(
            child: ExpansionTile(
              title: Text(
                questions[i].$1,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              initiallyExpanded: i == open,
              onExpansionChanged: (value) {
                if (value) setState(() => open = i);
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Text(
                    questions[i].$2,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'Need help with a match, payment, or missing Stars? Contact the platform support team from the official support channel.',
          style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.5),
        ),
      ],
    ),
  );
}
