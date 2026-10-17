class ApiConstants {
  // TODO(deploy): point this at the production HTTPS origin before shipping.
  // A release build with a localhost URL resolves to the *phone's* loopback and
  // can never reach the server. Prefer wiring it through the build rather than
  // editing this line per-environment:
  //
  //   static const String baseUrl =
  //       String.fromEnvironment('API_BASE_URL', defaultValue: _devBaseUrl);
  //   flutter build appbundle --dart-define=API_BASE_URL=https://api.example.com/api
  //
  // Two other things move with it, both currently set for cleartext LAN dev:
  //   - android:usesCleartextTraffic + res/xml/network_security_config.xml
  //     (already removed — an http:// URL will now be blocked on Android)
  //   - iOS ATS, if the production origin is ever not HTTPS
  //
  // Physical device on the same Wi-Fi → use the laptop's LAN IP + port.
  // Android emulator → use http://10.0.2.2:3000/api
  // Desktop/web on the laptop itself → use http://localhost:3000/api
  static const String baseUrl = 'https://49nvjn19-3000.inc1.devtunnels.ms/api';
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p';

  // ─── Paths, relative to [baseUrl] ───────────────────────────────────────────
  //
  // Every request in the app resolves its path here, so the backend's surface is
  // readable in one place and a route rename is one edit rather than a grep.
  // Paths that take an id are functions; the rest are constants.

  //* Health
  static const String health = '/health';

  //* Auth
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authFirebase = '/auth/firebase';

  //* User
  static const String userProfile = '/users/profile';
  static const String userPreferences = '/users/preferences';
  static const String userAvatar = '/users/avatar';
  static const String userCover = '/users/cover';
  static const String userFcmToken = '/users/fcm-token';
  static const String userNotificationPrefs = '/users/notification-prefs';

  //* Library
  static const String library = '/library';
  static const String libraryStats = '/library/stats';
  static const String libraryUpsert = '/library/upsert';
  static String libraryEntry(int tmdbId) => '/library/$tmdbId';
  static String librarySeason(int tmdbId, int seasonNumber) =>
      '/library/$tmdbId/seasons/$seasonNumber';

  //* TMDB proxy
  static const String tmdbTrending = '/tmdb/trending';
  static const String tmdbDiscover = '/tmdb/discover';
  static const String tmdbSearch = '/tmdb/search';
  static String tmdbMovie(int id) => '/tmdb/movie/$id';
  static String tmdbMovieProviders(int id) => '/tmdb/movie/$id/watch-providers';
  static String tmdbTv(int id) => '/tmdb/tv/$id';
  static String tmdbTvProviders(int id) => '/tmdb/tv/$id/watch-providers';
  static String tmdbTvSeason(int tvId, int seasonNumber) =>
      '/tmdb/tv/$tvId/season/$seasonNumber';
  static const String tmdbCollectionsFeatured = '/tmdb/collection/featured';
  static const String tmdbCollectionSearch = '/tmdb/collection/search';
  static String tmdbCollection(int id) => '/tmdb/collection/$id';

  //* Anime sources
  static const String jikanTop = '/jikan/top';
  static String jikanAnimeEpisodes(int malId) => '/jikan/anime/$malId/episodes';
  static const String anilistSearch = '/anilist/search';
  static String anilistAnime(int id) => '/anilist/anime/$id';

  //* Recommender
  static const String recommendationsHome = '/recommendations/home';
  static const String recommendationsMoodMessage =
      '/recommendations/mood/message';
  static String recommendationsSimilar(String cinemaType, int sourceId) =>
      '/recommendations/similar/$cinemaType/$sourceId';

  //* Rankings
  static const String rankings = '/rankings';
  static String rankingList(String listId) => '/rankings/$listId';
  static String rankingEntries(String listId) => '/rankings/$listId/entries';

  //* Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';
}
