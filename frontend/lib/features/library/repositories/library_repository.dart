import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/network/api_client.dart';

class LibraryRepository {
  final ApiClient _apiClient;

  LibraryRepository(this._apiClient);

  // ── Collection ────────────────────────────────────────────────────────────

  Future<List<LibraryEntryModel>> fetchEntries() async {
    try {
      final res = await _apiClient.dio.get('/library');
      final list = res.data as List;
      return list
          .map((e) => LibraryEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<LibraryStatsModel> fetchStats() async {
    try {
      final res = await _apiClient.dio.get('/library/stats');
      return LibraryStatsModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  // ── Single entry CRUD ─────────────────────────────────────────────────────

  Future<LibraryEntryModel> addEntry({
    required int tmdbId,
    required CinemaType cinemaType,
    required String title,
    String? posterPath,
    String? releaseYear,
    List<String> genres = const [],
    double? tmdbRating,
    int? runtimeMinutes,
    String? originalLanguage,
    WatchStatus status = WatchStatus.watchlist,
  }) async {
    try {
      final res = await _apiClient.dio.post('/library', data: {
        'tmdbId': tmdbId,
        'cinemaType': cinemaType.apiValue,
        'title': title,
        if (posterPath != null) 'posterPath': posterPath,
        if (releaseYear != null) 'releaseYear': releaseYear,
        'genres': genres,
        if (tmdbRating != null) 'tmdbRating': tmdbRating,
        if (runtimeMinutes != null) 'runtimeMinutes': runtimeMinutes,
        if (originalLanguage != null) 'originalLanguage': originalLanguage,
        'status': status.apiValue,
      });
      return LibraryEntryModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  /// Looks up an entry by its compound key (tmdbId + cinemaType).
  Future<LibraryEntryModel?> getEntry(int tmdbId, CinemaType cinemaType) async {
    try {
      final res = await _apiClient.dio.get(
        '/library/$tmdbId',
        queryParameters: {'type': cinemaType.apiValue},
      );
      return LibraryEntryModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      final err = ApiClient.parseError(e);
      if (err is BackendException && err.code == 'LIBRARY_ENTRY_NOT_FOUND') {
        return null;
      }
      throw err;
    }
  }

  /// Updates show-level fields. Requires cinemaType to resolve the compound key.
  Future<LibraryEntryModel> updateEntry(
    int tmdbId,
    CinemaType cinemaType, {
    WatchStatus? status,
    double? userRating,
    String? review,
    LibraryProgress? progress,
    int? runtimeMinutes,
  }) async {
    try {
      final res = await _apiClient.dio.put(
        '/library/$tmdbId',
        queryParameters: {'type': cinemaType.apiValue},
        data: {
          if (status != null) 'status': status.apiValue,
          if (userRating != null) 'userRating': userRating,
          if (review != null) 'review': review,
          if (progress != null) 'progress': progress.toJson(),
          if (runtimeMinutes != null) 'runtimeMinutes': runtimeMinutes,
        },
      );
      return LibraryEntryModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  /// Deletes a show-level entry. Requires cinemaType to resolve the compound key.
  Future<void> deleteEntry(int tmdbId, CinemaType cinemaType) async {
    try {
      await _apiClient.dio.delete(
        '/library/$tmdbId',
        queryParameters: {'type': cinemaType.apiValue},
      );
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  /// Atomically creates or returns the existing show entry in one round trip.
  Future<LibraryEntryModel> upsertEntry({
    required int tmdbId,
    required CinemaType cinemaType,
    required String title,
    String? posterPath,
    String? releaseYear,
    List<String> genres = const [],
    double? tmdbRating,
    int? runtimeMinutes,
    String? originalLanguage,
    WatchStatus status = WatchStatus.watchlist,
    double? userRating,
    LibraryProgress? progress,
  }) async {
    try {
      final res = await _apiClient.dio.post('/library/upsert', data: {
        'tmdbId': tmdbId,
        'cinemaType': cinemaType.apiValue,
        'title': title,
        if (posterPath != null) 'posterPath': posterPath,
        if (releaseYear != null) 'releaseYear': releaseYear,
        'genres': genres,
        if (tmdbRating != null) 'tmdbRating': tmdbRating,
        if (runtimeMinutes != null) 'runtimeMinutes': runtimeMinutes,
        if (originalLanguage != null) 'originalLanguage': originalLanguage,
        'status': status.apiValue,
        if (userRating != null) 'userRating': userRating,
        if (progress != null) 'progress': progress.toJson(),
      });
      return LibraryEntryModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  // ── Season-level CRUD ─────────────────────────────────────────────────────

  /// Upserts a single season entry within the show document.
  /// Creates the parent show document if it doesn't exist yet.
  Future<LibraryEntryModel> upsertSeason({
    required int tmdbId,
    required CinemaType cinemaType,
    required int seasonNumber,
    int? seasonId,
    required WatchStatus status,
    double? rating,
    // Show-level fields — used to create the parent doc when absent
    required String showTitle,
    String? posterPath,
    String? releaseYear,
    List<String> genres = const [],
    double? tmdbRating,
    String? originalLanguage,
  }) async {
    try {
      final res = await _apiClient.dio.put(
        '/library/$tmdbId/seasons/$seasonNumber',
        queryParameters: {'type': cinemaType.apiValue},
        data: {
          if (seasonId != null) 'seasonId': seasonId,
          'status': status.apiValue,
          if (rating != null) 'rating': rating,
          // Show-level data for backend to create parent doc if missing
          'cinemaType': cinemaType.apiValue,
          'title': showTitle,
          if (posterPath != null) 'posterPath': posterPath,
          if (releaseYear != null) 'releaseYear': releaseYear,
          'genres': genres,
          if (tmdbRating != null) 'tmdbRating': tmdbRating,
          if (originalLanguage != null) 'originalLanguage': originalLanguage,
        },
      );
      return LibraryEntryModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  /// Removes a single season entry from the show document.
  Future<LibraryEntryModel> deleteSeason({
    required int tmdbId,
    required CinemaType cinemaType,
    required int seasonNumber,
  }) async {
    try {
      final res = await _apiClient.dio.delete(
        '/library/$tmdbId/seasons/$seasonNumber',
        queryParameters: {'type': cinemaType.apiValue},
      );
      return LibraryEntryModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }
}
