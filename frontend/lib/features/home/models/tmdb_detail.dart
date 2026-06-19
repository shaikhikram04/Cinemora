import 'package:cinemora/core/constants/assets_path.dart';
import 'package:cinemora/features/home/models/series_season.dart';

class CastMember {
  final String name;
  final String character;
  final String? profileUrl;

  const CastMember({
    required this.name,
    required this.character,
    this.profileUrl,
  });
}

class StreamingProvider {
  final String name;
  final String type; // "Subscription" | "Rent" | "Buy"
  final String? assetPath;
  final String? logoUrl;

  const StreamingProvider({
    required this.name,
    required this.type,
    this.assetPath,
    this.logoUrl,
  });

  String? get webUrl {
    final l = name.toLowerCase();
    if (l.contains('netflix')) return 'https://www.netflix.com';
    if (l.contains('prime') || l.contains('amazon')) {
      return 'https://www.primevideo.com';
    }
    if (l.contains('disney')) return 'https://www.disneyplus.com';
    if (l.contains('apple')) return 'https://tv.apple.com';
    if (l.contains('hotstar') || l.contains('jio')) {
      return 'https://www.hotstar.com';
    }
    if (l.contains('crunchyroll')) return 'https://www.crunchyroll.com';
    if (l.contains('mubi')) return 'https://mubi.com';
    if (l.contains('sony')) return 'https://www.sonyliv.com';
    if (l.contains('zee5')) return 'https://www.zee5.com';
    if (l.contains('hbo') || l.contains('max')) return 'https://www.max.com';
    if (l.contains('hulu')) return 'https://www.hulu.com';
    if (l.contains('peacock')) return 'https://www.peacocktv.com';
    if (l.contains('paramount')) return 'https://www.paramountplus.com';
    if (l.contains('discovery')) return 'https://www.discoveryplus.com';
    return null;
  }
}

// ─── Movie detail ─────────────────────────────────────────────────────────────

class TmdbMovieDetail {
  final String overview;
  final List<String> genres;
  final String? runtime; // "2h 32m"
  final int? runtimeMinutes;
  final String year;
  final String? director;
  final List<CastMember> cast;
  final List<StreamingProvider> providers;
  final String? trailerKey; // YouTube video ID

  const TmdbMovieDetail({
    required this.overview,
    required this.genres,
    this.runtime,
    this.runtimeMinutes,
    required this.year,
    this.director,
    required this.cast,
    required this.providers,
    this.trailerKey,
  });

