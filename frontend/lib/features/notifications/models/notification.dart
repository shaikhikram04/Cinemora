enum NotificationType { newRelease, newSeason, system }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final int? tmdbId;
  final String? cinemaType; // "movie" | "tv" | "anime"
  final String? posterPath;
  final int? season;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.tmdbId,
    this.cinemaType,
    this.posterPath,
    this.season,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return AppNotification(
      id: json['_id'] as String,
      type: switch (json['type'] as String?) {
        'new_release' => NotificationType.newRelease,
        'new_season' => NotificationType.newSeason,
        _ => NotificationType.system,
      },
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tmdbId: (data['tmdbId'] as num?)?.toInt(),
      cinemaType: data['cinemaType'] as String?,
      posterPath: data['posterPath'] as String?,
      season: (data['season'] as num?)?.toInt(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Anime entries carry a full image URL; TMDB entries a relative path.
  /// w185 is plenty for the 48px inbox thumbnail.
  String? get posterUrl => _posterUrl('w185');

  /// Full-size variant for the detail screen's hero — same w500 the library
  /// rows pass, so a poster opened from a notification isn't blurry.
  String? get posterUrlLarge => _posterUrl('w500');

  String? _posterUrl(String size) {
    final path = posterPath;
    if (path == null || path.isEmpty) return null;
    return path.startsWith('http')
        ? path
        : 'https://image.tmdb.org/t/p/$size$path';
  }

  String get timeLabel {
    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        tmdbId: tmdbId,
        cinemaType: cinemaType,
        posterPath: posterPath,
        season: season,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
