import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';
import 'game_room_screen.dart';

class QuickMatchScreen extends StatefulWidget {
  const QuickMatchScreen({super.key, this.initialModeId});
  final int? initialModeId;
  @override
  State<QuickMatchScreen> createState() => _QuickMatchScreenState();
}

class _QuickMatchScreenState extends State<QuickMatchScreen> {
  int? modeId;
  int rangeMax = 100;
  int entryFee = 25;
  bool busy = false;

  List<Map<String, dynamic>> get options {
    final store = AppStoreScope.of(context);
    return store.configurations
        .where(
          (item) =>
              (modeId == null || item['mode_id'] == modeId) &&
              (item['number_max'] == rangeMax) &&
              (item['entry_fee'] == entryFee),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    modeId = widget.initialModeId;
  }

  Future<void> launch() async {
    final store = AppStoreScope.of(context);
    final matches = options;
    if (matches.isEmpty) {
      return showAppMessage(
        context,
        'That game configuration is unavailable.',
        error: true,
      );
    }
    if (toInt(store.user?['balance']) < entryFee) {
      return showAppMessage(
        context,
        'You need $entryFee Stars to join this match.',
        error: true,
      );
    }
    setState(() => busy = true);
    try {
      final result = await store.games.quickMatch(
        toInt(matches.first['configuration_id']),
      );
      await store.refresh();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameRoomScreen(gameId: result['game_id'].toString()),
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
    final availableModes = store.modes;
    modeId ??= availableModes.isEmpty
        ? null
        : toInt(availableModes.first['mode_id']);
    Map<String, dynamic>? selectedMode;
    for (final mode in availableModes) {
      if (toInt(mode['mode_id']) == modeId) selectedMode = mode;
    }
    final rangeChoices =
        store.configurations
            .where((c) => toInt(c['mode_id']) == modeId)
            .map((c) => toInt(c['number_max']))
            .toSet()
            .toList()
          ..sort();
    final feeChoices =
        store.configurations
            .where((c) => toInt(c['mode_id']) == modeId && toInt(c['number_max']) == rangeMax)
            .map((c) => toInt(c['entry_fee']))
            .toSet()
            .toList()
          ..sort();
    if (!rangeChoices.contains(rangeMax) && rangeChoices.isNotEmpty) {
      rangeMax = rangeChoices.contains(100) ? 100 : rangeChoices.first;
    }
    if (!feeChoices.contains(entryFee) && feeChoices.isNotEmpty) {
      entryFee = feeChoices.contains(25) ? 25 : feeChoices.first;
    }
    final commissionPct = options.isEmpty
        ? 0.0
        : toDouble(options.first['commission_percentage']);
    final pool = entryFee * 2;
    final commission = (pool * commissionPct / 100).floor();
    return Scaffold(
      appBar: const StarHeader(title: 'Match Configuration', showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        children: [
          _step('1. SELECT DUEL MODE'),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final mode in availableModes)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _ChoiceTile(
                      label: '${mode['name']}',
                      selected: toInt(mode['mode_id']) == modeId,
                      onTap: () => setState(() {
                        modeId = toInt(mode['mode_id']);
                        rangeMax = 100;
                        entryFee = 25;
                      }),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _step('2. NUMBER RANGE'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final range in rangeChoices)
                _ChoicePill(
                  label: '1 – $range',
                  subtitle: range >= 500
                      ? 'PRO'
                      : range >= 100
                      ? 'HARD'
                      : range > 10
                      ? 'MEDIUM'
                      : 'EASY',
                  selected: range == rangeMax,
                  onTap: () => setState(() => rangeMax = range),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _step('3. ENTRY STAKE')),
              Text(
                'Balance: ${store.user?['balance'] ?? 0} ★',
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final fee in feeChoices)
                _ChoicePill(
                  label: '$fee ★',
                  selected: fee == entryFee,
                  onTap: () => setState(() => entryFee = fee),
                ),
            ],
          ),
          const SizedBox(height: 19),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: AppColors.gold,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'SERVER-VERIFIED POOL BREAKDOWN',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _BreakdownRow('Mode', '${selectedMode?['name'] ?? '—'}'),
                _BreakdownRow('Combined pool', '$pool ★'),
                _BreakdownRow(
                  'Commission (${commissionPct.toStringAsFixed(0)}%)',
                  '-$commission ★',
                ),
                const Divider(color: AppColors.border, height: 18),
                _BreakdownRow(
                  'Winner receives',
                  '${pool - commission} ★',
                  strong: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GoldButton(
            label: 'FIND OPPONENT  ·  $entryFee ★',
            onPressed: launch,
            icon: Icons.sports_mma_rounded,
            busy: busy,
          ),
          const SizedBox(height: 9),
          const Text(
            'Entry Stars are reserved by the server when matchmaking starts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _step(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      color: AppColors.gold,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.1,
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(11),
    child: Container(
      height: 62,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: .1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: selected ? AppColors.gold : AppColors.border),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: selected ? AppColors.gold : Colors.white,
        ),
      ),
    ),
  );
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(11),
    child: Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: .1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: selected ? AppColors.gold : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? AppColors.gold : Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 8, color: AppColors.muted),
            ),
        ],
      ),
    ),
  );
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow(this.label, this.value, {this.strong = false});
  final String label, value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: strong ? Colors.white : AppColors.muted,
              fontWeight: strong ? FontWeight.w800 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: strong ? 13 : 10,
            color: strong ? AppColors.green : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
