import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'edit_profile_state.dart';

enum _ImageKind { avatar, cover }

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepository _repo;
  final AppAuthCubit _authCubit;
  final ImagePicker _picker;

  // The snapshot every dirty check is measured against. Held here rather than
  // in the state so copyWith doesn't have to carry a second copy of the form.
  final String _initialName;
  final String _initialUsername;
  final String _initialBio;
  final Set<String> _initialGenres;
  final Set<String> _initialLanguages;

  EditProfileCubit(
    this._repo,
    this._authCubit,
    UserModel user, {
    ImagePicker? picker,
  })  : _picker = picker ?? ImagePicker(),
        _initialName = user.name,
        _initialUsername = user.displayUsername,
        _initialBio = user.bio ?? '',
        _initialGenres = EditProfileState.fromUser(user).selectedGenres.toSet(),
        _initialLanguages =
            EditProfileState.fromUser(user).selectedLanguages.toSet(),
        super(EditProfileState.fromUser(user));

  void setName(String value) => _emitDraft(state.copyWith(name: value));

  void setUsername(String value) => _emitDraft(state.copyWith(username: value));

  void setBio(String value) => _emitDraft(state.copyWith(bio: value));

  void toggleGenre(String genre) {
    final current = List<String>.from(state.selectedGenres);
    if (current.contains(genre)) {
      current.remove(genre);
    } else {
      current.add(genre);
    }
    _emitDraft(state.copyWith(selectedGenres: current));
  }

  void toggleLanguage(String language) {
    final current = List<String>.from(state.selectedLanguages);
    if (current.contains(language)) {
      current.remove(language);
    } else {
      current.add(language);
    }
    _emitDraft(state.copyWith(selectedLanguages: current));
  }

  /// Recomputes [EditProfileState.isDirty] for every draft edit, so Save's
  /// enabled state is derived rather than assumed.
  void _emitDraft(EditProfileState next) {
    // Selection order is not meaningful to the user, so compare as sets —
    // otherwise deselecting and reselecting a genre would read as a change.
    final dirty = next.name.trim() != _initialName.trim() ||
        next.username.trim() != _initialUsername.trim() ||
        next.bio.trim() != _initialBio.trim() ||
        !_sameSet(next.selectedGenres, _initialGenres) ||
        !_sameSet(next.selectedLanguages, _initialLanguages);

    emit(next.copyWith(isDirty: dirty));
  }

  static bool _sameSet(List<String> a, Set<String> b) =>
      a.length == b.length && a.every(b.contains);

  Future<void> pickAvatar() => _pickAndUpload(_ImageKind.avatar);

  Future<void> pickCover() => _pickAndUpload(_ImageKind.cover);

  /// Picks from the gallery and uploads straight away — the backend stores the
  /// image and persists the URL, so there's no "unsaved image" limbo and the
  /// Save button stays purely about the text fields.
  Future<void> _pickAndUpload(_ImageKind kind) async {
    if (state.isUploading) return;

    final isAvatar = kind == _ImageKind.avatar;

    // Downscale before upload: a modern phone photo is 10 MB+ and would trip
    // the backend's 5 MB cap. The server crops to its final size regardless.
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: isAvatar ? 1024 : 1920,
      imageQuality: 85,
    );
    if (picked == null || isClosed) return; // user backed out of the picker

    emit(state.copyWith(
      isUploadingAvatar: isAvatar,
      isUploadingCover: !isAvatar,
      error: null,
    ));

    try {
      final user = isAvatar
          ? await _repo.uploadAvatar(picked.path)
          : await _repo.uploadCover(picked.path);
      if (isClosed) return;

      emit(state.copyWith(
        avatarUrl: user.avatar,
        coverUrl: user.framePoster,
        isUploadingAvatar: false,
        isUploadingCover: false,
      ));

      // Push it app-wide so the profile header and settings row update too,
      // without waiting for the user to hit Save.
      _authCubit.updateUser(user);
    } on AppException catch (e) {
      _failUpload(e.userMessage);
    } catch (_) {
      _failUpload('Could not upload the image. Please try again.');
    }
  }

  void _failUpload(String message) {
    if (isClosed) return;
    emit(state.copyWith(
      status: EditProfileStatus.error,
      error: message,
      isUploadingAvatar: false,
      isUploadingCover: false,
    ));
  }

  /// Reads the draft off state rather than taking it from the view, so there is
  /// exactly one definition of what gets saved and when saving is permitted.
  Future<void> save() async {
    if (!state.canSave) return;

    final name = state.name;
    final username = state.username;
    final bio = state.bio;

    emit(state.copyWith(status: EditProfileStatus.saving, error: null));

    try {
      final updatedUser = await _repo.updateProfileAndPreferences(
        name: name.trim(),
        username: username.trim().isEmpty ? null : username.trim(),
        bio: bio.trim().isEmpty ? null : bio.trim(),
        genres: state.selectedGenres,
        languages: state.selectedLanguages,
      );

      if (!isClosed) {
        emit(state.copyWith(
          status: EditProfileStatus.success,
          savedUser: updatedUser,
          // Nothing is pending any more, so the unsaved-changes guard lets the
          // screen pop and Save falls back to disabled.
          isDirty: false,
        ));
      }
    } on AppException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: EditProfileStatus.error,
          error: e.userMessage,
        ));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
          status: EditProfileStatus.error,
          error: 'Something went wrong. Please try again.',
        ));
      }
    }
  }

  void clearError() => emit(state.copyWith(
        status: EditProfileStatus.idle,
        error: null,
      ));
}
