import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/user_model.dart';

class OnboardingState extends Equatable {
  final int currentStep;
  final List<String> selectedGenres;
  final List<String> selectedLanguages;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  /// The server's copy of the user once preferences have been saved, carrying
  /// both the selections and the `isOnboarded` flip the same request performs.
  ///
  /// The screen hands this to [AppAuthCubit] so the session picks up what was
  /// just chosen — without it the app keeps the user from the sign-in payload,
  /// whose preferences are still empty for a brand-new account, and every
  /// screen reading preferences from the session shows its own placeholder
  /// defaults instead. Non-null whenever [submitSuccess] is true.
  final UserModel? submittedUser;

  const OnboardingState({
    this.currentStep = 0,
    this.selectedGenres = const [],
    this.selectedLanguages = const [],
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitError,
    this.submittedUser,
  });

  bool get canContinue {
    switch (currentStep) {
      case 0:
        return selectedGenres.length >= 3;
      case 1:
        return selectedLanguages.isNotEmpty;
      default:
        return true;
    }
  }

  bool isGenreSelected(String key) => selectedGenres.contains(key);
  bool isLanguageSelected(String key) => selectedLanguages.contains(key);

  OnboardingState copyWith({
    int? currentStep,
    List<String>? selectedGenres,
    List<String>? selectedLanguages,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
    bool clearSubmitError = false,
    UserModel? submittedUser,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submittedUser: submittedUser ?? this.submittedUser,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        selectedGenres,
        selectedLanguages,
        isSubmitting,
        submitSuccess,
        submitError,
        submittedUser,
      ];
}
