import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_state.dart';
import 'package:cinemora/features/authentication/views/login_view.dart';
import 'package:cinemora/features/authentication/views/welcome_view.dart';
import 'package:cinemora/features/splash/views/splash_screen.dart';
import 'package:cinemora/features/discover/views/discover_view.dart';
import 'package:cinemora/features/franchise/views/franchise_detail_view.dart';
import 'package:cinemora/features/franchise/views/franchise_list_view.dart';
import 'package:cinemora/features/home/screens/home.dart';
import 'package:cinemora/features/home/views/home_feed_view.dart';
import 'package:cinemora/features/home/views/movie_details_view.dart';
import 'package:cinemora/features/home/views/series_details_view.dart';
import 'package:cinemora/features/library/views/library_view.dart';
import 'package:cinemora/features/notifications/views/notifications_view.dart';
import 'package:cinemora/features/onboarding/views/onboarding_success_view.dart';
import 'package:cinemora/features/onboarding/views/taste_setup_view.dart';
import 'package:cinemora/features/profile/views/profile_view.dart';
import 'package:cinemora/features/rankings/views/rankings_view.dart';
import 'package:cinemora/features/settings/views/about_view.dart';
import 'package:cinemora/features/settings/views/appearance_view.dart';
import 'package:cinemora/features/settings/views/data_library_view.dart';
import 'package:cinemora/features/settings/views/edit_profile_view.dart';
import 'package:cinemora/features/settings/views/help_support_view.dart';
import 'package:cinemora/features/settings/views/notification_settings_view.dart';
import 'package:cinemora/features/settings/views/privacy_security_view.dart';
import 'package:cinemora/features/settings/views/settings_view.dart';
import 'package:cinemora/features/watch_together/views/create_session_view.dart';
import 'package:cinemora/features/watch_together/views/join_session_view.dart';
import 'package:cinemora/features/watch_together/views/watch_together_intro_view.dart';

class MovieRouteArgs {
  final String title;
  final String image;
  final String? backdropImage;
  final String rating;
  final int? id;
  const MovieRouteArgs({
    required this.title,
    required this.image,
    this.backdropImage,
    required this.rating,
    this.id,
  });
}

class SeriesRouteArgs {
  final String title;
  final String image;
  final String? backdropImage;
  final String rating;
  final int? id;
  final String source; // "tmdb" | "jikan"
  final int? focusSeason; // auto-select this season tab on open
  const SeriesRouteArgs({
    required this.title,
    required this.image,
    this.backdropImage,
    required this.rating,
    this.id,
    this.source = 'tmdb',
    this.focusSeason,
  });
}

class FranchiseRouteArgs {
  final int collectionId;
  final String? name;
  final String? backdropUrl;
  const FranchiseRouteArgs({
    required this.collectionId,
    this.name,
    this.backdropUrl,
  });
}

GoRouter buildAppRouter(AppAuthCubit authCubit, [ChangeNotifier? notifier]) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = authCubit.state;
      final location = state.matchedLocation;

      if (authState is AppAuthInitial) {
        if (location != AppRoutes.splash) return AppRoutes.splash;
        return null;
      }

      if (authState is AppAuthLoading) return null;

      if (authState is AppAuthUnauthenticated || authState is AppAuthError) {
        if (authCubit.hasSeenWelcome) {
          if (location != AppRoutes.login) return AppRoutes.login;
        } else {
          if (location != AppRoutes.welcome) return AppRoutes.welcome;
        }
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
            location == AppRoutes.login ||
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
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
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
            CinemoraHomeShell(navigationShell: navigationShell),
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
            backdropImage: args.backdropImage,
            rating: args.rating,
            tmdbId: args.id,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.seriesDetails,
        builder: (context, state) {
          final args = state.extra! as SeriesRouteArgs;
          return SeriesDetailsView(
            seriesTitle: args.title,
            seriesImage: args.image,
            backdropImage: args.backdropImage,
            rating: args.rating,
            id: args.id,
            source: args.source,
            focusSeason: args.focusSeason,
          );
        },
      ),

      // ── Franchises ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.franchiseList,
        builder: (context, state) => const FranchiseListView(),
      ),
      GoRoute(
        path: AppRoutes.franchiseDetail,
        builder: (context, state) {
          final args = state.extra! as FranchiseRouteArgs;
          return FranchiseDetailView(
            collectionId: args.collectionId,
            name: args.name,
            backdropUrl: args.backdropUrl,
          );
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
