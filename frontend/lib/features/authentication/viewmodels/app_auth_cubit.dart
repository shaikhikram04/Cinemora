import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/services/auth_service.dart';
import 'app_auth_state.dart';

class AppAuthCubit extends Cubit<AppAuthState> {
  final AuthService _authService;

  bool hasSeenWelcome = false;

  AppAuthCubit(this._authService) : super(const AppAuthInitial());

  /// True when the current user was restored from the offline cache and still
  /// needs to be checked against the server.
  bool _needsRevalidation = false;

  Future<void> checkAuthStatus() async {
    emit(const AppAuthLoading());
    try {
      hasSeenWelcome = await _authService.getHasSeenWelcome();
      final session = await _authService.restoreSession();
      if (session == null) {
        emit(const AppAuthUnauthenticated());
        return;
      }

      // A cached user who never finished onboarding is a dead end: onboarding
      // is entirely server-driven, so there is nothing useful to show them.
      if (session.fromCache && !session.user.isOnboarded) {
        emit(const AppAuthOffline());
        return;
      }

      _needsRevalidation = session.fromCache;
      _emitAuthenticated(session.user);
    } on NetworkException {
      emit(const AppAuthOffline());
    } catch (_) {
      emit(const AppAuthUnauthenticated());
    }
  }

  /// Re-checks a cache-restored session once the network is back, so a stale
  /// avatar or a since-completed onboarding doesn't stick around. Silent by
  /// design — the user is already in the app and nothing should flash.
  Future<void> revalidateIfStale() async {
    if (!_needsRevalidation) return;
    try {
      final session = await _authService.restoreSession();
      if (session == null) {
        // The session really was dead; we just couldn't tell until now.
        _needsRevalidation = false;
        emit(const AppAuthUnauthenticated());
        return;
      }
      if (session.fromCache) return; // still offline — try again next time
      _needsRevalidation = false;
      _emitAuthenticated(session.user);
    } catch (_) {
      // Still unreachable. The cached user stays; we'll retry on the next
      // reconnect.
    }
  }

  /// Single funnel for authenticated emissions so the offline cache can never
  /// drift out of step with the state the app is actually rendering.
  void _emitAuthenticated(UserModel user) {
    emit(AppAuthAuthenticated(user));
    _authService.cacheUser(user);
  }

  Future<void> markWelcomeSeen() async {
    if (hasSeenWelcome) return;
    hasSeenWelcome = true;
    await _authService.setHasSeenWelcome();
  }

  Future<void> signInWithGoogle() async {
    emit(const AppAuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      _emitAuthenticated(user);
    } on AppException catch (e) {
      emit(AppAuthError(e.userMessage));
    } catch (_) {
      emit(const AppAuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> signInWithApple() async {
    emit(const AppAuthLoading());
    try {
      final user = await _authService.signInWithApple();
      _emitAuthenticated(user);
    } on AppException catch (e) {
      emit(AppAuthError(e.userMessage));
    } catch (_) {
      emit(const AppAuthError('Something went wrong. Please try again.'));
    }
  }

  void markOnboarded() {
    final current = state;
    if (current is AppAuthAuthenticated) {
      _emitAuthenticated(current.user.copyWith(isOnboarded: true));
    }
  }

  void updateUser(UserModel user) {
    _emitAuthenticated(user);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    hasSeenWelcome = true;
    await _authService.setHasSeenWelcome();
    emit(const AppAuthUnauthenticated());
  }
}
