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

  EditProfileCubit(
    this._repo,
    this._authCubit,
    UserModel user, {
    ImagePicker? picker,
  })  : _picker = picker ?? ImagePicker(),
        super(EditProfileState.fromUser(user));

  void toggleGenre(String genre) {
    final current = List<String>.from(state.selectedGenres);
    if (current.contains(genre)) {
      current.remove(genre);
    } else {
      current.add(genre);
    }
    emit(state.copyWith(selectedGenres: current));
  }

  void toggleLanguage(String language) {
    final current = List<String>.from(state.selectedLanguages);
    if (current.contains(language)) {
      current.remove(language);
    } else {
      current.add(language);
    }
    emit(state.copyWith(selectedLanguages: current));
  }

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

  Future<void> save({
    required String name,
    required String username,
    required String bio,
  }) async {
    if (state.status == EditProfileStatus.saving) return;

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
