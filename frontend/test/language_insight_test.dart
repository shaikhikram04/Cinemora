import 'package:flutter_test/flutter_test.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/utils/language_insight.dart';

LibraryEntryModel _entry(
  String? originalLanguage, {
  WatchStatus status = WatchStatus.watched,
  double? userRating,
  int rewatches = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return LibraryEntryModel(
    id: 'id-$originalLanguage-${status.name}-$userRating-$rewatches',
    tmdbId: 1,
    cinemaType: CinemaType.movie,
    title: 'Title',
    originalLanguage: originalLanguage,
    status: status,
    userRating: userRating,
    watchedAt: List.filled(rewatches, now),
    createdAt: now,
    updatedAt: now,
  );
}

List<LibraryEntryModel> _many(int count, String code) =>
    List.generate(count, (_) => _entry(code));

void main() {
  group('deriveFavoriteLanguage', () {
    test('crowns the language the user over-indexes on, not the biggest pile',
        () {
      // 50 titles: mostly English, but 10 Korean (20%) is four times the share a
      // typical library carries. A plain "most watched" rule would say English.
      final entries = [
        ..._many(30, 'en'),
        ..._many(10, 'ko'),
        ..._many(10, 'ja'),
      ];

      final insight = deriveFavoriteLanguage(entries);

      expect(insight!.label, 'Korean');
      expect(insight.code, 'ko');
      expect(insight.titleCount, 10);
      expect(insight.sharePercent, closeTo(20.0, 0.01));
    });

    test('still says English for a purely mainstream library', () {
      final entries = [..._many(25, 'en'), ..._many(5, 'ja')];

      expect(deriveFavoriteLanguage(entries)!.label, 'English');
    });

    test('a single foreign film does not crown its language', () {
      // Lift for one Tamil title would be enormous; the count guard rejects it.
      final entries = [_entry('ta'), ..._many(30, 'en')];

      expect(deriveFavoriteLanguage(entries)!.label, 'English');
    });

    test('returns null when the library is too thin to make a claim', () {
      expect(deriveFavoriteLanguage(_many(7, 'ja')), isNull);
      expect(deriveFavoriteLanguage(const []), isNull);
    });

    test('untagged legacy entries are skipped, not guessed', () {
      // 20 entries predating originalLanguage plus 5 tagged ones is still only
      // 5 titles of real signal — under the bar, so we say nothing.
      final entries = [
        ...List.generate(20, (_) => _entry(null)),
        ..._many(5, 'ja'),
      ];

      expect(deriveFavoriteLanguage(entries), isNull);
    });

    test('anime counts as Japanese and can win outright', () {
      final entries = [..._many(20, 'ja'), ..._many(10, 'en')];

      final insight = deriveFavoriteLanguage(entries);

      expect(insight!.label, 'Japanese');
      expect(insight.titleCount, 20);
    });

    test('rewatched five-star titles pull their language up', () {
      // Same counts both ways; only the enthusiasm differs.
      final lukewarm = [
        ..._many(20, 'en'),
        ..._many(6, 'hi'),
      ];
      final beloved = [
        ..._many(20, 'en'),
        ...List.generate(
          6,
          (_) => _entry('hi', userRating: 5.0, rewatches: 3),
        ),
      ];

      final lukewarmHindi = deriveFavoriteLanguage(lukewarm)!.sharePercent;
      final belovedHindi = deriveFavoriteLanguage(beloved)!.sharePercent;

      expect(deriveFavoriteLanguage(beloved)!.label, 'Hindi');
      expect(belovedHindi, greaterThan(lukewarmHindi));
    });

    test('dropped and panned titles push their language down, not up', () {
      final entries = [
        ..._many(20, 'en'),
        ...List.generate(
          8,
          (_) => _entry('ko', status: WatchStatus.dropped),
        ),
      ];

      // Korean is a fifth of the shelf by count, but every one was abandoned.
      expect(deriveFavoriteLanguage(entries)!.label, 'English');
    });

    test('normalizes casing so EN and en are one language', () {
      final entries = [..._many(15, 'EN'), ..._many(5, 'en')];

      final insight = deriveFavoriteLanguage(entries);

      expect(insight!.code, 'en');
      expect(insight.titleCount, 20);
    });

    test('an untabulated language still gets a readable label', () {
      final entries = [..._many(20, 'en'), ..._many(6, 'sv')];

      expect(deriveFavoriteLanguage(entries)!.label, 'Swedish');
    });
  });
}
