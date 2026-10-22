import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';
import 'game_room_screen.dart';

class PrivateMatchScreen extends StatefulWidget {
  const PrivateMatchScreen({super.key});
  @override
  State<PrivateMatchScreen> createState() => _PrivateMatchScreenState();
}

class _PrivateMatchScreenState extends State<PrivateMatchScreen> {
  bool joining = false;
  bool busy = false;
  int? modeId;
  int rangeMax = 100;
  int entryFee = 10;
  final code = TextEditingController();

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  Future<void> createRoom() async {
    final store = AppStoreScope.of(context);
    final matches = store.configurations
        .where(
          (c) =>
              c['mode_id'] == modeId &&
              c['number_max'] == rangeMax &&
              c['entry_fee'] == entryFee,
        )
        .toList();
    final match = matches.isEmpty ? null : matches.first;
    if (match == null) {
      return showAppMessage(
        context,
        'Choose an available game configuration.',
        error: true,
      );
    }
    setState(() => busy = true);
    try {
      final data = await store.games.createPrivateMatch(
        toInt(match['configuration_id']),
      );
      await store.refresh();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Private room ready'),
          content: SelectableText(
            'Invite code\n\n${data['invite_code']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 22,
              color: AppColors.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameRoomScreen(gameId: data['game_id'].toString()),
        ),
      );
    } catch (e) {
      if (mounted) showAppMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> joinRoom() async {
    final store = AppStoreScope.of(context);
    setState(() => busy = true);
    try {
      final data = await store.games.joinPrivateMatch(
        code.text.trim().toUpperCase(),
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameRoomScreen(gameId: data['game_id'].toString()),
        ),
      );
      await store.refresh();
    } catch (e) {
      if (mounted) showAppMessage(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    modeId ??= store.modes.isEmpty ? null : toInt(store.modes.first['mode_id']);
    final selectedConfigurations = store.configurations
        .where((c) => toInt(c['mode_id']) == modeId)
        .toList();
    final ranges =
        selectedConfigurations
            .map((c) => toInt(c['number_max']))
            .toSet()
            .toList()
          ..sort();
    final fees =
        selectedConfigurations
            .where((c) => toInt(c['number_max']) == rangeMax)
            .map((c) => toInt(c['entry_fee']))
            .toSet()
            .toList()
          ..sort();
    return Scaffold(
      appBar: const StarHeader(title: 'Private Match', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _tab(
                    'CREATE ROOM',
                    !joining,
                    () => setState(() => joining = false),
                  ),
                ),
                Expanded(
                  child: _tab(
                    'JOIN BY CODE',
                    joining,
                    () => setState(() => joining = true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (joining) ...[
            const Icon(Icons.key_rounded, size: 46, color: AppColors.indigo),
            const SizedBox(height: 9),
            const Text(
              'Enter your invite code',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            const Text(
              'Ask the room host for their private code.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              maxLength: 10,
              decoration: const InputDecoration(
                hintText: 'STAR-XXXX',
                counterText: '',
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
            ),
            const SizedBox(height: 14),
            GoldButton(
              label: 'JOIN PRIVATE GAME',
              onPressed: joinRoom,
              icon: Icons.login_rounded,
              busy: busy,
            ),
          ] else ...[
            const SectionLabel('Duel mode'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              children: [
                for (final mode in store.modes)
                  ChoiceChip(
                    label: Text(
                      '${mode['name']}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    selected: modeId == toInt(mode['mode_id']),
                    onSelected: (_) => setState(() {
                      modeId = toInt(mode['mode_id']);
                      rangeMax = 100;
                      entryFee = 10;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 17),
            const SectionLabel('Number range'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              children: [
                for (final range in ranges)
                  ChoiceChip(
                    label: Text(
                      '1 – $range',
                      style: const TextStyle(fontSize: 10),
                    ),
                    selected: rangeMax == range,
                    onSelected: (_) => setState(() => rangeMax = range),
                  ),
              ],
            ),
            const SizedBox(height: 17),
            const SectionLabel('Entry stake'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              children: [
                for (final fee in fees)
                  ChoiceChip(
                    label: Text('$fee ★', style: const TextStyle(fontSize: 10)),
                    selected: entryFee == fee,
                    onSelected: (_) => setState(() => entryFee = fee),
                  ),
              ],
            ),
            const SizedBox(height: 17),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'A private invite code is generated on the server. Entry Stars are deducted only after both players are matched.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GoldButton(
              label: 'CREATE PRIVATE DUEL  ·  $entryFee ★',
              onPressed: createRoom,
              icon: Icons.people_outline,
              busy: busy,
            ),
          ],
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: active ? AppColors.background : AppColors.muted,
        ),
      ),
    ),
  );
}
