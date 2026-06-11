import 'package:equatable/equatable.dart';

class GenreCount extends Equatable {
  final String genre;
  final int count;

  const GenreCount({required this.genre, required this.count});

  factory GenreCount.fromJson(Map<String, dynamic> json) {
    return GenreCount(
      genre: json['genre'] as String,
      count: json['count'] as int,
    );
  }

  @override
  List<Object?> get props => [genre, count];
}

class LibraryStatsModel extends Equatable {
  final int totalEntries;
  final int watched;
  final int watchlist;
  final int watching;
  final int dropped;
  final int movies;
  final int tvShows;
  final int anime;
  final int totalWatchMinutes;
  final int rewatchCount;
  final List<GenreCount> topGenres;

  const LibraryStatsModel({
    this.totalEntries = 0,
    this.watched = 0,
    this.watchlist = 0,
    this.watching = 0,
    this.dropped = 0,
    this.movies = 0,
    this.tvShows = 0,
    this.anime = 0,
    this.totalWatchMinutes = 0,
    this.rewatchCount = 0,
    this.topGenres = const [],
  });

  factory LibraryStatsModel.fromJson(Map<String, dynamic> json) {
    final byStatus = json['byStatus'] as Map<String, dynamic>? ?? {};
    final byCinemaType = json['byCinemaType'] as Map<String, dynamic>? ?? {};
    final genreList = (json['topGenres'] as List?)
            ?.map((e) => GenreCount.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return LibraryStatsModel(
      totalEntries: json['totalEntries'] as int? ?? 0,
      watched: byStatus['watched'] as int? ?? 0,
      watchlist: byStatus['watchlist'] as int? ?? 0,
      watching: byStatus['watching'] as int? ?? 0,
      dropped: byStatus['dropped'] as int? ?? 0,
      movies: byCinemaType['movie'] as int? ?? 0,
      tvShows: byCinemaType['tv'] as int? ?? 0,
      anime: byCinemaType['anime'] as int? ?? 0,
      totalWatchMinutes: json['totalWatchMinutes'] as int? ?? 0,
      rewatchCount: json['rewatchCount'] as int? ?? 0,
      topGenres: genreList,
    );
  }

  int get totalWatchHours => (totalWatchMinutes / 60).round();

  String? get topGenreName =>
      topGenres.isNotEmpty ? topGenres.first.genre : null;

  @override
  List<Object?> get props => [
        totalEntries, watched, watchlist, watching, dropped,
        movies, tvShows, anime, totalWatchMinutes, rewatchCount, topGenres,
      ];
}
