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

  const SeriesSeason({
    required this.number,
    required this.year,
    required this.rating,
    required this.episodes,
  });

  int get episodeCount => episodes.length;
}
