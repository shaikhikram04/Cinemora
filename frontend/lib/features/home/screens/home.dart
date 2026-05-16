import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/features/discover/screens/discover_screen.dart';
import 'package:watchary/features/home/widgets/home_bottom_nav_bar.dart';
import 'package:watchary/features/home/widgets/home_feed_page.dart';
import 'package:watchary/features/library/screens/library_screen.dart';

class WatcharyHomeShell extends StatefulWidget {
  const WatcharyHomeShell({super.key});

  @override
  State<WatcharyHomeShell> createState() => _WatcharyHomeShellState();
}

class _WatcharyHomeShellState extends State<WatcharyHomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeFeedPage(),
      const DiscoverScreen(),
      const LibraryScreen(),
      const _EmptyTabPage(),
      const _EmptyTabPage(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: WColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: WColors.background,
        body: IndexedStack(index: _index, children: pages),
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
              currentIndex: _index,
              onChanged: (value) => setState(() => _index = value),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTabPage extends StatelessWidget {
  const _EmptyTabPage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: ColoredBox(color: WColors.background),
    );
  }
}
