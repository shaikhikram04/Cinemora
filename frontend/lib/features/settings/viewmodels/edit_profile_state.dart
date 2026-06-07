import 'package:equatable/equatable.dart';

class EditProfileState extends Equatable {
  final List<String> selectedGenres;
  final String selectedLanguage;
  final String selectedEra;
  final bool showPreview;

  const EditProfileState({
    this.selectedGenres = const ['Drama', 'Thriller', 'Psychological'],
    this.selectedLanguage = 'English',
    this.selectedEra = '2010s',
    this.showPreview = false,
  });

  EditProfileState copyWith({
    List<String>? selectedGenres,
    String? selectedLanguage,
    String? selectedEra,
    bool? showPreview,
  }) {
    return EditProfileState(
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedEra: selectedEra ?? this.selectedEra,
      showPreview: showPreview ?? this.showPreview,
    );
  }

  @override
  List<Object> get props => [selectedGenres, selectedLanguage, selectedEra, showPreview];
}
