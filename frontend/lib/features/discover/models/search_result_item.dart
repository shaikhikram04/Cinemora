import 'package:equatable/equatable.dart';
import 'package:cinemora/core/constants/api_constants.dart';

class SearchResultItem extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final double rating;
  final String year;
  final String mediaType; // 'movie' | 'tv' | 'anime'
  final String source;    // 'tmdb' | 'jikan'

  const SearchResultItem({
    required this.id,
    required this.title,
    this.posterPath,
    required this.rating,
    required this.year,
    required this.mediaType,
    required this.source,
  });

  String get posterUrl {
    if (source == 'jikan') return posterPath ?? '';
    return posterPath != null ? '${ApiConstants.tmdbImageBase}/w342$posterPath' : '';
  }

  String get ratingDisplay => rating > 0 ? rating.toStringAsFixed(1) : '—';

  String get typeLabel {
    switch (mediaType) {
      case 'tv':
        return 'Series';
      case 'anime':
        return 'Anime';
      default:
        return 'Movie';
    }
  }

  factory SearchResultItem.fromTmdb(Map<String, dynamic> json) {
    final rawType = json['media_type'] as String? ?? 'movie';
    final title = (json['title'] ?? json['name'] ?? '') as String;
    final releaseDate =
        (json['release_date'] ?? json['first_air_date'] ?? '') as String;
    final year = releaseDate.isNotEmpty ? releaseDate.split('-').first : '';
    final rating = (json['vote_average'] as num?)?.toDouble() ?? 0.0;

    return SearchResultItem(
      id: json['id'] as int,
      title: title,
      posterPath: json['poster_path'] as String?,
      rating: rating,
      year: year,
      mediaType: _resolveMediaType(json, rawType),
      source: 'tmdb',
    );
  }

  factory SearchResultItem.fromTmdbDiscover(
      Map<String, dynamic> json, String type) {
    final title = (json['title'] ?? json['name'] ?? '') as String;
    final releaseDate =
        (json['release_date'] ?? json['first_air_date'] ?? '') as String;
    final year = releaseDate.isNotEmpty ? releaseDate.split('-').first : '';
    final rating = (json['vote_average'] as num?)?.toDouble() ?? 0.0;

    return SearchResultItem(
      id: json['id'] as int,
      title: title,
      posterPath: json['poster_path'] as String?,
      rating: rating,
      year: year,
      mediaType: _resolveMediaType(json, type),
      source: 'tmdb',
    );
  }

  // Detects anime: Japanese animation = genre 16 + JP origin or language.
  // Distinguishes from Western cartoons (SpongeBob, Avatar) which share genre 16.
  static String _resolveMediaType(Map<String, dynamic> json, String fallback) {
    final genreIds = (json['genre_ids'] as List?)?.cast<int>() ?? [];
    final originCountry =
        (json['origin_country'] as List?)?.cast<String>() ?? [];
    final originalLanguage = json['original_language'] as String? ?? '';

    // Only promote to 'anime' for TV-type items. Animated Japanese movies (e.g.
    // MHA: Heroes Rising) share genre 16 + JP origin but have a movie TMDB ID —
    // routing them to the TV endpoint would cause a 404.
    if (fallback != 'movie' &&
        genreIds.contains(16) &&
        (originalLanguage == 'ja' || originCountry.contains('JP'))) {
      return 'anime';
    }
    return fallback == 'tv' ? 'tv' : 'movie';
  }

  factory SearchResultItem.fromAniList(Map<String, dynamic> json) {
    final title = json['title'] as Map<String, dynamic>?;
    final coverImage = json['coverImage'] as Map<String, dynamic>?;
    final startDate = json['startDate'] as Map<String, dynamic>?;
    // AniList scores are 0–100; convert to 0–10
    final rawScore = (json['averageScore'] as num?)?.toDouble() ?? 0.0;

    return SearchResultItem(
      id: json['idMal'] as int? ?? json['id'] as int,
      title: (title?['english'] ?? title?['romaji'] ?? '') as String,
      posterPath: coverImage?['large'] as String?,
      rating: rawScore > 0 ? rawScore / 10.0 : 0.0,
      year: startDate?['year']?.toString() ?? '',
      mediaType: 'anime',
      source: 'jikan',
    );
  }

  @override
  List<Object?> get props => [id, source, mediaType, title, posterPath];
}
