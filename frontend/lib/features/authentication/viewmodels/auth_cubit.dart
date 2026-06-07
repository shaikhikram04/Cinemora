import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/features/authentication/viewmodels/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  static const int _totalPages = 4;

  AuthCubit() : super(const AuthState());

  void nextPage() {
    if (state.currentPage < _totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void jumpToLast() {
    emit(state.copyWith(currentPage: _totalPages - 1));
  }

  void pageChanged(int index) {
    emit(state.copyWith(currentPage: index));
  }
}
