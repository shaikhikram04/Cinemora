enum CinemaType {
  movie,
  tv,
  anime;

  String get apiValue => name; // 'movie', 'tv', 'anime'

  static CinemaType fromJson(String value) => switch (value) {
        'movie' => CinemaType.movie,
        'tv' => CinemaType.tv,
        'anime' => CinemaType.anime,
        _ => CinemaType.movie,
      };

  // Maps UI filter display labels to enum values. Returns null for 'All'.
  static CinemaType? fromDisplayName(String display) => switch (display) {
        'Movies' => CinemaType.movie,
        'Series' => CinemaType.tv,
        'Anime' => CinemaType.anime,
        _ => null,
      };

  String get displayName => switch (this) {
        CinemaType.movie => 'Movie',
        CinemaType.tv => 'Series',
        CinemaType.anime => 'Anime',
      };
}
