import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:watchary/core/router/app_routes.dart';
import 'package:watchary/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:watchary/features/authentication/viewmodels/app_auth_state.dart';
import 'package:watchary/features/authentication/views/welcome_view.dart';
import 'package:watchary/features/splash/views/animated_loading_screen.dart';
import 'package:watchary/features/discover/views/discover_view.dart';
import 'package:watchary/features/home/screens/home.dart';
import 'package:watchary/features/home/views/home_feed_view.dart';
import 'package:watchary/features/home/views/movie_details_view.dart';
import 'package:watchary/features/home/views/series_details_view.dart';
import 'package:watchary/features/library/views/library_view.dart';
import 'package:watchary/features/notifications/views/notifications_view.dart';
import 'package:watchary/features/onboarding/views/onboarding_success_view.dart';
import 'package:watchary/features/onboarding/views/taste_setup_view.dart';
import 'package:watchary/features/profile/views/profile_view.dart';
import 'package:watchary/features/rankings/views/rankings_view.dart';
import 'package:watchary/features/settings/views/about_view.dart';
import 'package:watchary/features/settings/views/appearance_view.dart';
import 'package:watchary/features/settings/views/data_library_view.dart';
import 'package:watchary/features/settings/views/edit_profile_view.dart';
import 'package:watchary/features/settings/views/help_support_view.dart';
import 'package:watchary/features/settings/views/notification_settings_view.dart';
import 'package:watchary/features/settings/views/privacy_security_view.dart';
import 'package:watchary/features/settings/views/settings_view.dart';
import 'package:watchary/features/watch_together/views/create_session_view.dart';
import 'package:watchary/features/watch_together/views/join_session_view.dart';
import 'package:watchary/features/watch_together/views/watch_together_intro_view.dart';

class MovieRouteArgs {
  final String title;
  final String image;
  final String rating;
  const MovieRouteArgs(
      {required this.title, required this.image, required this.rating});
}

class SeriesRouteArgs {
  final String title;
  final String image;
  final String rating;
  const SeriesRouteArgs(
      {required this.title, required this.image, required this.rating});
}

GoRouter buildAppRouter(AppAuthCubit authCubit, [ChangeNotifier? notifier]) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.matchedLocation;

      if (authState is AppAuthInitial || authState is AppAuthLoading) {
        if (location != AppRoutes.splash) return AppRoutes.splash;
        return null;
      }

      if (authState is AppAuthUnauthenticated || authState is AppAuthError) {
        if (location != AppRoutes.welcome) return AppRoutes.welcome;
        return null;
      }

      if (authState is AppAuthAuthenticated) {
        final isOnboarded = authState.user.isOnboarded;

        // Always allow the success screen — it's the reward after finishing onboarding
        if (location == AppRoutes.onboardingSuccess) return null;

        if (!isOnboarded) {
          if (location != AppRoutes.onboarding) return AppRoutes.onboarding;
          return null;
        }

        // Fully authenticated + onboarded — bounce away from auth/onboarding/splash routes
        if (location == AppRoutes.welcome ||
            location == AppRoutes.onboarding ||
            location == AppRoutes.splash) {
          return AppRoutes.home;
        }
        return null;
      }

      return null;
    },
    routes: [
      // ── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const AnimatedLoadingScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeView(),
      ),

      // ── Onboarding ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const TasteSetupView(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSuccess,
        builder: (context, state) => const OnboardingSuccessView(),
      ),

      // ── Shell (bottom nav) ────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            WatcharyHomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeFeedView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.library,
                builder: (context, state) => const LibraryView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.rankings,
                builder: (context, state) => const RankingsView()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileView()),
          ]),
        ],
      ),

      // ── Detail screens ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.movieDetails,
        builder: (context, state) {
          final args = state.extra! as MovieRouteArgs;
          return MovieDetailsView(
              movieTitle: args.title,
              movieImage: args.image,
              rating: args.rating);
        },
      ),
      GoRoute(
        path: AppRoutes.seriesDetails,
        builder: (context, state) {
          final args = state.extra! as SeriesRouteArgs;
          return SeriesDetailsView(
              seriesTitle: args.title,
              seriesImage: args.image,
              rating: args.rating);
        },
      ),

      // ── Notifications ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsView(),
      ),

      // ── Watch Together ────────────────────────────────────────────────────
      GoRoute(
          path: AppRoutes.watchTogether,
          builder: (context, state) => const WatchTogetherIntroView()),
      GoRoute(
          path: AppRoutes.watchTogetherCreate,
          builder: (context, state) => const CreateSessionView()),
      GoRoute(
          path: AppRoutes.watchTogetherJoin,
          builder: (context, state) => const JoinSessionView()),

      // ── Settings ──────────────────────────────────────────────────────────
      GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsView()),
      GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => const EditProfileView()),
      GoRoute(
          path: AppRoutes.appearance,
          builder: (context, state) => const AppearanceView()),
      GoRoute(
          path: AppRoutes.notificationSettings,
          builder: (context, state) => const NotificationSettingsView()),
      GoRoute(
          path: AppRoutes.privacySecurity,
          builder: (context, state) => const PrivacySecurityView()),
      GoRoute(
          path: AppRoutes.helpSupport,
          builder: (context, state) => const HelpSupportView()),
      GoRoute(
          path: AppRoutes.about,
          builder: (context, state) => const AboutView()),
      GoRoute(
          path: AppRoutes.dataLibrary,
          builder: (context, state) => const DataLibraryView()),
    ],
  );
}
