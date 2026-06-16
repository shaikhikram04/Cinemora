import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:cinemora/core/constants/assets_path.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/router/app_routes.dart';

const _kPosterUrls = [
  'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1505685296765-3a2736de412f?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=200&q=80',
];

/// Pure UI — all state is animation controllers; no business logic → no Cubit.
class OnboardingSuccessView extends StatefulWidget {
  const OnboardingSuccessView({super.key});

  @override
  State<OnboardingSuccessView> createState() => _OnboardingSuccessViewState();
}

class _OnboardingSuccessViewState extends State<OnboardingSuccessView>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final AnimationController _contentController;
  late final Animation<double> _checkScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _checkController.forward();
        _contentController.forward();
      }
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: context.colors.backgroundAlt,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: context.colors.backgroundAlt,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Lottie.asset(
              AppAnimations.confetti,
              fit: BoxFit.cover,
              repeat: false,
              animate: true,
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  ScaleTransition(
                    scale: _checkScale,
                    child: _buildCheckmark(),
                  ),
                  SizedBox(height: 32.h),
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          _buildPosters(),
                          SizedBox(height: 28.h),
                          _buildText(),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _contentFade,
                    child: _buildCTA(context),
                  ),
                  SizedBox(height: WSizes.lg.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckmark() {
    return SizedBox(
      width: 140.w,
      height: 140.w,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 130.w,
            height: 130.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.background,
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withAlpha(84),
                  blurRadius: 32,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: context.colors.primary.withAlpha(32),
                  blurRadius: 64,
                  spreadRadius: 14,
                ),
              ],
            ),
          ),
          Container(
            width: 130.w,
            height: 130.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary.withAlpha(10),
              border: Border.all(
                color: context.colors.primary.withAlpha(50),
                width: 2.w,
              ),
            ),
          ),
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary,
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 44.sp),
          ),
          Positioned(
            top: 4.h,
            right: 0,
            child: _buildFloatingBadge('⭐', const Color(0xFFFBBF24)),
          ),
          Positioned(
            top: 18.h,
            right: -18.w,
            child: _buildFloatingBadge('🌟', const Color(0xFFA78BFA)),
          ),
          Positioned(
            top: 2.h,
            right: -34.w,
            child: _buildFloatingBadge('✨', const Color(0xFF60A5FA)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge(String emoji, Color color) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(50),
        border: Border.all(color: color.withAlpha(130), width: 1.5),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildPosters() {
    return SizedBox(
      height: 100.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _kPosterUrls.asMap().entries.map((entry) {
          final angle = (entry.key - 2) * 0.07;
          return Transform.rotate(
            angle: angle,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              width: 58.w,
              height: 88.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(entry.value),
                  fit: BoxFit.cover,
                ),
                color: context.colors.surfaceRaised,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.xl.w),
      child: Column(
        children: [
          Text(
            'Your cinema experience\nis ready.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          SizedBox(height: WSizes.sm.h),
          Text(
            'Personalized picks, curated just for you.\nStart discovering.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.mutedForeground,
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.home),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
            gradient: const LinearGradient(
              colors: [Color(0xFFE63946), Color(0xFFCF2F3B)],
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withAlpha(90),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore My Cinema',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Text('✨', style: TextStyle(fontSize: 16.sp)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
