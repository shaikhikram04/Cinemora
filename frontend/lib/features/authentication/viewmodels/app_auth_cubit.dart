import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/core/services/auth_service.dart';
import 'app_auth_state.dart';

class AppAuthCubit extends Cubit<AppAuthState> {
  final AuthService _authService;

  AppAuthCubit(this._authService) : super(const AppAuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AppAuthLoading());
    try {
      final user = await _authService.restoreSession();
      emit(user != null
          ? AppAuthAuthenticated(user)
          : const AppAuthUnauthenticated());
    } catch (_) {
      emit(const AppAuthUnauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AppAuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      emit(AppAuthAuthenticated(user));
    } catch (e) {
      emit(AppAuthError(e.toString()));
    }
  }

  Future<void> signInWithApple() async {
    emit(const AppAuthLoading());
    try {
      final user = await _authService.signInWithApple();
      emit(AppAuthAuthenticated(user));
    } catch (e) {
      emit(AppAuthError(e.toString()));
    }
  }

  void markOnboarded() {
    final current = state;
    if (current is AppAuthAuthenticated) {
      emit(AppAuthAuthenticated(current.user.copyWith(isOnboarded: true)));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(const AppAuthUnauthenticated());
  }
}
