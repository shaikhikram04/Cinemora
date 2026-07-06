import 'package:equatable/equatable.dart';
import 'package:cinemora/core/constants/api_constants.dart';

class FranchiseSummary extends Equatable {
  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;
  final int? movieCount;

  const FranchiseSummary({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
    this.movieCount,
  });

  String get posterUrl => posterPath != null && posterPath!.isNotEmpty
      ? '${ApiConstants.tmdbImageBase}/w342$posterPath'
      : '';

  String get backdropUrl => backdropPath != null && backdropPath!.isNotEmpty
      ? '${ApiConstants.tmdbImageBase}/w780$backdropPath'
      : '';

  // From our own backend's /tmdb/collection/featured (already slimmed down)
  factory FranchiseSummary.fromFeaturedJson(Map<String, dynamic> json) =>
      FranchiseSummary(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        posterPath: json['posterPath'] as String?,
        backdropPath: json['backdropPath'] as String?,
        movieCount: json['movieCount'] as int?,
      );

  // From raw TMDB responses: /search/collection results, or a
  // movie's belongs_to_collection object (neither includes `parts`).
  factory FranchiseSummary.fromTmdbJson(Map<String, dynamic> json) =>
      FranchiseSummary(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        posterPath: json['poster_path'] as String?,
        backdropPath: json['backdrop_path'] as String?,
        movieCount: (json['parts'] as List?)?.length,
      );

  @override
  List<Object?> get props => [id, name, posterPath, backdropPath, movieCount];
}
