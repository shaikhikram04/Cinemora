class SeriesEpisode {
  final int number;
  final String title;
  final String runtime;

  const SeriesEpisode({
    required this.number,
    required this.title,
    required this.runtime,
  });
}

class SeriesSeason {
  final int number;
  final String year;
  final String rating;
  final List<SeriesEpisode> episodes;
  // MAL ID for anime seasons — used for lazy episode loading via Jikan
  final int? malId;
  // TMDB season ID — set for TMDB TV show seasons
  final int? seasonId;

  const SeriesSeason({
    required this.number,
    required this.year,
    required this.rating,
    required this.episodes,
    this.malId,
    this.seasonId,
  });

  int get episodeCount => episodes.length;

  // Unique ID usable as a library entry key: anime uses malId, TMDB uses seasonId
  int? get libraryId => malId ?? seasonId;

  SeriesSeason copyWith({List<SeriesEpisode>? episodes}) {
    return SeriesSeason(
      number: number,
      year: year,
      rating: rating,
      episodes: episodes ?? this.episodes,
      malId: malId,
      seasonId: seasonId,
    );
  }
}
