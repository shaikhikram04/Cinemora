import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/themes/theme.dart';
import 'package:watchary/features/authentication/screens/welcome.dart';

class WatcharyApp extends StatelessWidget {
  const WatcharyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Watchary',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          theme: WTheme.lightTheme,
          darkTheme: WTheme.darkTheme,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
