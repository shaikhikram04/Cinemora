import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Drives the repeating wave cycle
  late final AnimationController _bounceController;

  // Scales amplitude from 0→1 so balls start flat then grow into the wave
  late final AnimationController _startupController;
  late final Animation<double> _amplitudeScale;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _startupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _amplitudeScale = CurvedAnimation(
      parent: _startupController,
      curve: Curves.easeInOut,
    );

    // Short pause so users see the static dots before the wave kicks in
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startupController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _startupController.dispose();
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
              children: [
                const Spacer(flex: 3),
                Image.asset(
                  'assets/icons/cinemora_transparent_icon.png',
                  width: 160.w,
                  height: 160.w,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Cinemora',
                  style: TextStyle(
                    color: WColors.foreground,
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your cinema companion',
                  style: TextStyle(
                    color: WColors.mutedSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 4),
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_bounceController, _startupController]),
                  builder: (context, _) => CustomPaint(
                    size: Size(160.w, 60.h),
                    painter: _WaveBubblePainter(
                      progress: _bounceController.value,
                      amplitudeScale: _amplitudeScale.value,
                    ),
                  ),
                ),
                SizedBox(height: 64.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveBubblePainter extends CustomPainter {
  final double progress;
  final double amplitudeScale;

  const _WaveBubblePainter({
    required this.progress,
    required this.amplitudeScale,
  });

  static const Color _ballColor = Color(0xFF8E8E93);

  // Each ball has its own local timeline: progress - (ballIndex × delay).
  // Within that local time it does a big arc then a small arc, then rests.
  // When localT ≤ 0 or past the active window, displacement = 0, so every
  // ball is at restY when not in its bounce window — they all land together.
  static double _displacement(
      int i, double progress, double bigAmp, double smallAmp) {
    const double perBallDelay = 0.09; // stagger between adjacent balls
    const double bigDuration = 0.20; // fraction of cycle for big arc
    const double smallDuration = 0.11; // fraction of cycle for small arc

    final double lt = progress - i * perBallDelay;
    if (lt <= 0) return 0;

    if (lt < bigDuration) {
      // Big bounce: smooth sine arch
      return bigAmp * sin(lt / bigDuration * pi);
    }

    final double afterBig = lt - bigDuration;
    if (afterBig < smallDuration) {
      // Small bounce: same arch shape, smaller amplitude
      return smallAmp * sin(afterBig / smallDuration * pi);
    }

    return 0; // resting until next cycle
  }

  @override
  void paint(Canvas canvas, Size size) {
    const int count = 5;
    final double r = size.height * 0.14;
    final double restY = size.height - r;
    final double bigAmp = size.height * 0.55 * amplitudeScale;
    final double smallAmp = size.height * 0.22 * amplitudeScale;

    final paint = Paint()
      ..color = _ballColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final double x = (size.width / (count + 1)) * (i + 1);
      final double disp = _displacement(i, progress, bigAmp, smallAmp);
      canvas.drawCircle(Offset(x, restY - disp), r, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveBubblePainter old) =>
      old.progress != progress || old.amplitudeScale != amplitudeScale;
}
