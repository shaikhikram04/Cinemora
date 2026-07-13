import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/user_model.dart';

enum EditProfileStatus { idle, saving, success, error }

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final List<String> selectedGenres;
  final List<String> selectedLanguages;
  final bool showPreview;
  final UserModel? savedUser;
  final String? error;

  const EditProfileState({
    this.status = EditProfileStatus.idle,
    this.selectedGenres = const ['Drama', 'Thriller', 'Psychological'],
    this.selectedLanguages = const ['English'],
    this.showPreview = false,
    this.savedUser,
    this.error,
  });

  factory EditProfileState.fromUser(UserModel user) {
    return EditProfileState(
      selectedGenres: user.preferences.genres.isNotEmpty
          ? List<String>.from(user.preferences.genres)
          : const ['Drama', 'Thriller', 'Psychological'],
      selectedLanguages: user.preferences.languages.isNotEmpty
          ? List<String>.from(user.preferences.languages)
          : const ['English'],
    );
  }

  EditProfileState copyWith({
    EditProfileStatus? status,
    List<String>? selectedGenres,
    List<String>? selectedLanguages,
    bool? showPreview,
    UserModel? savedUser,
    String? error,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      showPreview: showPreview ?? this.showPreview,
      savedUser: savedUser ?? this.savedUser,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedGenres,
        selectedLanguages,
        showPreview,
        savedUser,
        error,
      ];
}
