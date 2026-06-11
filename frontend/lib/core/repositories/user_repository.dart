import '../models/library_entry_model.dart';
import '../models/library_stats_model.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<UserModel> getMe() async {
    final res = await _apiClient.dio.get('/auth/me');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    required String name,
    String? username,
    String? bio,
    String? avatar,
    String? framePoster,
  }) async {
    await _apiClient.dio.put('/users/profile', data: {
      'name': name,
      if (username != null) 'username': username,
      if (bio != null) 'bio': bio,
      if (avatar != null) 'avatar': avatar,
      if (framePoster != null) 'framePoster': framePoster,
    });
    return getMe();
  }

  Future<UserModel> updatePreferences({
    List<String>? contentTypes,
    List<String>? genres,
    List<String>? languages,
    String? era,
  }) async {
    await _apiClient.dio.put('/users/preferences', data: {
      if (contentTypes != null) 'contentTypes': contentTypes,
      if (genres != null) 'genres': genres,
      if (languages != null) 'languages': languages,
      if (era != null) 'era': era,
    });
    return getMe();
  }

  // Saves profile fields and taste preferences in parallel, then returns the
  // refreshed user. Used by EditProfileCubit.save().
  Future<UserModel> updateProfileAndPreferences({
    required String name,
    String? username,
    String? bio,
    required List<String> genres,
    required String language,
    required String era,
    List<String>? contentTypes,
  }) async {
    await Future.wait([
      _apiClient.dio.put('/users/profile', data: {
        'name': name,
        'username': username,
        'bio': bio,
      }),
      _apiClient.dio.put('/users/preferences', data: {
        'genres': genres,
        'languages': [language],
        'era': era,
        if (contentTypes != null) 'contentTypes': contentTypes,
      }),
    ]);
    return getMe();
  }

  Future<LibraryStatsModel> getLibraryStats() async {
    final res = await _apiClient.dio.get('/library/stats');
    return LibraryStatsModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<LibraryEntryModel>> getLibraryEntries({
    String? status,
    String sort = 'updatedAt',
  }) async {
    final res = await _apiClient.dio.get('/library', queryParameters: {
      if (status != null) 'status': status,
      'sort': sort,
    });
    final list = res.data as List;
    return list
        .map((e) => LibraryEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
