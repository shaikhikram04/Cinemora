import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class SecureStorageService {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _welcomeSeenKey = 'has_seen_welcome';
  static const _cachedUserKey = 'cached_user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens(String access, String refresh) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: access),
      _storage.write(key: _refreshKey, value: refresh),
    ]);
  }

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessKey, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clearAll() => _storage.deleteAll();

  /// The last known signed-in user, kept so a launch with no network can
  /// restore an identity instead of bouncing the user to the login screen.
  /// Always re-validated against `/auth/me` as soon as the network allows.
  Future<void> saveCachedUser(UserModel user) =>
      _storage.write(key: _cachedUserKey, value: jsonEncode(user.toJson()));

  Future<UserModel?> getCachedUser() async {
    final raw = await _storage.read(key: _cachedUserKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A cache written by an older schema is worthless, not fatal.
      await _storage.delete(key: _cachedUserKey);
      return null;
    }
  }

  /// Drops the session but keeps [_welcomeSeenKey] — a user whose session ended
  /// belongs on the login screen, not back at the first-run welcome carousel.
  /// The cached user goes with the session: it must never outlive the tokens it
  /// was fetched with.
  Future<void> clearSession() => Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
        _storage.delete(key: _cachedUserKey),
      ]);

  Future<bool> getHasSeenWelcome() async {
    final value = await _storage.read(key: _welcomeSeenKey);
    return value == 'true';
  }

  Future<void> setHasSeenWelcome() =>
      _storage.write(key: _welcomeSeenKey, value: 'true');
}
