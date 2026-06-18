import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../exceptions/app_exception.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import 'secure_storage_service.dart';

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

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
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

  Future<UserModel?> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;

    try {
      final res = await _apiClient.dio.get('/auth/me');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

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
