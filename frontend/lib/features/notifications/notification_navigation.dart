import 'package:go_router/go_router.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/notifications/models/notification.dart';

/// Opens the title a notification points at.
///
/// Shared by the inbox and by push taps so the two can't drift — the backend
/// puts the same fields in the FCM payload that the inbox row already has.
/// Returns false when the notification points at nothing openable, leaving the
/// caller to decide on a fallback.
///
/// These are the same route args the library rows use; the detail screen
/// fetches the real data by id — for anime sequels that id is the *new*
/// season's MAL id.
bool openNotificationTarget(GoRouter router, AppNotification notif) {
  final id = notif.tmdbId;
  if (!notif.canOpen || id == null) return false;

  final image = notif.posterUrlLarge ?? '';

  if (notif.cinemaType == 'movie') {
    router.push(
      AppRoutes.movieDetails,
      extra: MovieRouteArgs(
        title: notif.title,
        image: image,
        rating: '—',
        id: id,
      ),
    );
  } else {
    router.push(
      AppRoutes.seriesDetails,
      extra: SeriesRouteArgs(
        title: notif.title,
        image: image,
        rating: '—',
        id: id,
        source: notif.cinemaType == 'anime' ? 'jikan' : 'tmdb',
        focusSeason: notif.season,
      ),
    );
  }
  return true;
}
