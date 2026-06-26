import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/discover/models/search_result_item.dart';

class DiscoverRepository {
  final ApiClient _apiClient;

  DiscoverRepository(this._apiClient);

  Future<List<SearchResultItem>> searchAll(String query) =>
      _searchTmdb(query, 'multi');

  Future<List<SearchResultItem>> searchMovies(String query) =>
      _searchTmdb(query, 'movie');

  Future<List<SearchResultItem>> searchSeries(String query) =>
      _searchTmdb(query, 'tv');

  Future<List<SearchResultItem>> searchAnime(String query) async {
    final res = await _apiClient.dio.get(
      '/anilist/search',
      queryParameters: {'q': query},
    );
    return (res.data['data'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(SearchResultItem.fromAniList)
        .toList();
  }

  // Genre-based discovery — hits the new /tmdb/discover endpoint
  Future<List<SearchResultItem>> discoverByGenre(
    int genreId,
    String type, {
    int page = 1,
  }) async {
    final res = await _apiClient.dio.get(
      '/tmdb/discover',
      queryParameters: {
        'type': type,
        'genre_id': genreId,
        'page': page,
      },
    );
    final items = (res.data['results'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((e) => SearchResultItem.fromTmdbDiscover(e, type))
        .where((e) => e.posterPath != null && e.posterPath!.isNotEmpty)
        .toList();
    return items;
  }

  Future<List<SearchResultItem>> _searchTmdb(String query, String type) async {
    final res = await _apiClient.dio.get(
      '/tmdb/search',
      queryParameters: {'q': query, 'type': type},
    );
    return (res.data['results'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .where((e) {
          // multi returns people too — skip them
          final mt = e['media_type'] as String?;
          return mt == null || mt == 'movie' || mt == 'tv';
        })
        .map(SearchResultItem.fromTmdb)
        .where((e) => e.posterPath != null && e.posterPath!.isNotEmpty)
        .toList();
  }

}
