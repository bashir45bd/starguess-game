import 'package:flutter/material.dart';

import '../app.dart';
import '../core/theme/app_theme.dart';
import '../features/info/notification_screen.dart';

int toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final s = value.toString().trim();
  final d = double.tryParse(s);
  return d != null ? d.toInt() : fallback;
}

double toDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  final s = value.toString().trim();
  return double.tryParse(s) ?? fallback;
}

num toNum(dynamic value, [num fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value;
  final s = value.toString().trim();
  return num.tryParse(s) ?? fallback;
}

class StarHeader extends StatelessWidget implements PreferredSizeWidget {
  const StarHeader({
    super.key,
    this.title,
    this.showBack = false,
    this.showWallet = true,
  });
  final String? title;
  final bool showBack;
  final bool showWallet;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : IconButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.stars_rounded, color: AppColors.gold),
            ),
      title: title == null
          ? const Text(
              'STARGUESS',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            )
          : Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        if (showWallet)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: .35),
                  ),
                ),
                child: Text(
                  '${store.user?['balance'] ?? 0} ★',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.muted,
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }
}

class StarBottomNav extends StatelessWidget {
  const StarBottomNav({super.key, required this.index, required this.onSelect});
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: index,
    onDestinationSelected: onSelect,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.sports_mma_outlined),
        selectedIcon: Icon(Icons.sports_mma),
        label: 'Play',
      ),
      NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: 'Wallet',
      ),
      NavigationDestination(
        icon: Icon(Icons.emoji_events_outlined),
        selectedIcon: Icon(Icons.emoji_events),
        label: 'Rank',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      color: AppColors.muted,
      fontSize: 10,
      letterSpacing: 1.25,
      fontWeight: FontWeight.w700,
    ),
  );
}

class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.arrow_forward_rounded, size: 17),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: .5,
          fontWeight: FontWeight.w900,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

void showAppMessage(
  BuildContext context,
  String message, {
  bool error = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error
          ? const Color(0xFF881337)
          : AppColors.surfaceRaised,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
