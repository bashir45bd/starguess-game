import 'package:flutter/foundation.dart';

import '../features/auth/auth_repository.dart';
import '../features/match/game_repository.dart';
import '../features/wallet/wallet_repository.dart';

class AppStore extends ChangeNotifier {
  AppStore({required this.auth, required this.games, required this.wallet});
  final AuthRepository auth;
  final GameRepository games;
  final WalletRepository wallet;

  Map<String, dynamic>? user;
  Map<String, dynamic>? walletData;
  List<Map<String, dynamic>> modes = [];
  List<Map<String, dynamic>> configurations = [];
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> packages = [];
  List<Map<String, dynamic>> leaderboard = [];
  List<Map<String, dynamic>> gameHistory = [];
  bool busy = false;

  Future<void> signIn(String email, String password) async {
    busy = true;
    notifyListeners();
    try {
      user = await auth.signIn(email.trim(), password);
      await refresh();
    } catch (_) {
      user = null;
      auth.api.token = null;
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> register(
    String username,
    String email,
    String password,
    String referral,
  ) async {
    busy = true;
    notifyListeners();
    try {
      final account = await auth.register(
        username: username.trim(),
        email: email.trim(),
        password: password,
        referralCode: referral.trim(),
      );
      if (account['verification_required'] == true) {
        return account;
      }
      if (account['token'] is String) {
        auth.api.token = account['token'] as String;
      }
      user = Map<String, dynamic>.from(account['user'] as Map);
      await refresh();
      return null;
    } catch (_) {
      user = null;
      auth.api.token = null;
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendVerificationCode(String email) =>
      auth.sendVerificationCode(email.trim());

  Future<void> verifyEmail(String email, String code) async {
    busy = true;
    notifyListeners();
    try {
      user = await auth.verifyEmail(email.trim(), code.trim());
      await refresh();
    } catch (_) {
      user = null;
      auth.api.token = null;
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final results = await Future.wait<Object>([
      auth.currentUser(),
      wallet.getWallet(),
      games.getConfiguration(),
      wallet.getPackages(),
      games.getHistory(),
    ]);
    user = results[0] as Map<String, dynamic>;
    walletData = results[1] as Map<String, dynamic>;
    final gameConfiguration =
        results[2] as Map<String, List<Map<String, dynamic>>>;
    modes = gameConfiguration['modes']!;
    configurations = gameConfiguration['configurations']!;
    packages = results[3] as List<Map<String, dynamic>>;
    gameHistory = results[4] as List<Map<String, dynamic>>;
    final walletResult = walletData!;
    user = {...?user, 'balance': walletResult['wallet']?['balance'] ?? 0};
    transactions = (walletResult['transactions'] as List)
        .cast<Map<String, dynamic>>();
    notifyListeners();
  }

  Future<void> loadLeaderboard(String period) async {
    leaderboard = await wallet.getLeaderboard(period);
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } finally {
      user = null;
      walletData = null;
      notifyListeners();
    }
  }
}
