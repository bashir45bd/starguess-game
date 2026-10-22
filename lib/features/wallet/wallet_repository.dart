import '../../core/network/api_client.dart';

class WalletRepository {
  WalletRepository(this.api);
  final ApiClient api;

  Future<Map<String, dynamic>> getWallet() async =>
      (await api.get('/user/wallet'))['data'] as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> getPackages() async =>
      ((await api.get('/user/star-packages'))['data'] as List)
          .cast<Map<String, dynamic>>();

  Future<Map<String, dynamic>> transfer(String recipient, int stars) async =>
      (await api.post('/user/transfers', {
            'recipient': recipient,
            'amount': stars,
          }))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> startPayment(
    int packageId,
    String phone,
  ) async =>
      (await api.post('/user/payments/sslcommerz/initiate', {
            'package_id': packageId,
            'phone': phone,
          }))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> paymentStatus(String paymentId) async =>
      (await api.get('/user/payments/$paymentId'))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> getLeaderboard(String period) async =>
      ((await api.get('/user/leaderboard?period=$period'))['data'] as List)
          .cast<Map<String, dynamic>>();
}
