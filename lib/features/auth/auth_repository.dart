import '../../core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this.api);
  final ApiClient api;

  Future<Map<String, dynamic>> currentUser() async =>
      (await api.get('/user/me'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await api.post('/user/auth/login', {
      'email': email,
      'password': password,
    });
    api.token = response['data']['token'] as String;
    return Map<String, dynamic>.from(response['data']['user'] as Map);
  }

  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    final res = await api.post('/user/auth/email-verification/send', {'email': email});
    return Map<String, dynamic>.from((res['data'] as Map?) ?? {});
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    final response = await api.post('/user/auth/email-verification/verify', {
      'email': email,
      'code': code,
    });
    api.token = response['data']['token'] as String;
    return Map<String, dynamic>.from(response['data']['user'] as Map);
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    final response = await api.post('/user/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      if (referralCode != null && referralCode.isNotEmpty)
        'referral_code': referralCode,
    });
    final data = Map<String, dynamic>.from(response['data'] as Map);
    api.token = data['token'] as String?;
    return data;
  }

  Future<void> signOut() async {
    try {
      await api.post('/user/auth/logout');
    } finally {
      api.token = null;
    }
  }
}
