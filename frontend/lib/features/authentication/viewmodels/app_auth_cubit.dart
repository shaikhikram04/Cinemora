import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/services/auth_service.dart';
import 'app_auth_state.dart';

class AppAuthCubit extends Cubit<AppAuthState> {
  final AuthService _authService;

  bool hasSeenWelcome = false;

  AppAuthCubit(this._authService) : super(const AppAuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AppAuthLoading());
    try {
      hasSeenWelcome = await _authService.getHasSeenWelcome();
      final user = await _authService.restoreSession();
      emit(user != null
          ? AppAuthAuthenticated(user)
          : const AppAuthUnauthenticated());
    } catch (_) {
      emit(const AppAuthUnauthenticated());
    }
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
      emit(AppAuthAuthenticated(user));
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
      emit(AppAuthAuthenticated(user));
    } on AppException catch (e) {
      emit(AppAuthError(e.userMessage));
    } catch (_) {
      emit(const AppAuthError('Something went wrong. Please try again.'));
    }
  }

  void markOnboarded() {
    final current = state;
    if (current is AppAuthAuthenticated) {
      emit(AppAuthAuthenticated(current.user.copyWith(isOnboarded: true)));
    }
  }

  void updateUser(UserModel user) {
    emit(AppAuthAuthenticated(user));
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(const AppAuthUnauthenticated());
  }
}
