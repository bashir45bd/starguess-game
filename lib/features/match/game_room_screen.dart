import 'dart:async';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class GameRoomScreen extends StatefulWidget {
  const GameRoomScreen({super.key, required this.gameId});
  final String gameId;
  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  final input = TextEditingController();
  Timer? polling;
  Map<String, dynamic>? snapshot;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    refreshGame();
    polling = Timer.periodic(const Duration(seconds: 2), (_) => refreshGame());
  }

  @override
  void dispose() {
    polling?.cancel();
    input.dispose();
    super.dispose();
  }

  Future<void> refreshGame() async {
    try {
      final data = await AppStoreScope.of(context).games.getGame(widget.gameId);
      if (mounted) {
        setState(() {
          snapshot = data;
          error = null;
        });
      }
      if (data['game']?['status'] == 'COMPLETED') polling?.cancel();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> submitNumber() async {
    final number = int.tryParse(input.text.trim());
    if (number == null) return setState(() => error = 'Enter a whole number.');
    final role = snapshot?['role'];
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (role == 'SECRET_OWNER') {
        await AppStoreScope.of(
          context,
        ).games.commitSecret(widget.gameId, number);
      } else {
        await AppStoreScope.of(
          context,
        ).games.submitGuess(widget.gameId, number);
      }
      input.clear();
      await refreshGame();
      if (mounted) await AppStoreScope.of(context).refresh();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = snapshot;
    final game = data?['game'] as Map<String, dynamic>?;
    final status = game?['status']?.toString() ?? 'LOADING';
    final role = data?['role']?.toString();
    final committed = data?['secret_committed'] == true;
    final myTurn = data?['your_turn'] == true;
    final range = data?['valid_range'] as Map<String, dynamic>? ?? const {};
    final attempts = data?['attempts'] as List? ?? const [];
    final gameOver = status == 'COMPLETED';
    final enteringSecret =
        role == 'SECRET_OWNER' &&
        status == 'IN_PROGRESS' &&
        !committed &&
        myTurn;
    final enteringGuess = role == 'GUESSER' && committed && myTurn && !gameOver;
    final title = status == 'WAITING'
        ? 'SEARCHING FOR OPPONENT…'
        : enteringSecret
        ? 'CHOOSE YOUR SECRET'
        : enteringGuess
        ? 'YOUR TURN TO GUESS'
        : gameOver
        ? 'MATCH COMPLETE'
        : 'WAITING FOR OPPONENT';
    final winner =
        gameOver &&
        game?['winner_id'] != null &&
        game?['winner_id'] == AppStoreScope.of(context).user?['user_id'];
    return Scaffold(
      appBar: StarHeader(
        title: '${game?['mode'] ?? '1v1 Duel'}',
        showBack: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshGame,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF111827), Color(0xFF171B2B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.green,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status == 'WAITING'
                            ? 'MATCHMAKING QUEUE'
                            : 'AUTHORITATIVE GAME STATE',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 9,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: .1),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: .4),
                      ),
                    ),
                    child: Icon(
                      gameOver
                          ? (winner ? Icons.emoji_events : Icons.sports_mma)
                          : Icons.sports_mma,
                      color: AppColors.gold,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Range ${range['min'] ?? game?['number_min'] ?? '—'} – ${range['max'] ?? game?['number_max'] ?? '—'}  ·  ${game?['entry_fee'] ?? '—'} ★ entry',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                  if (status == 'WAITING') ...[
                    const SizedBox(height: 14),
                    const LinearProgressIndicator(
                      color: AppColors.gold,
                      backgroundColor: AppColors.border,
                    ),
                  ],
                  if (gameOver) ...[
                    const SizedBox(height: 10),
                    Text(
                      winner
                          ? 'VICTORY  ·  +${game?['prize_amount'] ?? 0} ★'
                          : 'The match is over',
                      style: TextStyle(
                        color: winner ? AppColors.green : AppColors.muted,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    if (game?['secret_revealed_number'] != null)
                      Text(
                        'Secret number: ${game?['secret_revealed_number']}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (enteringSecret || enteringGuess) ...[
              const SizedBox(height: 19),
              Text(
                enteringSecret
                    ? 'Set a secret between ${range['min']} and ${range['max']}. Your opponent will not see it until the match ends.'
                    : 'Enter a guess from ${range['min']} through ${range['max']}. Higher or lower is calculated by the server.',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: input,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: enteringSecret
                      ? 'Your secret number'
                      : 'Your guess',
                  prefixIcon: const Icon(Icons.tag_rounded),
                ),
              ),
              const SizedBox(height: 10),
              GoldButton(
                label: enteringSecret ? 'COMMIT SECRET' : 'SUBMIT GUESS',
                onPressed: submitNumber,
                icon: enteringSecret
                    ? Icons.lock_outline
                    : Icons.arrow_upward_rounded,
                busy: busy,
              ),
            ],
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error!,
                  style: const TextStyle(
                    color: Color(0xFFFDA4AF),
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(height: 21),
            const SectionLabel('Attempt history'),
            const SizedBox(height: 8),
            if (attempts.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No guesses yet. The history will appear here.',
                  style: TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ),
            for (final attempt in attempts.reversed)
              Card(
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.gold.withValues(alpha: .12),
                    child: Text(
                      '${attempt['attempt_number']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  title: Text(
                    '${attempt['guess_number']}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  trailing: Text(
                    '${attempt['result']}',
                    style: TextStyle(
                      color: attempt['result'] == 'HIGHER'
                          ? AppColors.indigo
                          : attempt['result'] == 'LOWER'
                          ? const Color(0xFFFB923C)
                          : AppColors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            if (gameOver) ...[
              const SizedBox(height: 12),
              GoldButton(
                label: 'BACK TO HOME',
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                icon: Icons.home_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
