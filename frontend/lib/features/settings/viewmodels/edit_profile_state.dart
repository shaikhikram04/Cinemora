import 'package:equatable/equatable.dart';
import 'package:cinemora/core/models/user_model.dart';

enum EditProfileStatus { idle, saving, success, error }

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final List<String> selectedGenres;
  final List<String> selectedLanguages;

  // Live text draft. The cubit owns it so Save can be driven by state rather
  // than by reaching into the view's controllers, which is what let the two
  // Save buttons disagree about when saving was allowed.
  final String name;
  final String username;
  final String bio;

  /// Whether anything the Save button is responsible for has changed. Avatar
  /// and cover are excluded on purpose — they persist the moment they're
  /// picked, so they are never pending.
  final bool isDirty;

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
    this.name = '',
    this.username = '',
    this.bio = '',
    this.isDirty = false,
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
      name: user.name,
      username: user.displayUsername,
      bio: user.bio ?? '',
      avatarUrl: user.avatar,
      coverUrl: user.framePoster,
    );
  }

  bool get isUploading => isUploadingAvatar || isUploadingCover;

  /// Saving mid-upload would race the image write against the profile write and
  /// could return a user without the new URL. Every Save affordance reads this
  /// one getter so they cannot drift apart.
  bool get canSave =>
      isDirty && status != EditProfileStatus.saving && !isUploading;

  EditProfileState copyWith({
    EditProfileStatus? status,
    List<String>? selectedGenres,
    List<String>? selectedLanguages,
    String? name,
    String? username,
    String? bio,
    bool? isDirty,
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
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      isDirty: isDirty ?? this.isDirty,
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
        name,
        username,
        bio,
        isDirty,
        avatarUrl,
        coverUrl,
        isUploadingAvatar,
        isUploadingCover,
        savedUser,
        error,
      ];
}
