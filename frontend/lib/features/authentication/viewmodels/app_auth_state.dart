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

class AppAuthError extends AppAuthState {
  final String message;
  const AppAuthError(this.message);
  @override
  List<Object?> get props => [message];
}
