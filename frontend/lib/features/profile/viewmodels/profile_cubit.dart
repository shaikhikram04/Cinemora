import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository _repo;

  ProfileCubit(this._repo) : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final stats = await _repo.getLibraryStats();
      final entries = await _repo.getLibraryEntries();

      if (!isClosed) {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          stats: stats,
          entries: entries,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: ProfileStatus.error,
          error: e.toString(),
        ));
      }
    }
  }

  // Refresh stats and entries in parallel after an edit-profile save.
  Future<void> refresh() async {
    try {
      final results = await Future.wait<Object>([
        _repo.getLibraryStats(),
        _repo.getLibraryEntries(),
      ]);
      if (!isClosed) {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          stats: results[0] as LibraryStatsModel,
          entries: results[1] as List<LibraryEntryModel>,
        ));
      }
    } catch (_) {}
  }
}
