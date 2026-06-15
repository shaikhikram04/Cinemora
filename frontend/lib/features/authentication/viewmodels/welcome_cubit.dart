import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/authentication/viewmodels/welcome_state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  static const int _totalPages = 4;

  WelcomeCubit() : super(const WelcomeState());

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
