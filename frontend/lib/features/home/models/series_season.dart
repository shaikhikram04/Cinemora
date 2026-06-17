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
  // MAL ID for this season — set on Jikan/AniList seasons for lazy episode loading
  final int? malId;

  const SeriesSeason({
    required this.number,
    required this.year,
    required this.rating,
    required this.episodes,
    this.malId,
  });

  int get episodeCount => episodes.length;

  SeriesSeason copyWith({List<SeriesEpisode>? episodes}) {
    return SeriesSeason(
      number: number,
      year: year,
      rating: rating,
      episodes: episodes ?? this.episodes,
      malId: malId,
    );
  }
}
