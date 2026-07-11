class SimilarItem {
  final String source; // "tmdb" | "jikan"
  final int sourceId;
  final String cinemaType; // "movie" | "tv" | "anime"
  final String title;
  final String? posterPath;
  final String? year;
  final double? rating;

  const SimilarItem({
    required this.source,
    required this.sourceId,
    required this.cinemaType,
    required this.title,
    this.posterPath,
    this.year,
    this.rating,
  });

  factory SimilarItem.fromJson(Map<String, dynamic> json) => SimilarItem(
        source: json['source'] as String? ?? 'tmdb',
        sourceId: json['sourceId'] as int,
        cinemaType: json['cinemaType'] as String? ?? 'movie',
        title: json['title'] as String? ?? 'Untitled',
        posterPath: json['posterPath'] as String?,
        year: json['year'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
      );

  // Jikan posters are already full URLs; TMDB posters are relative paths.
  String get posterUrl {
    final path = posterPath;
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : 'https://image.tmdb.org/t/p/w500$path';
  }

  String get ratingDisplay => rating != null ? rating!.toStringAsFixed(1) : '—';
}
