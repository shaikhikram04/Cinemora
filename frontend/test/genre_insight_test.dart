import 'package:flutter_test/flutter_test.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/utils/genre_insight.dart';

var _seq = 0;

LibraryEntryModel _entry(
  List<String> genres, {
  WatchStatus status = WatchStatus.watched,
  double? userRating,
  int rewatches = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return LibraryEntryModel(
    id: 'id-${_seq++}',
    tmdbId: 1,
    cinemaType: CinemaType.movie,
    title: 'Title',
    genres: genres,
    status: status,
    userRating: userRating,
    watchedAt: List.filled(rewatches, now),
    createdAt: now,
    updatedAt: now,
  );
}

List<LibraryEntryModel> _many(int count, List<String> genres) =>
    List.generate(count, (_) => _entry(genres));

void main() {
  group('deriveViewingPersonality', () {
    test('crowns the genre the user over-indexes on, not the biggest pile', () {
      // Drama is on more titles, but Crime at this share is far above what a
      // typical library carries. The old checkbox rule would have said Drama.
      final entries = [
        ..._many(20, ['Drama']),
        ..._many(12, ['Crime']),
      ];

      final insight = deriveViewingPersonality(entries)!;

      expect(insight.genre, 'Crime');
      expect(insight.archetype, 'The Detective');
      expect(insight.titleCount, 12);
    });

    test('folds TMDB and AniList names for one taste onto one bucket', () {
      // 'Science Fiction' (TMDB film), 'Sci-Fi & Fantasy' (TMDB TV) and 'Sci-Fi'
      // (AniList) are the same taste. Counted apart, each would lose to Drama.
      final entries = [
        ..._many(12, ['Drama']),
        ..._many(4, ['Science Fiction']),
        ..._many(4, ['Sci-Fi & Fantasy']),
        ..._many(4, ['Sci-Fi']),
      ];

      final insight = deriveViewingPersonality(entries)!;

      expect(insight.genre, 'Sci-Fi');
      expect(insight.archetype, 'The World Builder');
      expect(insight.titleCount, 12);
    });

    test('format tags never become a personality', () {
      // TMDB stamps 'Animation' on every anime film, so it lands on more titles
      // here than any real genre. A mostly-anime library must still be read on
      // the stories it chose, not on the medium they arrived in.
      final entries = [
        ..._many(20, ['Animation', 'Action']),
        ..._many(8, ['Horror']),
      ];

      final insight = deriveViewingPersonality(entries)!;

      expect(insight.genre, isNot('Animation'));
      expect(insight.genre, 'Horror');
      expect(insight.archetype, 'The Brave Soul');
    });

    test('an entry carrying only format tags contributes no signal', () {
      // Not merely ignored in the tally — it must not count toward the minimum
      // either, or a shelf of untasted titles would drag a real one over the bar.
      final entries = [
        ..._many(20, ['Animation', 'Family']),
        ..._many(6, ['Horror']),
      ];

      expect(deriveViewingPersonality(entries), isNull);
    });

    test('one entry cannot vote twice for the same genre', () {
      // A TMDB TV title can carry both 'Action' and 'Action & Adventure'.
      final doubleTagged = _many(10, ['Action', 'Action & Adventure']);
      final singleTagged = _many(10, ['Action']);

      expect(
        deriveViewingPersonality([...doubleTagged, ..._many(10, ['Drama'])])!
            .sharePercent,
        closeTo(
          deriveViewingPersonality([...singleTagged, ..._many(10, ['Drama'])])!
              .sharePercent,
          0.01,
        ),
      );
    });

    test('a single horror film does not crown Horror', () {
      // Lift for one horror title would be enormous; the count guard rejects it.
      final entries = [
        _entry(['Horror']),
        ..._many(30, ['Drama']),
      ];

      expect(deriveViewingPersonality(entries)!.genre, 'Drama');
    });

    test('returns null when the library is too thin to make a claim', () {
      expect(deriveViewingPersonality(_many(7, ['Crime'])), isNull);
      expect(deriveViewingPersonality(const []), isNull);
    });

    test('untagged legacy entries are skipped, not guessed', () {
      final entries = [
        ..._many(20, const []),
        ..._many(5, ['Crime']),
      ];

      expect(deriveViewingPersonality(entries), isNull);
    });

    test('rewatched five-star titles can flip the personality outright', () {
      // Same counts both ways — 20 drama, 6 romance. Only the enthusiasm differs,
      // and it is enough to move the verdict, which is the whole reason the
      // weighting exists.
      final lukewarm = [
        ..._many(20, ['Drama']),
        ..._many(6, ['Romance']),
      ];
      final beloved = [
        ..._many(20, ['Drama']),
        ...List.generate(
          6,
          (_) => _entry(['Romance'], userRating: 5.0, rewatches: 3),
        ),
      ];

      expect(deriveViewingPersonality(lukewarm)!.archetype, 'The Story Seeker');
      expect(deriveViewingPersonality(beloved)!.archetype, 'The Romantic');
    });

    test('dropped titles push their genre down, not up', () {
      final entries = [
        ..._many(20, ['Drama']),
        ...List.generate(
          8,
          (_) => _entry(['Horror'], status: WatchStatus.dropped),
        ),
      ];

      // Horror is a chunk of the shelf by count, but every one was abandoned.
      expect(deriveViewingPersonality(entries)!.genre, isNot('Horror'));
    });

    test('genre names are matched regardless of casing or padding', () {
      final entries = [
        ..._many(20, ['Drama']),
        ..._many(8, [' crime ']),
      ];

      expect(deriveViewingPersonality(entries)!.genre, 'Crime');
    });

    test('every archetype it can return carries a description', () {
      // Guards the two maps drifting apart: a genre wired up without a blurb
      // would render an empty card body.
      for (final genre in [
        'Drama',
        'Psychological',
        'Slice of Life',
        'Sci-Fi',
        'Fantasy',
        'Supernatural',
        'Action',
        'Thriller',
        'Adventure',
        'Crime',
        'Mystery',
        'Horror',
        'Romance',
        'Comedy',
        'Documentary',
        'History',
        'War',
        'Sports',
      ]) {
        final entries = [
          ..._many(10, [genre]),
          ..._many(10, ['Drama']),
        ];

        final insight = deriveViewingPersonality(entries)!;
        expect(insight.description, isNotEmpty, reason: 'no blurb for $genre');
      }
    });
  });
}
