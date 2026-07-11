import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/home/models/home_recommendations.dart';
import 'package:cinemora/features/home/models/jikan_anime_item.dart';
import 'package:cinemora/features/home/models/mood_reply.dart';
import 'package:cinemora/features/home/models/series_season.dart';
import 'package:cinemora/features/home/models/similar_item.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';
import 'package:cinemora/features/home/models/tmdb_item.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  Future<List<TmdbItem>> fetchTrendingMovies() async {
    final res = await _apiClient.dio.get(
      '/tmdb/trending',
      queryParameters: {'type': 'movie', 'time': 'week'},
    );
    final results = res.data['results'] as List;
    return results
        .map((e) => TmdbItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TmdbItem>> fetchTrendingSeries() async {
    final res = await _apiClient.dio.get(
      '/tmdb/trending',
      queryParameters: {'type': 'tv', 'time': 'week'},
    );
    final results = res.data['results'] as List;
    return results
        .map((e) => TmdbItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<JikanAnimeItem>> fetchTopAnime() async {
    final res = await _apiClient.dio.get(
      '/jikan/top',
      queryParameters: {'filter': 'bypopularity', 'type': 'tv', 'limit': 10},
    );
    final results = res.data['data'] as List;
    return results
        .map((e) => JikanAnimeItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HomeRecommendations> fetchHomeRecommendations(
      {CinemaType? type}) async {
    final res =
        await _apiClient.dio.get('/recommendations/home', queryParameters: {
      'type': type?.apiValue ?? 'all',
    });
    return HomeRecommendations.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<SimilarItem>> fetchSimilar(
      CinemaType cinemaType, int sourceId) async {
    final res = await _apiClient.dio.get(
      '/recommendations/similar/${cinemaType.apiValue}/$sourceId',
    );
    final results = res.data as List;
    return results
        .map((e) => SimilarItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Mood chat — sessionId is null on the first message, then echoed back to
  // continue the same conversation. Rate-limit / not-configured errors come
  // back as BackendException with a user-facing message.
  Future<MoodReply> sendMoodMessage(
      {String? sessionId, required String message}) async {
    final res = await _apiClient.dio.post(
      '/recommendations/mood/message',
      data: {
        if (sessionId != null) 'sessionId': sessionId,
        'message': message,
      },
    );
    return MoodReply.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TmdbMovieDetail> fetchMovieDetail(int id) async {
    final results = await Future.wait([
      _apiClient.dio.get('/tmdb/movie/$id'),
      _apiClient.dio.get('/tmdb/movie/$id/watch-providers'),
    ]);
    return TmdbMovieDetail.fromJson(
      results[0].data as Map<String, dynamic>,
      results[1].data as Map<String, dynamic>,
    );
  }

  Future<TmdbTvDetail> fetchTvDetail(int id) async {
    final results = await Future.wait([
      _apiClient.dio.get('/tmdb/tv/$id'),
      _apiClient.dio.get('/tmdb/tv/$id/watch-providers'),
    ]);
    return TmdbTvDetail.fromJson(
      results[0].data as Map<String, dynamic>,
      results[1].data as Map<String, dynamic>,
    );
  }

  Future<SeriesSeason> fetchTvSeasonEpisodes(int tvId, int seasonNumber) async {
    final res = await _apiClient.dio.get('/tmdb/tv/$tvId/season/$seasonNumber');
    final data = res.data as Map<String, dynamic>;
    final episodes = (data['episodes'] as List? ?? [])
        .cast<Map>()
        .map((e) {
          final runtime = e['runtime'] as int?;
          return SeriesEpisode(
            number: e['episode_number'] as int? ?? 0,
            title: e['name'] as String? ?? 'Episode ${e['episode_number']}',
            runtime: runtime != null && runtime > 0 ? '${runtime}m' : '—',
          );
        })
        .where((e) => e.number > 0)
        .toList();

    final airYear = (data['air_date'] as String? ?? '').split('-').first;
    final voteAvg = (data['vote_average'] as num?)?.toDouble() ?? 0.0;

    return SeriesSeason(
      number: seasonNumber,
      year: airYear,
      rating: voteAvg > 0 ? voteAvg.toStringAsFixed(1) : '—',
      episodes: episodes.isEmpty
          ? List.generate(
              1,
              (i) => SeriesEpisode(
                  number: i + 1, title: 'Episode ${i + 1}', runtime: '—'))
          : episodes,
    );
  }

  // Single GraphQL request — replaces the old 4-call Jikan approach
  Future<TmdbTvDetail> fetchAnimeDetail(int id) async {
    final res = await _apiClient.dio.get('/anilist/anime/$id');
    return TmdbTvDetail.fromAniListJson(res.data as Map<String, dynamic>);
  }

  // Lazy episode loader — called by the cubit when a season is selected
  Future<List<SeriesEpisode>> fetchAnimeEpisodes(int malId) async {
    final ep1Res = await _apiClient.dio.get(
      '/jikan/anime/$malId/episodes',
      queryParameters: {'page': 1},
    );
    final rawEps = await _paginateAnimeEpisodes(
        malId, ep1Res.data as Map<String, dynamic>);
    return rawEps
        .map((e) => SeriesEpisode(
              number: e['mal_id'] as int? ?? 0,
              title: e['title'] as String? ?? 'Episode ${e['mal_id']}',
              runtime: '24m',
            ))
        .where((e) => e.number > 0)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _paginateAnimeEpisodes(
    int malId,
    Map<String, dynamic> firstPage,
  ) async {
    final eps = List<Map<String, dynamic>>.from(
      (firstPage['data'] as List? ?? []).cast<Map<String, dynamic>>(),
    );
    var hasNext =
        (firstPage['pagination'] as Map?)?['has_next_page'] as bool? ?? false;
    var page = 2;
    while (hasNext && page <= 6) {
      try {
        final res = await _apiClient.dio.get(
          '/jikan/anime/$malId/episodes',
          queryParameters: {'page': page},
        );
        final data = res.data as Map<String, dynamic>;
        eps.addAll((data['data'] as List? ?? []).cast<Map<String, dynamic>>());
        hasNext =
            (data['pagination'] as Map?)?['has_next_page'] as bool? ?? false;
        page++;
      } catch (_) {
        break;
      }
    }
    return eps;
  }
}
