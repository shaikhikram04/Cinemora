import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/library/viewmodels/library_state.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository _repo;
  final LibraryCubit _library;

  late final StreamSubscription<LibraryState> _librarySub;

  /// The library belongs to [LibraryCubit] — app-scoped, loaded at auth, and
  /// kept current by every detail-page mutation via `syncEntry`. The profile
  /// mirrors it instead of fetching its own list, so crossing a threshold (an
  /// 8th watched title unlocking the era and language tiles) shows up the next
  /// time the user opens this tab rather than waiting for a pull-to-refresh.
  ProfileCubit(this._repo, this._library)
      : super(ProfileState(entries: _library.state.entries)) {
    _librarySub = _library.stream.listen((libraryState) {
      if (isClosed) return;
      // LibraryCubit also emits on filter, sort and search changes, which leave
      // `entries` untouched by identity. Only re-derive when the list changed.
      if (identical(libraryState.entries, state.entries)) return;
      emit(state.copyWith(entries: libraryState.entries));
    });
  }

  /// Stats only — entries arrive from the library subscription above.
  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final stats = await _repo.getLibraryStats();
      if (!isClosed) {
        emit(state.copyWith(status: ProfileStatus.loaded, stats: stats));
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

  /// Pull-to-refresh: re-reads stats and the library from the server. In-app
  /// edits already stream in, so this only matters for changes made elsewhere.
  Future<void> refresh() async {
    try {
      // Kick both off before awaiting either — the library's fresh entries
      // arrive through the subscription, so only stats land here.
      final statsFuture = _repo.getLibraryStats();
      final libraryFuture = _library.loadData();
      final stats = await statsFuture;
      await libraryFuture;

      if (!isClosed) {
        emit(state.copyWith(status: ProfileStatus.loaded, stats: stats));
      }
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _librarySub.cancel();
    return super.close();
  }
}
