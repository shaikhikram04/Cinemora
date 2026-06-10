import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:watchary/core/constants/colors.dart';

class AnimatedLoadingScreen extends StatefulWidget {
  const AnimatedLoadingScreen({super.key});

  @override
  State<AnimatedLoadingScreen> createState() => _AnimatedLoadingScreenState();
}

class _AnimatedLoadingScreenState extends State<AnimatedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: WColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: WColors.background,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Lottie animation ─────────────────────────────────────
                // Replace 'assets/animations/loading.json' with your file
                SizedBox(
                  width: 180.w,
                  height: 180.w,
                  child: Lottie.asset(
                    'assets/animations/loading.json',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _FallbackSpinner(),
                  ),
                ),
                SizedBox(height: 24.h),

                // ── App name ─────────────────────────────────────────────
                Text(
                  'Watchary',
                  style: TextStyle(
                    color: WColors.foreground,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your cinema companion',
                  style: TextStyle(
                    color: WColors.mutedForeground,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Shown only if the Lottie asset isn't added yet
class _FallbackSpinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 48.w,
        height: 48.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: WColors.primary,
        ),
      ),
    );
  }
}
