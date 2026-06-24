import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/home/widgets/home_bottom_nav_bar.dart';

class CinemoraHomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CinemoraHomeShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: context.colors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: navigationShell,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              WSizes.screenPadding.w,
              0,
              WSizes.screenPadding.w,
              10.h,
            ),
            child: HomeBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onChanged: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
