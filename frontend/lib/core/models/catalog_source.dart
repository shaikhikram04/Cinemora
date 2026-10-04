import 'package:cinemora/core/models/cinema_type.dart';

/// Which upstream a title's data came from.
///
/// Only TMDB is named explicitly. The anime upstream's wire label has already
/// moved from `jikan` to `anilist` and may move again, so every non-TMDB value
/// collapses to [anime] — "is this TMDB or not" is the only distinction the app
/// actually branches on.
enum CatalogSource {
  tmdb,
  anime;

  bool get isAnime => this == CatalogSource.anime;

  /// A series from the anime upstream is [CinemaType.anime]; a TMDB series is
  /// [CinemaType.tv]. Used for the library's compound (id, cinemaType) key.
  CinemaType get seriesCinemaType => isAnime ? CinemaType.anime : CinemaType.tv;

  /// Tolerant of whatever the upstream currently calls itself: only an explicit
  /// `tmdb`, or a missing value (which the API omits on TMDB rows), is TMDB.
  static CatalogSource fromJson(String? value) =>
      value == null || value == 'tmdb'
          ? CatalogSource.tmdb
          : CatalogSource.anime;

  static CatalogSource forCinemaType(CinemaType? type) =>
      type == CinemaType.anime ? CatalogSource.anime : CatalogSource.tmdb;

  /// For a raw cinemaType string off the API (`movie` | `tv` | `anime`).
  static CatalogSource forCinemaTypeName(String? name) =>
      name == 'anime' ? CatalogSource.anime : CatalogSource.tmdb;
}
