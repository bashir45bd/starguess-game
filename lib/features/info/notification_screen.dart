import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> items = [];
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final response = await AppStoreScope.of(
        context,
      ).auth.api.get('/user/notifications');
      if (mounted) {
        setState(
          () => items = (response['data'] as List).cast<Map<String, dynamic>>(),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const StarHeader(title: 'Notifications', showBack: true),
    body: error != null
        ? Center(
            child: Text(
              error!,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          )
        : items.isEmpty
        ? const Center(
            child: Text(
              'No notifications right now.',
              style: TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          )
        : RefreshIndicator(
            onRefresh: load,
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                for (final item in items)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        item['type'] == 'REWARD'
                            ? Icons.card_giftcard
                            : item['type'] == 'GAME'
                            ? Icons.sports_mma
                            : Icons.info_outline,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      title: Text(
                        '${item['title']}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        '${item['message']}\n${item['created_at']}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 9,
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  ),
              ],
            ),
          ),
  );
}
