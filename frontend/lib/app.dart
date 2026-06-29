import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/themes/theme.dart';
import 'package:cinemora/core/viewmodels/theme_mode_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/discover/repositories/discover_repository.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';
import 'package:cinemora/features/library/repositories/library_repository.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_cubit.dart';

class CinemoraApp extends StatefulWidget {
  final AppAuthCubit authCubit;
  final UserRepository userRepository;
  final HomeRepository homeRepository;
  final LibraryRepository libraryRepository;
  final DiscoverRepository discoverRepository;
  final ThemeModeCubit themeModeCubit;
  final SharedPreferences prefs;

  const CinemoraApp({
    super.key,
    required this.authCubit,
    required this.userRepository,
    required this.homeRepository,
    required this.libraryRepository,
    required this.discoverRepository,
    required this.themeModeCubit,
    required this.prefs,
  });

  @override
  State<CinemoraApp> createState() => _CinemoraAppState();
}

class _CinemoraAppState extends State<CinemoraApp> {
  late final GoRouter _router;
  late final _RouterNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = _RouterNotifier(widget.authCubit);
    _router = buildAppRouter(widget.authCubit, _notifier);
    widget.authCubit.checkAuthStatus();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authCubit),
        BlocProvider.value(value: widget.themeModeCubit),
        BlocProvider(
          create: (_) => LibraryCubit(widget.libraryRepository)..loadData(),
        ),
        BlocProvider(
          create: (_) => RankingsCubit(),
        ),
        RepositoryProvider.value(value: widget.userRepository),
        RepositoryProvider.value(value: widget.homeRepository),
        RepositoryProvider.value(value: widget.libraryRepository),
        RepositoryProvider.value(value: widget.discoverRepository),
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
