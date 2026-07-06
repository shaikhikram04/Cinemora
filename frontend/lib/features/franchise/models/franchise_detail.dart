import 'package:equatable/equatable.dart';
import 'package:cinemora/core/constants/api_constants.dart';

class FranchiseMovieItem extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String year;
  final double rating;

  const FranchiseMovieItem({
    required this.id,
    required this.title,
    this.posterPath,
    required this.year,
    required this.rating,
  });

  String get posterUrl => posterPath != null && posterPath!.isNotEmpty
      ? '${ApiConstants.tmdbImageBase}/w342$posterPath'
      : '';

  String get ratingDisplay => rating > 0 ? rating.toStringAsFixed(1) : '—';

  factory FranchiseMovieItem.fromJson(Map<String, dynamic> json) {
    final releaseDate = json['release_date'] as String? ?? '';
    return FranchiseMovieItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      year: releaseDate.isNotEmpty ? releaseDate.split('-').first : '',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, title, posterPath, year, rating];
}

class FranchiseDetail extends Equatable {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final List<FranchiseMovieItem> movies;

  const FranchiseDetail({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.movies,
  });

  String get backdropUrl => backdropPath != null && backdropPath!.isNotEmpty
      ? '${ApiConstants.tmdbImageBase}/w780$backdropPath'
      : '';

  factory FranchiseDetail.fromJson(Map<String, dynamic> json) {
    final parts = (json['parts'] as List? ?? []).cast<Map<String, dynamic>>();
    // Release dates are ISO (YYYY-MM-DD) so lexical sort == chronological sort.
    final sortedParts = List<Map<String, dynamic>>.from(parts)
      ..sort((a, b) => (a['release_date'] as String? ?? '9999')
          .compareTo(b['release_date'] as String? ?? '9999'));

    return FranchiseDetail(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      movies: sortedParts.map(FranchiseMovieItem.fromJson).toList(),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, overview, posterPath, backdropPath, movies];
}
