import 'package:flutter/material.dart';

import '../../shared/widgets.dart';
import '../match/quick_match_screen.dart';
import '../profile/profile_screen.dart';
import '../wallet/leaderboard_screen.dart';
import '../wallet/wallet_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const QuickMatchScreen(),
      const WalletScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: StarBottomNav(
        index: index,
        onSelect: (value) => setState(() => index = value),
      ),
    );
  }
}
