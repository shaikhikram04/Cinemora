import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/user_model.dart';

enum EditProfileStatus { idle, saving, success, error }

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final List<String> selectedGenres;
  final List<String> selectedLanguages;

  // Avatar and cover persist the moment they're picked, independently of the
  // Save button — so they carry their own URLs and in-flight flags rather than
  // riding on `status` (which the view uses to pop the screen on success).
  final String? avatarUrl;
  final String? coverUrl;
  final bool isUploadingAvatar;
  final bool isUploadingCover;

  final UserModel? savedUser;
  final String? error;

  const EditProfileState({
    this.status = EditProfileStatus.idle,
    this.selectedGenres = const ['Drama', 'Thriller', 'Psychological'],
    this.selectedLanguages = const ['English'],
    this.avatarUrl,
    this.coverUrl,
    this.isUploadingAvatar = false,
    this.isUploadingCover = false,
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
      avatarUrl: user.avatar,
      coverUrl: user.framePoster,
    );
  }

  bool get isUploading => isUploadingAvatar || isUploadingCover;

  EditProfileState copyWith({
    EditProfileStatus? status,
    List<String>? selectedGenres,
    List<String>? selectedLanguages,
    String? avatarUrl,
    String? coverUrl,
    bool? isUploadingAvatar,
    bool? isUploadingCover,
    UserModel? savedUser,
    String? error,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isUploadingCover: isUploadingCover ?? this.isUploadingCover,
      savedUser: savedUser ?? this.savedUser,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedGenres,
        selectedLanguages,
        avatarUrl,
        coverUrl,
        isUploadingAvatar,
        isUploadingCover,
        savedUser,
        error,
      ];
}
