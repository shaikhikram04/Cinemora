import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/authentication/viewmodels/welcome_state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  /// One page saying what the app is, then sign-in.
  ///
  /// The two that went were a list of generic feature tiles and a mocked-up
  /// recommendation card — both selling capabilities to someone who hasn't
  /// agreed to the premise yet, and both standing between a returning user and
  /// the sign-in button they opened the app to press.
  ///
  /// Public because the progress indicator has to agree with it; a hardcoded
  /// count at the render site is how a carousel ends up with a dot that never
  /// fills.
  static const int totalPages = 2;

  WelcomeCubit() : super(const WelcomeState());

  void nextPage() {
    if (state.currentPage < totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void jumpToLast() {
    emit(state.copyWith(currentPage: totalPages - 1));
  }

  void pageChanged(int index) {
    emit(state.copyWith(currentPage: index));
  }
}
