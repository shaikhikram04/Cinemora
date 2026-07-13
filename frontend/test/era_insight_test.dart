import 'package:flutter_test/flutter_test.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/utils/era_insight.dart';

LibraryEntryModel _entry(
  String? releaseYear, {
  WatchStatus status = WatchStatus.watched,
  double? userRating,
  int rewatches = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return LibraryEntryModel(
    id: 'id-$releaseYear-${status.name}-$userRating-$rewatches',
    tmdbId: 1,
    cinemaType: CinemaType.movie,
    title: 'Title',
    releaseYear: releaseYear,
    status: status,
    userRating: userRating,
    watchedAt: List.filled(rewatches, now),
    createdAt: now,
    updatedAt: now,
  );
}

List<LibraryEntryModel> _many(int count, String year) =>
    List.generate(count, (_) => _entry(year));

void main() {
  group('deriveFavoriteEra', () {
    test('crowns the decade the user over-indexes on, not the biggest pile',
        () {
      // 57 titles: mostly modern, but the 80s share (9/57 ≈ 16%) is triple what
      // a typical library carries. A plain "most watched" rule would say 2010s.
      final entries = [
        ..._many(24, '2015'),
        ..._many(18, '2021'),
        ..._many(9, '1985'),
        ..._many(6, '1994'),
      ];

      final insight = deriveFavoriteEra(entries);

      expect(insight!.label, '1980s');
      expect(insight.titleCount, 9);
      expect(insight.sharePercent, closeTo(15.79, 0.01));
    });

    test('still says 2010s for a purely mainstream library', () {
      final entries = [..._many(20, '2014'), ..._many(10, '2022')];

      expect(deriveFavoriteEra(entries)!.label, '2010s');
    });

    test('a single old film does not crown Pre-1970s', () {
      // Lift for one 1965 title would be enormous; the count guard rejects it.
      final entries = [_entry('1965'), ..._many(30, '2016')];

      expect(deriveFavoriteEra(entries)!.label, '2010s');
    });

    test('returns null when the library is too thin to make a claim', () {
      expect(deriveFavoriteEra([]), isNull);
      expect(deriveFavoriteEra(_many(3, '1985')), isNull);
      expect(deriveFavoriteEra(_many(7, '1985')), isNull);
    });

    test('rewatched five-star titles pull their decade up', () {
      // The 90s pile is smaller than the 2000s one, but it's beloved and
      // rewatched while the 2000s titles are merely watchlisted.
      final entries = [
        ..._many(12, '2005').map((e) => _entry(e.releaseYear,
            status: WatchStatus.watchlist)),
        ...List.generate(
          4,
          (_) => _entry('1996', userRating: 5.0, rewatches: 3),
        ),
      ];

      expect(deriveFavoriteEra(entries)!.label, '1990s');
    });

    test('dropped and panned titles push their decade down, not up', () {
      // 1980s has the most titles by count, but they were all dropped or hated,
      // so it should never win.
      final entries = [
        ..._many(10, '1985')
            .map((e) => _entry(e.releaseYear, status: WatchStatus.dropped)),
        ...List.generate(6, (_) => _entry('1988', userRating: 0.5)),
        ..._many(8, '2015'),
      ];

      final insight = deriveFavoriteEra(entries);

      expect(insight!.label, isNot('1980s'));
      expect(insight.label, '2010s');
    });

    test('skips entries with missing or unparseable release years', () {
      final entries = [
        ..._many(10, '2015'),
        _entry(null),
        _entry(''),
        _entry('N/A'),
        _entry('Unknown'),
      ];

      final insight = deriveFavoriteEra(entries);

      expect(insight!.label, '2010s');
      expect(insight.titleCount, 10);
      expect(insight.sharePercent, closeTo(100, 0.01));
    });

    test('reads a year out of a full date string', () {
      expect(deriveFavoriteEra(_many(10, '1988-04-16'))!.label, '1980s');
    });

    test('falls back to plain weighted mode when signal is spread thin', () {
      // One or two titles per decade: no decade clears the count/share guards,
      // so we pick the heaviest rather than returning nothing.
      final entries = [
        _entry('1965'),
        _entry('1975'),
        _entry('1985'),
        _entry('1995'),
        _entry('2005'),
        _entry('2012'),
        _entry('2014'),
        _entry('2021'),
      ];

      expect(deriveFavoriteEra(entries)!.label, '2010s');
    });
  });
}
