import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/core/services/push_notifications_service.dart';
import 'package:cinemora/core/themes/theme.dart';
import 'package:cinemora/common/widgets/states/w_offline_banner.dart';
import 'package:cinemora/core/viewmodels/network_status_cubit.dart';
import 'package:cinemora/core/viewmodels/theme_mode_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_state.dart';
import 'package:cinemora/features/discover/repositories/discover_repository.dart';
import 'package:cinemora/features/franchise/repositories/franchise_repository.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/library/viewmodels/library_state.dart';
import 'package:cinemora/features/notifications/models/notification.dart';
import 'package:cinemora/features/notifications/notification_navigation.dart';
import 'package:cinemora/features/notifications/repositories/notifications_repository.dart';
import 'package:cinemora/features/notifications/viewmodels/notifications_cubit.dart';
import 'package:cinemora/features/rankings/repositories/rankings_repository.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_cubit.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_state.dart';
import 'package:cinemora/features/tour/tour_mode.dart';
import 'package:cinemora/features/tour/viewmodels/tour_cubit.dart';
import 'package:cinemora/features/tour/viewmodels/tour_state.dart';
import 'package:cinemora/features/tour/widgets/tour_overlay.dart';

/// Set the first time the app reaches an authenticated state on this device.
/// Gates the notification permission prompt away from that first run.
const _kFirstRunDoneKey = 'first_authenticated_run_done';

class CinemoraApp extends StatefulWidget {
  final AppAuthCubit authCubit;
  final NetworkStatusCubit networkStatusCubit;
  final UserRepository userRepository;
  final HomeRepository homeRepository;
  final LibraryRepository libraryRepository;
  final DiscoverRepository discoverRepository;
  final FranchiseRepository franchiseRepository;
  final RankingsRepository rankingsRepository;
  final NotificationsRepository notificationsRepository;
  final ThemeModeCubit themeModeCubit;
  final SharedPreferences prefs;

  /// Shared with both repositories at construction — see [TourMode].
  final TourMode tourMode;

  const CinemoraApp({
    super.key,
    required this.authCubit,
    required this.networkStatusCubit,
    required this.userRepository,
    required this.homeRepository,
    required this.libraryRepository,
    required this.discoverRepository,
    required this.franchiseRepository,
    required this.rankingsRepository,
    required this.notificationsRepository,
    required this.themeModeCubit,
    required this.prefs,
    required this.tourMode,
  });

  @override
  State<CinemoraApp> createState() => _CinemoraAppState();
}

class _CinemoraAppState extends State<CinemoraApp> {
  late final GoRouter _router;
  late final _RouterNotifier _notifier;
  late final LibraryCubit _libraryCubit;
  late final RankingsCubit _rankingsCubit;
  late final NotificationsCubit _notificationsCubit;
  late final TourCubit _tourCubit;
  late final PushNotificationsService _pushService;
  late final StreamSubscription<AppAuthState> _authSub;
  late final StreamSubscription<void> _reconnectSub;
  late final StreamSubscription<RankingsState> _rankingsErrorSub;
  late final StreamSubscription<LibraryState> _tourLibrarySub;
  late final StreamSubscription<TourState> _tourEndSub;
  bool _tourWasRunning = false;

  /// Rankings are mutated from the placement flow, the rankings tab and the
  /// profile tab, so a failed write has no single screen to report on. This
  /// lets the cubit surface one wherever the user happens to be.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _libraryCubit = LibraryCubit(widget.libraryRepository, widget.tourMode);
    _rankingsCubit = RankingsCubit(widget.rankingsRepository, widget.tourMode);
    _notificationsCubit = NotificationsCubit(widget.notificationsRepository);
    _tourCubit = TourCubit(widget.prefs, widget.tourMode);
    // The first-run tour's opening step clears only once the watchlist write
    // has actually landed, so it watches the library rather than the tap.
    _tourLibrarySub = _libraryCubit.stream
        .listen((state) => _tourCubit.onLibraryChanged(state.entries));

    // Everything the tour did was answered from memory rather than written to
    // the server (see TourMode), so refetching both collections is all it takes
    // to clear the demo watchlist entry and the demo ranking list — and it
    // guarantees what's on screen afterwards matches what's actually stored,
    // rather than trying to unpick the changes by hand.
    _tourEndSub = _tourCubit.stream.listen((state) {
      final wasRunning = _tourWasRunning;
      _tourWasRunning = state.step.isRunning;
      if (!wasRunning || state.step.isRunning) return;
      _libraryCubit.loadData();
      _rankingsCubit.loadLists();
    });
    _pushService = PushNotificationsService(widget.userRepository);
    // Detaches this device from the account while the session can still
    // authenticate the call — see AppAuthCubit.onBeforeSignOut.
    widget.authCubit.onBeforeSignOut = _pushService.stop;
    _notifier = _RouterNotifier(widget.authCubit);
    _router = buildAppRouter(widget.authCubit, _notifier);

