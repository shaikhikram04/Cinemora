import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchary/core/repositories/user_repository.dart';
import 'package:watchary/features/onboarding/viewmodels/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  static const int totalSteps = 5;

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

  void toggleContentType(String key) => emit(state.copyWith(
      selectedContentTypes: _toggle(state.selectedContentTypes, key)));

  void toggleGenre(String key) =>
      emit(state.copyWith(selectedGenres: _toggle(state.selectedGenres, key)));

  void toggleLanguage(String key) => emit(
      state.copyWith(selectedLanguages: _toggle(state.selectedLanguages, key)));

  void togglePlatform(String key) => emit(
      state.copyWith(selectedPlatforms: _toggle(state.selectedPlatforms, key)));

  Future<void> submitPreferences() async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));
    try {
      await _userRepository.updatePreferences(
        contentTypes: state.selectedContentTypes,
        genres: state.selectedGenres,
        languages: state.selectedLanguages,
      );
      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
    } catch (e) {
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
