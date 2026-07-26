import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/tour/tour_mode.dart';

class LibraryRepository {
  final ApiClient _apiClient;

  /// While the first-run tour is running, the three mutating methods below
  /// answer from memory instead of the network — see [TourMode]. Reads are
  /// left alone: the tour has no reason to hide the user's real library from
  /// them, and it starts empty for the new accounts that get the tour anyway.
  final TourMode _tourMode;

  LibraryRepository(this._apiClient, this._tourMode);

  /// Stand-in for the entry the server would have returned. Carries a marked
  /// id so anything that reaches for one can't mistake it for a saved row.
  LibraryEntryModel _localEntry({
    required int tmdbId,
    required CinemaType cinemaType,
    required String title,
    String? posterPath,
    String? releaseYear,
    List<String> genres = const [],
    double? tmdbRating,
    int? runtimeMinutes,
    String? originalLanguage,
    required WatchStatus status,
    double? userRating,
  }) {
    final now = DateTime.now();
    return LibraryEntryModel(
      id: 'tour-local-$tmdbId-${cinemaType.apiValue}',
      tmdbId: tmdbId,
      cinemaType: cinemaType,
      title: title,
      posterPath: posterPath,
      releaseYear: releaseYear,
      status: status,
      userRating: userRating,
      genres: genres,
      tmdbRating: tmdbRating,
      runtimeMinutes: runtimeMinutes,
      originalLanguage: originalLanguage,
      watchedAt: status == WatchStatus.watched ? [now] : const [],
      createdAt: now,
      updatedAt: now,
    );
  }

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
    if (_tourMode.isActive) {
      return _localEntry(
        tmdbId: tmdbId,
        cinemaType: cinemaType,
        title: title,
        posterPath: posterPath,
        releaseYear: releaseYear,
        genres: genres,
        tmdbRating: tmdbRating,
        runtimeMinutes: runtimeMinutes,
        originalLanguage: originalLanguage,
        status: status,
      );
    }
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
    // Nothing here can reconstruct the row's title or artwork, so the return
    // value is a placeholder — LibraryCubit keeps its own optimistic copy in
    // tour mode rather than overwriting it with this.
    if (_tourMode.isActive) {
      return _localEntry(
        tmdbId: tmdbId,
        cinemaType: cinemaType,
        title: '',
        status: status ?? WatchStatus.watchlist,
        userRating: userRating,
        runtimeMinutes: runtimeMinutes,
      );
    }
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
    // Reachable during the tour: its first step spotlights a watchlist toggle,
    // and tapping it twice removes what the first tap added.
    if (_tourMode.isActive) return;
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
    if (_tourMode.isActive) {
      return _localEntry(
        tmdbId: tmdbId,
        cinemaType: cinemaType,
        title: title,
        posterPath: posterPath,
        releaseYear: releaseYear,
        genres: genres,
        tmdbRating: tmdbRating,
        runtimeMinutes: runtimeMinutes,
        originalLanguage: originalLanguage,
        status: status,
        userRating: userRating,
      );
    }
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
    if (_tourMode.isActive) {
      return _localEntry(
        tmdbId: tmdbId,
        cinemaType: cinemaType,
        title: showTitle,
        posterPath: posterPath,
        releaseYear: releaseYear,
        genres: genres,
        tmdbRating: tmdbRating,
        originalLanguage: originalLanguage,
        status: status,
        userRating: rating,
      );
    }
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
    // Belt and braces. Season controls sit outside the spotlight on every step
    // that reaches a series detail screen, so the tour can't get here — but the
    // guarantee this whole file is making is "no tour write reaches the
    // server", and an exception to that is worth more as a closed door than as
    // a comment. The return is a placeholder for the same reason [updateEntry]'s
    // is: an unreachable path doesn't need a faithful one.
    if (_tourMode.isActive) {
      return _localEntry(
        tmdbId: tmdbId,
        cinemaType: cinemaType,
        title: '',
        status: WatchStatus.watchlist,
      );
    }
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
