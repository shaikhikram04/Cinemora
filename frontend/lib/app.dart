import 'dart:async';
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
import 'package:cinemora/core/viewmodels/theme_mode_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_state.dart';
import 'package:cinemora/features/discover/repositories/discover_repository.dart';
import 'package:cinemora/features/franchise/repositories/franchise_repository.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/notifications/repositories/notifications_repository.dart';
import 'package:cinemora/features/notifications/viewmodels/notifications_cubit.dart';
import 'package:cinemora/features/rankings/repositories/rankings_repository.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_cubit.dart';

class CinemoraApp extends StatefulWidget {
  final AppAuthCubit authCubit;
  final UserRepository userRepository;
  final HomeRepository homeRepository;
  final LibraryRepository libraryRepository;
  final DiscoverRepository discoverRepository;
  final FranchiseRepository franchiseRepository;
  final RankingsRepository rankingsRepository;
  final NotificationsRepository notificationsRepository;
  final ThemeModeCubit themeModeCubit;
  final SharedPreferences prefs;

  const CinemoraApp({
    super.key,
    required this.authCubit,
    required this.userRepository,
    required this.homeRepository,
    required this.libraryRepository,
    required this.discoverRepository,
    required this.franchiseRepository,
    required this.rankingsRepository,
    required this.notificationsRepository,
    required this.themeModeCubit,
    required this.prefs,
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
  late final PushNotificationsService _pushService;
  late final StreamSubscription<AppAuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _libraryCubit = LibraryCubit(widget.libraryRepository);
    _rankingsCubit = RankingsCubit(widget.rankingsRepository);
    _notificationsCubit = NotificationsCubit(widget.notificationsRepository);
    _pushService = PushNotificationsService(widget.userRepository);
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
        // just refreshes the badge, and tapping one opens the inbox.
        _pushService.start(
          onForegroundMessage: _notificationsCubit.refreshUnreadCount,
          onNotificationTap: () => _router.push(AppRoutes.notifications),
        );
      } else if (state is AppAuthUnauthenticated) {
        _rankingsCubit.clear();
        _notificationsCubit.clear();
      }
    });

    widget.authCubit.checkAuthStatus();
  }

  @override
  void dispose() {
    _authSub.cancel();
    _notifier.dispose();
    _libraryCubit.close();
    _rankingsCubit.close();
    _notificationsCubit.close();
    _pushService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authCubit),
        BlocProvider.value(value: widget.themeModeCubit),
        BlocProvider.value(value: _libraryCubit),
        BlocProvider.value(value: _rankingsCubit),
        BlocProvider.value(value: _notificationsCubit),
        RepositoryProvider.value(value: widget.userRepository),
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
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: WTheme.lightTheme,
            darkTheme: WTheme.darkTheme,
            routerConfig: _router,
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
