import '../network/api_client.dart';

const _contentTypeToEnum = {
  'Movies': 'movies',
  'Web Series': 'series',
  'Anime': 'anime',
  'Documentaries': 'documentaries',
};

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<void> updatePreferences({
    required List<String> contentTypes,
    required List<String> genres,
    required List<String> languages,
  }) async {
    await _apiClient.dio.put('/users/preferences', data: {
      'contentTypes': contentTypes.map((c) => _contentTypeToEnum[c] ?? c).toList(),
      'genres': genres,
      'languages': languages,
    });
  }
}
