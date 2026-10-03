import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/features/onboarding/viewmodels/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  /// Genres and languages — the two answers the recommender actually reads.
  ///
  /// The step count is exactly the number of answers [submitPreferences]
  /// sends, which is the rule that keeps this screen honest: a step whose
  /// answer nothing consumes has no business asking for taps. Three steps went
  /// on that rule — streaming platforms (never even transmitted), content
  /// types (stored, never read), and a review screen for a form with nothing
  /// at stake.
  static const int totalSteps = 2;

  final UserRepository _userRepository;

  OnboardingCubit(this._userRepository) : super(const OnboardingState());

  void stepChanged(int step) => emit(state.copyWith(currentStep: step));

  void nextStep() {
    if (state.currentStep < totalSteps - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Clears the current step's answer and moves on.
  ///
  /// On the last step there is nowhere to move to, so the step index stays put
  /// and the caller submits instead — that's what keeps Skip available on
  /// every step rather than trapping someone on the final one behind an answer
  /// they don't want to give.
  void skipCurrentStep() {
    final step = state.currentStep;
    final next = step < totalSteps - 1 ? step + 1 : step;
    switch (step) {
      case 0:
        emit(state.copyWith(selectedGenres: const [], currentStep: next));
      case 1:
        emit(state.copyWith(selectedLanguages: const [], currentStep: next));
    }
  }

  void toggleGenre(String key) =>
      emit(state.copyWith(selectedGenres: _toggle(state.selectedGenres, key)));

  void toggleLanguage(String key) => emit(
      state.copyWith(selectedLanguages: _toggle(state.selectedLanguages, key)));

  Future<void> submitPreferences() async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));
    try {
      // The refreshed user is carried into state rather than dropped: it's the
      // only copy that has the selections on it, and the session is still
      // holding the sign-in payload with empty preferences.
      //
      // contentTypes is deliberately not sent. Onboarding used to ask which of
      // movies/series/anime you watch, store the answer, and then never read it
      // again — the feed and the recommender both work across every type. The
      // field stays on the model for accounts that already answered; nothing
      // asks any more.
      final user = await _userRepository.updatePreferences(
        genres: state.selectedGenres,
        languages: state.selectedLanguages,
      );
      emit(state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
        submittedUser: user,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(isSubmitting: false, submitError: e.userMessage));
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        submitError: 'Something went wrong. Please try again.',
      ));
    }
  }

  List<String> _toggle(List<String> list, String key) {
    final updated = List<String>.from(list);
    updated.contains(key) ? updated.remove(key) : updated.add(key);
    return updated;
  }
}