    _authSub = widget.authCubit.stream.listen((state) {
      if (state is AppAuthAuthenticated) {
        _libraryCubit.loadData();
        _rankingsCubit.loadLists();
        // Lights up the home-screen bell badge; also triggers the backend's
        // release-check pass so fresh notifications exist by the time the
        // inbox is opened.
        _notificationsCubit.refreshUnreadCount();
        // Permission prompt + token sync; a push arriving in the foreground
        // just refreshes the badge, and tapping one opens the title it's about.
        //
        // The prompt is held back on the very first authenticated run. Landing
        // an OS permission dialog on someone who has been signed in for a few
        // seconds asks them to decide about notifications before they've seen
        // what the app sends — and on a new account it lands on top of the
        // first-run tour. From the next launch it prompts as normal, and the
        // notification settings screen can request it explicitly at any point.
        final isFirstRun = !(widget.prefs.getBool(_kFirstRunDoneKey) ?? false);
        widget.prefs.setBool(_kFirstRunDoneKey, true);
        _pushService.start(
          onForegroundMessage: _notificationsCubit.refreshUnreadCount,
          onNotificationTap: _openPushTarget,
          canPrompt: !isFirstRun,
        );
      } else if (state is AppAuthUnauthenticated) {
        _rankingsCubit.clear();
        _notificationsCubit.clear();
      }
    });

    _rankingsErrorSub = _rankingsCubit.stream.listen((state) {
      final error = state.mutationError;
      if (error == null) return;
      _messengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      _rankingsCubit.clearMutationError();
    });

    // App-wide recovery. The screen-scoped cubits handle themselves via
    // BlocListener; these three are long-lived and have no screen to hang a
    // listener off, so they're refreshed from here.
    _reconnectSub = widget.networkStatusCubit.onReconnect.listen((_) {
      if (widget.authCubit.state is! AppAuthAuthenticated) return;
      // A cache-restored identity may be stale — check it before anything
      // downstream reads isOnboarded or the avatar.
      widget.authCubit.revalidateIfStale();
      if (_libraryCubit.state.status == LibraryStatus.error) {
        _libraryCubit.loadData();
      }
      if (_rankingsCubit.state.lists.isEmpty) _rankingsCubit.loadLists();
      _notificationsCubit.refreshUnreadCount();
    });

    widget.authCubit.checkAuthStatus();
  }

  /// Routes a tapped push. The payload carries everything the inbox row would
  /// have, so the tap lands on the title itself; the inbox is the fallback for
  /// a notification that points at nothing openable (or a payload shape this
  /// build predates).
  void _openPushTarget(RemoteMessage message) {
    final notif = AppNotification.fromPushData(message.data);
    if (notif == null) {
      _router.push(AppRoutes.notifications);
      return;
    }

    // A tapped push is a read notification — otherwise the badge keeps
    // counting something the user has already acted on.
    if (notif.id.isNotEmpty) _notificationsCubit.markReadFromPush(notif.id);

    if (!openNotificationTarget(_router, notif)) {
      _router.push(AppRoutes.notifications);
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    _reconnectSub.cancel();
    _rankingsErrorSub.cancel();
    _tourLibrarySub.cancel();
    _tourEndSub.cancel();
    _notifier.dispose();
    _libraryCubit.close();
    _rankingsCubit.close();
    _notificationsCubit.close();
    _tourCubit.close();
    _pushService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authCubit),
        BlocProvider.value(value: widget.networkStatusCubit),
        BlocProvider.value(value: widget.themeModeCubit),
        BlocProvider.value(value: _libraryCubit),
        BlocProvider.value(value: _rankingsCubit),
        BlocProvider.value(value: _notificationsCubit),
        BlocProvider.value(value: _tourCubit),
        RepositoryProvider.value(value: widget.userRepository),
        // Notification settings reads OS permission through this, so it can
        // stop presenting toggles as live when the OS is dropping everything.
        RepositoryProvider.value(value: _pushService),
        RepositoryProvider.value(value: widget.homeRepository),
        RepositoryProvider.value(value: widget.libraryRepository),
        RepositoryProvider.value(value: widget.discoverRepository),
        RepositoryProvider.value(value: widget.franchiseRepository),
        RepositoryProvider<SharedPreferences>.value(value: widget.prefs),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp.router(
            title: 'Cinemora',
            scaffoldMessengerKey: _messengerKey,
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: WTheme.lightTheme,
            darkTheme: WTheme.darkTheme,
            routerConfig: _router,
            // Wrapped here rather than per-screen so the offline banner covers
            // every route, including ones added later. The coach-mark overlay
            // goes inside it for the same reason, and because this is the only
            // subtree containing the Navigator — the one place a single
            // overlay can sit above pushed routes *and* modal sheets, both of
            // which the first-run tour has to reach.
            builder: (context, child) => OfflineBanner.offlineBanner(
              child: TourOverlay(child: child ?? const SizedBox.shrink()),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouterNotifier extends ChangeNotifier {
  late final StreamSubscription _sub;

  _RouterNotifier(AppAuthCubit cubit) {
    _sub = cubit.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
