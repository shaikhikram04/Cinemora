import 'package:equatable/equatable.dart';

// ── Season entry (embedded in LibraryEntryModel) ──────────────────────────────

class LibrarySeasonEntry extends Equatable {
  final int seasonNumber;
  final int? seasonId; // TMDB season ID or MAL ID — null for Jikan seasons
  final String status; // "watchlist" | "watched" | "dropped"
  final double? rating;

  const LibrarySeasonEntry({
    required this.seasonNumber,
    this.seasonId,
    required this.status,
    this.rating,
  });

  factory LibrarySeasonEntry.fromJson(Map<String, dynamic> json) =>
      LibrarySeasonEntry(
        seasonNumber: json['seasonNumber'] as int,
        seasonId: json['seasonId'] as int?,
        status: json['status'] as String,
        rating: (json['rating'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'seasonNumber': seasonNumber,
        if (seasonId != null) 'seasonId': seasonId,
        'status': status,
        if (rating != null) 'rating': rating,
      };

  @override
  List<Object?> get props => [seasonNumber, seasonId, status, rating];
}

// ── Progress (episode-level, kept for backwards compat) ───────────────────────

class LibraryProgress extends Equatable {
  final int? currentSeason;
  final int? currentEpisode;
  final int? totalSeasons;
  final int? totalEpisodes;

  const LibraryProgress({
    this.currentSeason,
    this.currentEpisode,
    this.totalSeasons,
    this.totalEpisodes,
  });

  factory LibraryProgress.fromJson(Map<String, dynamic> json) =>
      LibraryProgress(
        currentSeason: json['currentSeason'] as int?,
        currentEpisode: json['currentEpisode'] as int?,
        totalSeasons: json['totalSeasons'] as int?,
        totalEpisodes: json['totalEpisodes'] as int?,
      );

  Map<String, dynamic> toJson() => {
        if (currentSeason != null) 'currentSeason': currentSeason,
        if (currentEpisode != null) 'currentEpisode': currentEpisode,
        if (totalSeasons != null) 'totalSeasons': totalSeasons,
        if (totalEpisodes != null) 'totalEpisodes': totalEpisodes,
      };

  double get progressFraction {
    if (totalEpisodes == null || totalEpisodes == 0 || currentEpisode == null) {
      return 0.0;
    }
    return (currentEpisode! / totalEpisodes!).clamp(0.0, 1.0);
  }

  String get label {
    if (currentEpisode == null) return '';
    final s = currentSeason != null ? 'S$currentSeason · ' : '';
    final of = totalEpisodes != null ? ' of $totalEpisodes' : '';
    return '${s}E$currentEpisode$of';
  }

  @override
  List<Object?> get props =>
      [currentSeason, currentEpisode, totalSeasons, totalEpisodes];
}

// ── Library entry ─────────────────────────────────────────────────────────────

class LibraryEntryModel extends Equatable {
  final String id;
  final int tmdbId;
  final String cinemaType; // "movie" | "tv" | "anime"
  final String title;
  final String? posterPath;
  final String? releaseYear;
  final String status; // "watchlist" | "watching" | "watched" | "dropped"
  final double? userRating;
  final List<String> genres;
  final double? tmdbRating;
  final int? runtimeMinutes;
  final LibraryProgress? progress;
  final List<LibrarySeasonEntry> seasons;
  final List<DateTime> watchedAt;
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LibraryEntryModel({
    required this.id,
    required this.tmdbId,
    required this.cinemaType,
    required this.title,
    this.posterPath,
    this.releaseYear,
    required this.status,
    this.userRating,
    this.genres = const [],
    this.tmdbRating,
    this.runtimeMinutes,
    this.progress,
    this.seasons = const [],
    this.watchedAt = const [],
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  LibraryEntryModel copyWith({
    String? id,
    int? tmdbId,
    String? cinemaType,
    String? title,
    String? posterPath,
    String? releaseYear,
    String? status,
    double? userRating,
    List<String>? genres,
    double? tmdbRating,
    int? runtimeMinutes,
    LibraryProgress? progress,
    List<LibrarySeasonEntry>? seasons,
    List<DateTime>? watchedAt,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LibraryEntryModel(
      id: id ?? this.id,
      tmdbId: tmdbId ?? this.tmdbId,
      cinemaType: cinemaType ?? this.cinemaType,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      releaseYear: releaseYear ?? this.releaseYear,
      status: status ?? this.status,
      userRating: userRating ?? this.userRating,
      genres: genres ?? this.genres,
      tmdbRating: tmdbRating ?? this.tmdbRating,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      progress: progress ?? this.progress,
      seasons: seasons ?? this.seasons,
      watchedAt: watchedAt ?? this.watchedAt,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory LibraryEntryModel.fromJson(Map<String, dynamic> json) {
    final progressJson = json['progress'] as Map<String, dynamic>?;
    final watchedAtList = (json['watchedAt'] as List?)
            ?.map((e) => DateTime.parse(e as String))
            .toList() ??
        [];
    final seasonsList = (json['seasons'] as List? ?? [])
        .map((e) => LibrarySeasonEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return LibraryEntryModel(
      id: (json['_id'] ?? json['id']).toString(),
      tmdbId: json['tmdbId'] as int,
      cinemaType: json['cinemaType'] as String,
      title: json['title'] as String,
      posterPath: json['posterPath'] as String?,
      releaseYear: json['releaseYear'] as String?,
      status: json['status'] as String,
      userRating: (json['userRating'] as num?)?.toDouble(),
      genres: List<String>.from(json['genres'] as List? ?? []),
      tmdbRating: (json['tmdbRating'] as num?)?.toDouble(),
      runtimeMinutes: json['runtimeMinutes'] as int?,
      progress: progressJson != null && progressJson.isNotEmpty
          ? LibraryProgress.fromJson(progressJson)
          : null,
      seasons: seasonsList,
      watchedAt: watchedAtList,
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get posterUrl {
    if (posterPath == null || posterPath!.isEmpty) return '';
    if (posterPath!.startsWith('http')) return posterPath!;
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get displayType {
    switch (cinemaType) {
      case 'movie':
        return 'Movie';
      case 'tv':
        return 'Series';
      case 'anime':
        return 'Anime';
      default:
        return cinemaType;
    }
  }

  String get displayStatus {
    switch (status) {
      case 'watchlist':
        return 'Watchlist';
      case 'watching':
        return 'Watching';
      case 'watched':
        return 'Watched';
      case 'dropped':
        return 'Dropped';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
        id,
        tmdbId,
        cinemaType,
        title,
        posterPath,
        releaseYear,
        status,
        userRating,
        genres,
        tmdbRating,
        runtimeMinutes,
        progress,
        seasons,
        watchedAt,
        review,
        createdAt,
        updatedAt,
      ];
}
