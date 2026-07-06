abstract class AppRoutes {
  // ── Splash ────────────────────────────────────────────────────────────────
  static const splash = '/splash';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const welcome = '/';
  static const login = '/login';

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const onboarding = '/onboarding';
  static const onboardingSuccess = '/onboarding/success';

  // ── Shell tabs ────────────────────────────────────────────────────────────
  static const home = '/home';
  static const discover = '/discover';
  static const library = '/library';
  static const rankings = '/rankings';
  static const profile = '/profile';

  // ── Detail screens (full-screen, no bottom nav) ───────────────────────────
  static const movieDetails = '/movie';
  static const seriesDetails = '/series';

  // ── Franchises ─────────────────────────────────────────────────────────────
  static const franchiseList = '/franchise';
  static const franchiseDetail = '/franchise/detail';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const notifications = '/notifications';

  // ── Watch Together ────────────────────────────────────────────────────────
  static const watchTogether = '/watch-together';
  static const watchTogetherCreate = '/watch-together/create';
  static const watchTogetherJoin = '/watch-together/join';

  // ── Settings ──────────────────────────────────────────────────────────────
  static const settings = '/settings';
  static const editProfile = '/settings/edit-profile';
  static const appearance = '/settings/appearance';
  static const notificationSettings = '/settings/notification-settings';
  static const privacySecurity = '/settings/privacy-security';
  static const helpSupport = '/settings/help-support';
  static const about = '/settings/about';
  static const dataLibrary = '/settings/data-library';
}
