import 'package:cinemora/core/constants/api_constants.dart';
import 'package:cinemora/core/models/catalog_source.dart';
import 'package:cinemora/core/models/cinema_type.dart';

/// A title suggested by the recommender service — the payload shared by every
/// recommendation endpoint: similar titles, pick of the week, because-you-ranked,
/// critically acclaimed, and the mood chat's replies.
class RecommendedTitle {
  final CatalogSource source;
  final int sourceId;
  final CinemaType cinemaType;
  final String title;
  final String? posterPath;
  final String? year;
  final double? rating;

  const RecommendedTitle({
    required this.source,
    required this.sourceId,
    required this.cinemaType,
    required this.title,
    this.posterPath,
    this.year,
    this.rating,
  });

  factory RecommendedTitle.fromJson(Map<String, dynamic> json) =>
      RecommendedTitle(
        source: CatalogSource.fromJson(json['source'] as String?),
        sourceId: json['sourceId'] as int,
        cinemaType: CinemaType.fromJson(json['cinemaType'] as String? ?? ''),
        title: json['title'] as String? ?? 'Untitled',
        posterPath: json['posterPath'] as String?,
        year: json['year'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
      );

  /// The anime upstream returns full image URLs; TMDB returns relative paths.
  String get posterUrl {
    final path = posterPath;
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http')
        ? path
        : '${ApiConstants.tmdbImageBase}/w500$path';
  }

  String get ratingDisplay => rating != null ? rating!.toStringAsFixed(1) : '—';
}
