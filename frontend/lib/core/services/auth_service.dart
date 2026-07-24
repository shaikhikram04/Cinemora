import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../exceptions/app_exception.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import 'secure_storage_service.dart';

/// Outcome of a successful session restore. [fromCache] means the server was
/// unreachable and this identity came from local storage — it is good enough to
/// render the app, but should be re-validated once the network returns.
class RestoredSession {
  final UserModel user;
  final bool fromCache;

  const RestoredSession(this.user, {required this.fromCache});
}

class AuthService {
  final ApiClient _apiClient;
  final SecureStorageService _storage;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._apiClient, this._storage);

  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const PlatformSignInException('sign_in_cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user!.getIdToken();
      return _loginToBackend(idToken!);
    } on AppException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    } on PlatformException catch (e) {
      throw PlatformSignInException(e.code, e.message);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<UserModel> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final idToken = await userCredential.user!.getIdToken();
      return _loginToBackend(idToken!);
    } on AppException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    } on SignInWithAppleAuthorizationException catch (e) {
      final code = e.code == AuthorizationErrorCode.canceled
          ? 'sign_in_cancelled'
          : 'sign_in_failed';
      throw PlatformSignInException(code, e.message);
    } on PlatformException catch (e) {
      throw PlatformSignInException(e.code, e.message);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  /// Restores the stored session.
  ///
  /// Returning `null` means "there is no session" and sends the user to login,
  /// so it must be reserved for cases where the server actually turned us down.
  /// A connection error says nothing about whether the session is valid —
  /// treating it as a rejection is what used to sign people out for opening the
  /// app on a train. Instead we fall back to the cached user, and throw only
  /// when there is no cache to fall back to.
  Future<RestoredSession?> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;

    try {
      final res = await _apiClient.dio.get('/auth/me');
      final user = UserModel.fromJson(res.data as Map<String, dynamic>);
      await _storage.saveCachedUser(user);
      return RestoredSession(user, fromCache: false);
    } catch (e) {
      final error = ApiClient.parseError(e);

      if (error is NetworkException) {
        final cached = await _storage.getCachedUser();
        if (cached != null) return RestoredSession(cached, fromCache: true);
        // Nothing cached and no way to ask — the caller decides what to show,
        // but it must not be the login screen.
        throw error;
      }

      // The server answered. On a 401 the auth interceptor has already tried a
      // refresh and, if the session was genuinely rejected, cleared it — and it
      // is deliberately careful *not* to clear on a network blip mid-refresh.
      // So ask storage what it decided rather than re-reading the status code,
      // which cannot tell "your session is dead" from "the refresh timed out".
      if (await _storage.getAccessToken() == null) return null;

      // 403 never reaches that refresh path, so it is settled here.
      if (_isForbidden(e)) {
        await _storage.clearSession();
        return null;
      }

      // Tokens survived, so whatever went wrong was not the session. Fall back
      // to the cached user rather than punishing a signed-in user for a 500.
      final cached = await _storage.getCachedUser();
      if (cached != null) return RestoredSession(cached, fromCache: true);
      return null;
    }
  }

  bool _isForbidden(Object error) =>
      error is DioException && error.response?.statusCode == 403;

  /// Keeps the offline fallback in step with the live user. Called from
  /// [AppAuthCubit] whenever an authenticated user is emitted, so profile and
  /// onboarding changes survive the next cold launch.
  Future<void> cacheUser(UserModel user) => _storage.saveCachedUser(user);

  Future<bool> getHasSeenWelcome() => _storage.getHasSeenWelcome();
  Future<void> setHasSeenWelcome() => _storage.setHasSeenWelcome();

  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _firebaseAuth.signOut(),
      _storage.clearAll(),
    ]);
  }

  Future<UserModel> _loginToBackend(String idToken) async {
    try {
      final res = await _apiClient.dio.post(
        '/auth/firebase',
        data: {'idToken': idToken},
      );
      final data = res.data as Map<String, dynamic>;
      await _storage.saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }
}
