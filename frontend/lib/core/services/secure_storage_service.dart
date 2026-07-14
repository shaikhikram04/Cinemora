import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _welcomeSeenKey = 'has_seen_welcome';

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

  /// Drops the session but keeps [_welcomeSeenKey] — a user whose session ended
  /// belongs on the login screen, not back at the first-run welcome carousel.
  Future<void> clearSession() => Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
      ]);

  Future<bool> getHasSeenWelcome() async {
    final value = await _storage.read(key: _welcomeSeenKey);
    return value == 'true';
  }

  Future<void> setHasSeenWelcome() =>
      _storage.write(key: _welcomeSeenKey, value: 'true');
}
