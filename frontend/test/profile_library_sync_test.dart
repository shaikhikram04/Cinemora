import 'package:flutter_test/flutter_test.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/profile/viewmodels/profile_cubit.dart';

// Neither cubit touches its repository on the paths under test — the profile
// mirrors the library in memory — so a noSuchMethod stub is enough.
class _FakeLibraryRepository implements LibraryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LibraryEntryModel _watched(int id, String language) {
  final now = DateTime(2026, 1, 1);
  return LibraryEntryModel(
    id: '$id',
    tmdbId: id,
    cinemaType: CinemaType.movie,
    title: 'Title $id',
    releaseYear: '2015',
    originalLanguage: language,
    status: WatchStatus.watched,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('ProfileCubit mirrors the library', () {
    test('seeds its entries from the library it was handed', () {
      final library = LibraryCubit(_FakeLibraryRepository());
      for (var i = 1; i <= 3; i++) {
        library.syncEntry(_watched(i, 'ja'));
      }

      final profile = ProfileCubit(_FakeUserRepository(), library);

      expect(profile.state.entries, hasLength(3));
    });

    test('crossing the threshold unlocks the tiles with no pull-to-refresh',
        () async {
      // The bug this replaces: the profile fetched its own snapshot once, so a
      // title added from a detail page never reached it. Seven watched titles
      // is one short of the bar both insights need.
      final library = LibraryCubit(_FakeLibraryRepository());
      for (var i = 1; i <= 7; i++) {
        library.syncEntry(_watched(i, 'ja'));
      }

      final profile = ProfileCubit(_FakeUserRepository(), library);

      expect(profile.state.favoriteEra, isNull);
      expect(profile.state.favoriteLanguage, isNull);

      // The user adds an 8th title from a detail page. That calls syncEntry on
      // the app-scoped LibraryCubit — nothing tells the profile directly.
      library.syncEntry(_watched(8, 'ja'));
      await Future<void>.delayed(Duration.zero);

      expect(profile.state.entries, hasLength(8));
      expect(profile.state.favoriteEra!.label, '2010s');
      expect(profile.state.favoriteLanguage!.label, 'Japanese');
    });

    test('a removed title flows through and can re-lock an insight', () async {
      final library = LibraryCubit(_FakeLibraryRepository());
      for (var i = 1; i <= 8; i++) {
        library.syncEntry(_watched(i, 'ja'));
      }

      final profile = ProfileCubit(_FakeUserRepository(), library);
      expect(profile.state.favoriteLanguage!.label, 'Japanese');

      library.removeEntryLocal(8, CinemaType.movie);
      await Future<void>.delayed(Duration.zero);

      expect(profile.state.entries, hasLength(7));
      expect(profile.state.favoriteLanguage, isNull);
    });

    test('filter and sort changes do not re-derive the insights', () async {
      // LibraryCubit emits on these too, but `entries` is untouched by identity.
      final library = LibraryCubit(_FakeLibraryRepository());
      for (var i = 1; i <= 8; i++) {
        library.syncEntry(_watched(i, 'ja'));
      }

      final profile = ProfileCubit(_FakeUserRepository(), library);
      final before = profile.state;

      library.selectType('Movies');
      library.selectSort('Alphabetical');
      await Future<void>.delayed(Duration.zero);

      // Same state object: no emit, so nothing was recomputed downstream.
      expect(identical(profile.state, before), isTrue);
    });
  });
}
