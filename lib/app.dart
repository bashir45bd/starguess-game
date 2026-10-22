import 'package:flutter/material.dart';

import 'core/app_store.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/auth_screen.dart';
import 'features/home/main_shell.dart';
import 'features/match/game_repository.dart';
import 'features/wallet/wallet_repository.dart';

class StarGuessApp extends StatefulWidget {
  const StarGuessApp({super.key});

  @override
  State<StarGuessApp> createState() => _StarGuessAppState();
}

class _StarGuessAppState extends State<StarGuessApp> {
  late final ApiClient api;
  late final AppStore store;

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    store = AppStore(
      auth: AuthRepository(api),
      games: GameRepository(api),
      wallet: WalletRepository(api),
    );
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppStoreScope(
    store: store,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StarGuess',
      theme: AppTheme.dark,
      home: AnimatedBuilder(
        animation: store,
        builder: (context, _) =>
            store.user == null ? const AuthScreen() : const MainShell(),
      ),
    ),
  );
}

class AppStoreScope extends InheritedNotifier<AppStore> {
  const AppStoreScope({
    required AppStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStoreScope>();
    assert(scope != null, 'AppStoreScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
