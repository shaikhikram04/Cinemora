class TmdbItem {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final String mediaType; // "movie" | "tv"

  const TmdbItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.releaseDate,
    required this.mediaType,
  });

  factory TmdbItem.fromJson(Map<String, dynamic> json) {
    return TmdbItem(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      mediaType: json['media_type'] as String? ?? 'movie',
    );
  }

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get backdropUrl =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : '';

  String get year => releaseDate?.split('-').first ?? '';

  String get ratingDisplay => voteAverage.toStringAsFixed(1);

  String get mediaTypeLabel => mediaType == 'tv' ? 'TV Show' : 'Movie';

}
