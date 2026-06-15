import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/user_model.dart';

enum EditProfileStatus { idle, saving, success, error }

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final List<String> selectedGenres;
  final String selectedLanguage;
  final String selectedEra;
  final bool showPreview;
  final UserModel? savedUser;
  final String? error;

  const EditProfileState({
    this.status = EditProfileStatus.idle,
    this.selectedGenres = const ['Drama', 'Thriller', 'Psychological'],
    this.selectedLanguage = 'English',
    this.selectedEra = '2010s',
    this.showPreview = false,
    this.savedUser,
    this.error,
  });

  factory EditProfileState.fromUser(UserModel user) {
    return EditProfileState(
      selectedGenres: user.preferences.genres.isNotEmpty
          ? List<String>.from(user.preferences.genres)
          : const ['Drama', 'Thriller', 'Psychological'],
      selectedLanguage: user.preferences.languages.isNotEmpty
          ? user.preferences.languages.first
          : 'English',
      selectedEra: user.preferences.era ?? '2010s',
    );
  }

  EditProfileState copyWith({
    EditProfileStatus? status,
    List<String>? selectedGenres,
    String? selectedLanguage,
    String? selectedEra,
    bool? showPreview,
    UserModel? savedUser,
    String? error,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedEra: selectedEra ?? this.selectedEra,
      showPreview: showPreview ?? this.showPreview,
      savedUser: savedUser ?? this.savedUser,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedGenres,
        selectedLanguage,
        selectedEra,
        showPreview,
        savedUser,
        error,
      ];
}
