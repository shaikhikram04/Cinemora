import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentStep;
  final List<String> selectedContentTypes;
  final List<String> selectedGenres;
  final List<String> selectedLanguages;
  final List<String> selectedPlatforms;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  const OnboardingState({
    this.currentStep = 0,
    this.selectedContentTypes = const [],
    this.selectedGenres = const [],
    this.selectedLanguages = const [],
    this.selectedPlatforms = const [],
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitError,
  });

  bool get canContinue {
    switch (currentStep) {
      case 0: return selectedContentTypes.isNotEmpty;
      case 1: return selectedGenres.length >= 3;
      case 2: return selectedLanguages.isNotEmpty;
      case 3: return selectedPlatforms.isNotEmpty;
      default: return true;
    }
  }

  bool isContentTypeSelected(String key) => selectedContentTypes.contains(key);
  bool isGenreSelected(String key) => selectedGenres.contains(key);
  bool isLanguageSelected(String key) => selectedLanguages.contains(key);
  bool isPlatformSelected(String key) => selectedPlatforms.contains(key);

  OnboardingState copyWith({
    int? currentStep,
    List<String>? selectedContentTypes,
    List<String>? selectedGenres,
    List<String>? selectedLanguages,
    List<String>? selectedPlatforms,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedContentTypes: selectedContentTypes ?? this.selectedContentTypes,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        selectedContentTypes,
        selectedGenres,
        selectedLanguages,
        selectedPlatforms,
        isSubmitting,
        submitSuccess,
        submitError,
      ];
}
