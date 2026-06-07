import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentStep;
  final List<String> selectedContentTypes;
  final List<String> selectedGenres;
  final List<String> selectedLanguages;
  final List<String> selectedPlatforms;

  const OnboardingState({
    this.currentStep = 0,
    this.selectedContentTypes = const [],
    this.selectedGenres = const [],
    this.selectedLanguages = const [],
    this.selectedPlatforms = const [],
  });

  bool get canContinue {
    if (currentStep == 1) return selectedGenres.length >= 3;
    return true;
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
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      selectedContentTypes: selectedContentTypes ?? this.selectedContentTypes,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
    );
  }

  @override
  List<Object> get props => [
        currentStep,
        selectedContentTypes,
        selectedGenres,
        selectedLanguages,
        selectedPlatforms,
      ];
}
