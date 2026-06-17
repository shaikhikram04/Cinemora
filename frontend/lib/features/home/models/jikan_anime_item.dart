class JikanAnimeItem {
  final int id;
  final String title;
  final String imageUrl;
  final double? score;
  final int? year;

  const JikanAnimeItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.score,
    this.year,
  });

  factory JikanAnimeItem.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;
    return JikanAnimeItem(
      id: json['mal_id'] as int,
      title: (json['title_english'] ?? json['title'] ?? '') as String,
      imageUrl: (jpg?['large_image_url'] ?? jpg?['image_url'] ?? '') as String,
      score: (json['score'] as num?)?.toDouble(),
      year: json['year'] as int?,
    );
  }

  String get ratingDisplay => score != null ? score!.toStringAsFixed(1) : '—';
}
