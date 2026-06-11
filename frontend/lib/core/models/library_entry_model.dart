import 'package:equatable/equatable.dart';

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
    required this.updatedAt,
  });

  factory LibraryEntryModel.fromJson(Map<String, dynamic> json) {
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
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

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

  @override
  List<Object?> get props =>
      [id, tmdbId, cinemaType, title, posterPath, releaseYear, status, userRating, genres, updatedAt];
}
