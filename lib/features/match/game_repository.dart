import '../../core/network/api_client.dart';

class GameRepository {
  GameRepository(this.api);
  final ApiClient api;

  Future<Map<String, List<Map<String, dynamic>>>> getConfiguration() async {
    final data =
        (await api.get('/user/config'))['data'] as Map<String, dynamic>;
    return {
      'modes': (data['modes'] as List).cast<Map<String, dynamic>>(),
      'configurations': (data['configurations'] as List)
          .cast<Map<String, dynamic>>(),
    };
  }

  Future<Map<String, dynamic>> quickMatch(int configurationId) async =>
      (await api.post('/user/games/quick', {
            'configuration_id': configurationId,
          }))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> createPrivateMatch(int configurationId) async =>
      (await api.post('/user/games/private', {
            'configuration_id': configurationId,
          }))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> joinPrivateMatch(String inviteCode) async =>
      (await api.post('/user/games/join', {'invite_code': inviteCode}))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> getGame(String id) async =>
      (await api.get('/user/games/$id'))['data'] as Map<String, dynamic>;

  Future<Map<String, dynamic>> commitSecret(String id, int number) async =>
      (await api.post('/user/games/$id/secret', {'number': number}))['data']
          as Map<String, dynamic>;

  Future<Map<String, dynamic>> submitGuess(String id, int number) async =>
      (await api.post('/user/games/$id/guess', {'number': number}))['data']
          as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> getHistory() async =>
      ((await api.get('/user/games'))['data'] as List)
          .cast<Map<String, dynamic>>();
}
