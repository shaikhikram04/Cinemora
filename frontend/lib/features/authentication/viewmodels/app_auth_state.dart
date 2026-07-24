import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/user_model.dart';

abstract class AppAuthState extends Equatable {
  const AppAuthState();
  @override
  List<Object?> get props => [];
}

class AppAuthInitial extends AppAuthState {
  const AppAuthInitial();
}

class AppAuthLoading extends AppAuthState {
  const AppAuthLoading();
}

class AppAuthAuthenticated extends AppAuthState {
  final UserModel user;
  const AppAuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AppAuthUnauthenticated extends AppAuthState {
  const AppAuthUnauthenticated();
}

/// A session exists but cannot be verified and there is nothing cached to fall
/// back to — the only case where being offline genuinely blocks the app. Kept
/// separate from [AppAuthUnauthenticated] so the router never mistakes an
/// unreachable server for a signed-out user.
class AppAuthOffline extends AppAuthState {
  const AppAuthOffline();
}

class AppAuthError extends AppAuthState {
  final String message;
  const AppAuthError(this.message);
  @override
  List<Object?> get props => [message];
}
