import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sound = true;
  String timezone = 'Asia/Dhaka';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const StarHeader(title: 'Settings', showBack: true),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: SwitchListTile(
            value: sound,
            activeTrackColor: AppColors.gold,
            title: const Text(
              'Game sound effects',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Audio and haptic feedback',
              style: TextStyle(fontSize: 9, color: AppColors.muted),
            ),
            onChanged: (value) => setState(() => sound = value),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Display time zone'),
              const SizedBox(height: 5),
              const Text(
                'All timestamps are stored as UTC.',
                style: TextStyle(color: AppColors.muted, fontSize: 9),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Asia/Dhaka', label: Text('Dhaka')),
                  ButtonSegment(value: 'UTC', label: Text('UTC')),
                ],
                selected: {timezone},
                onSelectionChanged: (value) =>
                    setState(() => timezone = value.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: const ListTile(
            leading: Icon(Icons.security_outlined, color: AppColors.green),
            title: Text(
              'Account sessions',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Your current session is authenticated by the StarGuess server.',
              style: TextStyle(color: AppColors.muted, fontSize: 9),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Center(
          child: Text(
            'StarGuess · Mobile client',
            style: TextStyle(color: AppColors.muted, fontSize: 9),
          ),
        ),
      ],
    ),
  );
}
