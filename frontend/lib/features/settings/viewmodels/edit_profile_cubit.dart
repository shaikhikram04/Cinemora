import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepository _repo;

  EditProfileCubit(this._repo, UserModel user)
      : super(EditProfileState.fromUser(user));

  void toggleGenre(String genre) {
    final current = List<String>.from(state.selectedGenres);
    if (current.contains(genre)) {
      current.remove(genre);
    } else {
      current.add(genre);
    }
    emit(state.copyWith(selectedGenres: current));
  }

  void selectLanguage(String language) =>
      emit(state.copyWith(selectedLanguage: language));

  void selectEra(String era) => emit(state.copyWith(selectedEra: era));

  void togglePreview() =>
      emit(state.copyWith(showPreview: !state.showPreview));

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
        language: state.selectedLanguage,
        era: state.selectedEra,
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