  factory TmdbMovieDetail.fromJson(
    Map<String, dynamic> detail,
    Map<String, dynamic> providersJson,
  ) {
    final genres = (detail['genres'] as List? ?? [])
        .cast<Map>()
        .map((g) => g['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .take(3)
        .toList();

    final runtimeMins = detail['runtime'] as int?;
    String? runtimeStr;
    if (runtimeMins != null && runtimeMins > 0) {
      final h = runtimeMins ~/ 60;
      final m = runtimeMins % 60;
      runtimeStr = h > 0 ? (m > 0 ? '${h}h ${m}m' : '${h}h') : '${m}m';
    }

    final releaseDate = detail['release_date'] as String? ?? '';
    final year = releaseDate.isNotEmpty ? releaseDate.split('-').first : '';

    final crew = (detail['credits']?['crew'] as List? ?? []).cast<Map>();
    final directors = crew
        .where((c) => c['job'] == 'Director')
        .map((c) => c['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');

    final cast = (detail['credits']?['cast'] as List? ?? [])
        .cast<Map>()
        .take(10)
        .map((c) {
          final profilePath = c['profile_path'] as String?;
          return CastMember(
            name: c['name'] as String? ?? '',
            character: c['character'] as String? ?? '',
            profileUrl: profilePath != null
                ? 'https://image.tmdb.org/t/p/w200$profilePath'
                : null,
          );
        })
        .where((m) => m.name.isNotEmpty)
        .toList();

    return TmdbMovieDetail(
      overview: detail['overview'] as String? ?? '',
      genres: genres,
      runtime: runtimeStr,
      runtimeMinutes: (runtimeMins != null && runtimeMins > 0) ? runtimeMins : null,
      year: year,
      director: directors.isNotEmpty ? directors : null,
      cast: cast,
      providers: _parseProviders(providersJson),
      trailerKey: _parseTrailerKey(detail),
    );
  }
}

// ─── TV / Anime detail ────────────────────────────────────────────────────────

class TmdbTvDetail {
  final String overview;
  final List<String> genres;
  final String yearRange; // "2022 – Present"
  final String? creator;
  final List<CastMember> cast;
  final List<StreamingProvider> providers;
  final List<SeriesSeason> seasons;
  final String? trailerKey; // YouTube video ID

  const TmdbTvDetail({
    required this.overview,
    required this.genres,
    required this.yearRange,
    this.creator,
    required this.cast,
    required this.providers,
    required this.seasons,
    this.trailerKey,
  });

  TmdbTvDetail copyWithSeasonEpisodes(SeriesSeason updated) {
    return TmdbTvDetail(
      overview: overview,
      genres: genres,
      yearRange: yearRange,
      creator: creator,
      cast: cast,
      providers: providers,
      seasons:
          seasons.map((s) => s.number == updated.number ? updated : s).toList(),
      trailerKey: trailerKey,
    );
  }

  factory TmdbTvDetail.fromJson(
    Map<String, dynamic> detail,
    Map<String, dynamic> providersJson,
  ) {
    final genres = (detail['genres'] as List? ?? [])
        .cast<Map>()
        .map((g) => g['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .take(3)
        .toList();

    final firstAir =
        (detail['first_air_date'] as String? ?? '').split('-').first;
    final lastAirDate = detail['last_air_date'] as String? ?? '';
    final lastYear = lastAirDate.isNotEmpty ? lastAirDate.split('-').first : '';
    final status = detail['status'] as String? ?? '';
    final isOngoing = status == 'Returning Series' || status == 'In Production';
    final yearRange = firstAir.isNotEmpty
        ? (isOngoing
            ? '$firstAir – Present'
            : lastYear.isNotEmpty && lastYear != firstAir
                ? '$firstAir – $lastYear'
                : firstAir)
        : '';

    final creators = (detail['created_by'] as List? ?? [])
        .cast<Map>()
        .map((c) => c['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');

    final cast = (detail['credits']?['cast'] as List? ?? [])
        .cast<Map>()
        .take(10)
        .map((c) {
          final profilePath = c['profile_path'] as String?;
          return CastMember(
            name: c['name'] as String? ?? '',
            character: c['character'] as String? ?? '',
            profileUrl: profilePath != null
                ? 'https://image.tmdb.org/t/p/w200$profilePath'
                : null,
          );
        })
        .where((m) => m.name.isNotEmpty)
        .toList();

    final rawSeasons = (detail['seasons'] as List? ?? [])
        .cast<Map>()
        .where((s) => (s['season_number'] as int? ?? 0) > 0)
        .toList();

    final seasons = rawSeasons.map((s) {
      final seasonNum = s['season_number'] as int;
      final airYear = (s['air_date'] as String? ?? '').split('-').first;
      final episodeCount = (s['episode_count'] as int? ?? 0).clamp(0, 200);
      return SeriesSeason(
        number: seasonNum,
        year: airYear,
        rating: '—',
        episodes: List.generate(
          episodeCount,
          (i) => SeriesEpisode(
              number: i + 1, title: 'Episode ${i + 1}', runtime: '—'),
        ),
        seasonId: s['id'] as int?,
      );
    }).toList();

    return TmdbTvDetail(
      overview: detail['overview'] as String? ?? '',
      genres: genres,
      yearRange: yearRange,
      creator: creators.isNotEmpty ? creators : null,
      cast: cast,
      providers: _parseProviders(providersJson),
      seasons: seasons,
      trailerKey: _parseTrailerKey(detail),
    );
  }

  factory TmdbTvDetail.fromJikanJson(
    Map<String, dynamic> detailJson,
    Map<String, dynamic> charactersJson,
    List<Map<String, dynamic>> allEpisodes,
    List<Map<String, dynamic>> prequelJsons,
    List<Map<String, dynamic>> sequelJsons,
  ) {
    final d = detailJson['data'] as Map<String, dynamic>? ?? {};

    final genres = (d['genres'] as List? ?? [])
        .cast<Map>()
        .map((g) => g['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .take(3)
        .toList();

    final year = d['year'] as int?;
    final status = d['status'] as String? ?? '';
    final isOngoing = status == 'Currently Airing';
    final yearRange =
        year != null ? (isOngoing ? '$year – Present' : '$year') : '';

    final studios = (d['studios'] as List? ?? [])
        .cast<Map>()
        .map((s) => s['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');

    final charList =
        (charactersJson['data'] as List? ?? []).cast<Map>().take(10);
    final cast = charList
        .map((c) {
          final char = c['character'] as Map? ?? {};
          final images = char['images'] as Map? ?? {};
          final jpg = images['jpg'] as Map? ?? {};
          return CastMember(
            name: char['name'] as String? ?? '',
            character: c['role'] as String? ?? '',
            profileUrl: jpg['image_url'] as String?,
          );
        })
        .where((m) => m.name.isNotEmpty)
        .toList();

    // Build current season episodes from pre-paginated list
    final episodeCount = d['episodes'] as int? ?? 0;
    final seriesEpisodes = allEpisodes.isNotEmpty
        ? allEpisodes
            .map((e) => SeriesEpisode(
                  number: e['mal_id'] as int? ?? 0,
                  title: e['title'] as String? ?? 'Episode ${e['mal_id']}',
                  runtime: '24m',
                ))
            .where((e) => e.number > 0)
            .toList()
        : List.generate(
            episodeCount > 0 ? episodeCount.clamp(1, 25) : 12,
            (i) => SeriesEpisode(
                number: i + 1, title: 'Episode ${i + 1}', runtime: '24m'),
          );

    // Helper: build a placeholder season from a related anime detail response
    SeriesSeason buildRelatedSeason(Map<String, dynamic> relJson, int seasonNum) {
      final data = relJson['data'] as Map<String, dynamic>? ?? {};
      final relYear = data['year'] as int?;
      final epCount = (data['episodes'] as int? ?? 0).clamp(1, 500);
      final score = (data['score'] as num?)?.toStringAsFixed(1) ?? '—';
      return SeriesSeason(
        number: seasonNum,
        year: relYear?.toString() ?? '',
        rating: score,
        episodes: List.generate(
          epCount,
          (i) => SeriesEpisode(number: i + 1, title: 'Episode ${i + 1}', runtime: '24m'),
        ),
      );
    }

    int yearOf(Map<String, dynamic> relJson) =>
        ((relJson['data'] as Map?)?['year'] as int?) ?? 9999;

    // Sort prequels oldest→newest so Season 1 is the original
    final sortedPrequels = List<Map<String, dynamic>>.from(prequelJsons)
        .where((j) => (j['data'] as Map?) != null)
        .toList()
      ..sort((a, b) => yearOf(a).compareTo(yearOf(b)));

    // Sort sequels oldest→newest
    final sortedSequels = List<Map<String, dynamic>>.from(sequelJsons)
        .where((j) => (j['data'] as Map?) != null)
        .toList()
      ..sort((a, b) => yearOf(a).compareTo(yearOf(b)));

    final currentSeasonNum = sortedPrequels.length + 1;

    final seasons = <SeriesSeason>[
      for (var i = 0; i < sortedPrequels.length; i++)
        buildRelatedSeason(sortedPrequels[i], i + 1),
      SeriesSeason(
        number: currentSeasonNum,
        year: yearRange,
        rating: (d['score'] as num?)?.toStringAsFixed(1) ?? '—',
        episodes: seriesEpisodes,
      ),
      for (var i = 0; i < sortedSequels.length; i++)
        buildRelatedSeason(sortedSequels[i], currentSeasonNum + i + 1),
    ];

    final jikanTrailerId = (d['trailer'] as Map?)?['youtube_id'] as String?;

    return TmdbTvDetail(
      overview: d['synopsis'] as String? ?? '',
      genres: genres,
      yearRange: yearRange,
      creator: studios.isNotEmpty ? studios : null,
      cast: cast,
      providers: const [],
      seasons: seasons,
      trailerKey: jikanTrailerId,
    );
  }

  // ─── AniList (single GraphQL request replaces 4 Jikan calls) ─────────────────

  factory TmdbTvDetail.fromAniListJson(Map<String, dynamic> json) {
    final media = ((json['data'] as Map?)?['Media'] as Map<String, dynamic>?) ?? {};

    final genres = (media['genres'] as List? ?? [])
        .cast<String>()
        .take(3)
        .toList();

    final startYear = (media['startDate'] as Map?)?['year'] as int?;
    final endYear = (media['endDate'] as Map?)?['year'] as int?;
    final status = media['status'] as String? ?? '';
    final isOngoing = status == 'RELEASING' || status == 'NOT_YET_RELEASED';
    final yearRange = startYear != null
        ? (isOngoing
            ? '$startYear – Present'
            : endYear != null && endYear != startYear
                ? '$startYear – $endYear'
                : '$startYear')
        : '';

    final studios = ((media['studios'] as Map?)?['nodes'] as List? ?? [])
        .cast<Map>()
        .map((s) => s['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');

    final cast = ((media['characters'] as Map?)?['edges'] as List? ?? [])
        .cast<Map>()
        .map((e) {
          final node = e['node'] as Map? ?? {};
          final nameMap = node['name'] as Map? ?? {};
          final imageMap = node['image'] as Map? ?? {};
          return CastMember(
            name: nameMap['full'] as String? ?? '',
            character: (e['role'] as String? ?? 'MAIN').toLowerCase() == 'main'
                ? 'Main'
                : 'Supporting',
            profileUrl: imageMap['medium'] as String?,
          );
        })
        .where((m) => m.name.isNotEmpty)
        .toList();

    // AniList averageScore is 0–100; convert to 0–10 for display
    String scoreDisplay(int? score) =>
        score != null && score > 0 ? (score / 10.0).toStringAsFixed(1) : '—';

    SeriesSeason buildRelatedSeason(Map<String, dynamic> node, int seasonNum) {
      final relYear = (node['startDate'] as Map?)?['year'] as int?;
      final epCount = (node['episodes'] as int? ?? 12).clamp(1, 500);
      final malId = node['idMal'] as int?;
      return SeriesSeason(
        number: seasonNum,
        year: relYear?.toString() ?? '',
        rating: scoreDisplay(node['averageScore'] as int?),
        episodes: List.generate(
          epCount,
          (i) => SeriesEpisode(number: i + 1, title: 'Episode ${i + 1}', runtime: '24m'),
        ),
        malId: malId,
      );
    }

    // Parse PREQUEL and SEQUEL relations (ANIME type only), sorted by year
    final edges = ((media['relations'] as Map?)?['edges'] as List? ?? []).cast<Map>();

    int startYearOf(Map node) =>
        (node['startDate'] as Map?)?['year'] as int? ?? 9999;

    final prequels = edges
        .where((e) =>
            e['relationType'] == 'PREQUEL' &&
            (e['node'] as Map?)?['type'] == 'ANIME')
        .map((e) => e['node'] as Map<String, dynamic>)
        .toList()
      ..sort((a, b) => startYearOf(a).compareTo(startYearOf(b)));

    final sequels = edges
        .where((e) =>
            e['relationType'] == 'SEQUEL' &&
            (e['node'] as Map?)?['type'] == 'ANIME')
        .map((e) => e['node'] as Map<String, dynamic>)
        .toList()
      ..sort((a, b) => startYearOf(a).compareTo(startYearOf(b)));

    final currentSeasonNum = prequels.length + 1;
    final currentEpCount = (media['episodes'] as int? ?? 12).clamp(1, 500);
    final currentMalId = media['idMal'] as int?;

    final seasons = <SeriesSeason>[
      for (var i = 0; i < prequels.length; i++)
        buildRelatedSeason(prequels[i], i + 1),
      SeriesSeason(
        number: currentSeasonNum,
        year: yearRange,
        rating: scoreDisplay(media['averageScore'] as int?),
        episodes: List.generate(
          currentEpCount,
          (i) => SeriesEpisode(number: i + 1, title: 'Episode ${i + 1}', runtime: '24m'),
        ),
        malId: currentMalId,
      ),
      for (var i = 0; i < sequels.length; i++)
        buildRelatedSeason(sequels[i], currentSeasonNum + i + 1),
    ];

    // Trailer — only YouTube
    final trailerMap = media['trailer'] as Map?;
    final trailerSite = (trailerMap?['site'] as String? ?? '').toLowerCase();
    final trailerKey = trailerSite == 'youtube' ? (trailerMap?['id'] as String?) : null;

    // Strip any residual HTML tags from description
    final rawDescription = media['description'] as String? ?? '';
    final description = rawDescription.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    return TmdbTvDetail(
      overview: description,
      genres: genres,
      yearRange: yearRange,
      creator: studios.isNotEmpty ? studios : null,
      cast: cast,
      providers: const [],
      seasons: seasons,
      trailerKey: trailerKey,
    );
  }
}

// ─── Trailer key helper ───────────────────────────────────────────────────────

String? _parseTrailerKey(Map<String, dynamic> detail) {
  final videos = (detail['videos']?['results'] as List? ?? []).cast<Map>();
  // Prefer official trailers, then any trailer, then any YouTube video
  for (final v in videos) {
    if (v['site'] == 'YouTube' &&
        v['type'] == 'Trailer' &&
        v['official'] == true) {
      return v['key'] as String?;
    }
  }
  for (final v in videos) {
    if (v['site'] == 'YouTube' && v['type'] == 'Trailer') {
      return v['key'] as String?;
    }
  }
  for (final v in videos) {
    if (v['site'] == 'YouTube') return v['key'] as String?;
  }
  return null;
}

// ─── Provider parsing helper ──────────────────────────────────────────────────

List<StreamingProvider> _parseProviders(Map<String, dynamic> json) {
  final results = json['results'] as Map<String, dynamic>? ?? {};
  final region = (results['IN'] ?? results['US'] ?? <String, dynamic>{})
      as Map<String, dynamic>;

  final providers = <StreamingProvider>[];
  final seen = <String>{};

  void addFromList(dynamic list, String type) {
    for (final p in (list as List? ?? [])) {
      final m = p as Map<String, dynamic>;
      final name = m['provider_name'] as String? ?? '';
      final logoPath = m['logo_path'] as String?;
      if (name.isNotEmpty && !seen.contains(name)) {
        seen.add(name);
        providers.add(StreamingProvider(
          name: name,
          type: type,
          assetPath: AppImages.forProvider(name),
          logoUrl: logoPath != null
              ? 'https://image.tmdb.org/t/p/original$logoPath'
              : null,
        ));
      }
    }
  }

  addFromList(region['flatrate'], 'Subscription');
  addFromList(region['rent'], 'Rent');
  addFromList(region['buy'], 'Buy');

  return providers.take(6).toList();
}
