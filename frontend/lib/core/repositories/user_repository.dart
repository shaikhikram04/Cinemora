import 'package:dio/dio.dart';

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

  /// Uploads the picked image and returns the user with the new URL already
  /// persisted — the backend stores it on Cloudinary and writes the URL to
  /// Mongo in one request, so there's nothing left for the caller to save.
  Future<UserModel> _uploadImage(String path, String endpoint) async {
    try {
      final form = FormData.fromMap({
        'image': await MultipartFile.fromFile(path),
      });
      final res = await _apiClient.dio.post(endpoint, data: form);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      // Surfaces the backend's own reason (too large, wrong type) instead of a
      // bare DioException the cubit would flatten into "something went wrong".
      throw ApiClient.parseError(e);
    }
  }

  Future<UserModel> uploadAvatar(String path) =>
      _uploadImage(path, '/users/avatar');

  Future<UserModel> uploadCover(String path) =>
      _uploadImage(path, '/users/cover');

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
  }) async {
    await _apiClient.dio.put('/users/preferences', data: {
      if (contentTypes != null) 'contentTypes': contentTypes,
      if (genres != null) 'genres': genres,
      if (languages != null) 'languages': languages,
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
    required List<String> languages,
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
        'languages': languages,
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

  // ── Push notifications ────────────────────────────────────────────────────

  Future<void> updateFcmToken(String token) async {
    await _apiClient.dio.put('/users/fcm-token', data: {'fcmToken': token});
  }

  /// Reads the push opt-outs off the full profile — prefs live on the user
  /// document, and /auth/me is the only place the backend serves them.
  Future<NotificationPrefs> getNotificationPrefs() async {
    final res = await _apiClient.dio.get('/auth/me');
    return NotificationPrefs.fromJson(
        (res.data as Map<String, dynamic>)['notificationPrefs']
                as Map<String, dynamic>? ??
            const {});
  }

  Future<NotificationPrefs> updateNotificationPrefs({
    bool? pushNewRelease,
    bool? pushNewSeason,
  }) async {
    final res = await _apiClient.dio.put('/users/notification-prefs', data: {
      if (pushNewRelease != null) 'pushNewRelease': pushNewRelease,
      if (pushNewSeason != null) 'pushNewSeason': pushNewSeason,
    });
    return NotificationPrefs.fromJson(
        (res.data as Map<String, dynamic>)['notificationPrefs']
                as Map<String, dynamic>? ??
            const {});
  }
}

/// Push-channel opt-outs. The in-app inbox always fills regardless — these
/// only decide whether the backend's daily sweep sends an FCM push.
class NotificationPrefs {
  final bool pushNewRelease;
  final bool pushNewSeason;

  const NotificationPrefs({
    this.pushNewRelease = true,
    this.pushNewSeason = true,
  });

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      NotificationPrefs(
        pushNewRelease: json['pushNewRelease'] as bool? ?? true,
        pushNewSeason: json['pushNewSeason'] as bool? ?? true,
      );
}
