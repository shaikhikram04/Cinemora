import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/themes/theme.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';

class WatcharyApp extends StatefulWidget {
  final AppAuthCubit authCubit;
  final UserRepository userRepository;

  const WatcharyApp({
    super.key,
    required this.authCubit,
    required this.userRepository,
  });

  @override
  State<WatcharyApp> createState() => _WatcharyAppState();
}

class _WatcharyAppState extends State<WatcharyApp> {
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
        RepositoryProvider.value(value: widget.userRepository),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => MaterialApp.router(
          title: 'Watchary',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          theme: WTheme.lightTheme,
          darkTheme: WTheme.darkTheme,
          routerConfig: _router,
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
