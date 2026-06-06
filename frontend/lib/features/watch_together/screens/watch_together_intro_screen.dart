import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/features/watch_together/screens/create_session_screen.dart';
import 'package:watchary/features/watch_together/screens/join_session_screen.dart';

class WatchTogetherIntroScreen extends StatelessWidget {
  const WatchTogetherIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _BackButton(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    const _HeroIllustration(),
                    SizedBox(height: 28.h),
                    Text(
                      'Find Your\nPerfect Match',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WColors.foreground,
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        height: 1.08,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Swipe independently.\nWe\'ll reveal only the movies\nand shows both of you love.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: WColors.mutedSecondary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.65,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    const _FeaturePills(),
                    SizedBox(height: 36.h),
                    _PrimaryButton(
                      icon: Icons.add_rounded,
                      label: 'Create Session',
                      onTap: () => Navigator.push(
                        context,
                        _sharedAxisRoute(const CreateSessionScreen()),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _SecondaryButton(
                      icon: Icons.link_rounded,
                      label: 'Join Session',
                      onTap: () => Navigator.push(
                        context,
                        _sharedAxisRoute(const JoinSessionScreen()),
                      ),
                    ),
                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: WColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: WColors.borderStrong),
        ),
        child: Icon(Icons.arrow_back_rounded, color: WColors.foreground, size: 18.sp),
      ),
    );
  }
}

// ── Hero illustration ─────────────────────────────────────────────────────────

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient glow ring
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFA94EF2).withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Secondary glow
          Container(
            width: 170.w,
            height: 170.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  WColors.accentRed.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Central circle with icon
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2B1259), Color(0xFF6A1950), Color(0xFF9B1C35)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA94EF2).withValues(alpha: 0.30),
                  blurRadius: 48,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: WColors.accentRed.withValues(alpha: 0.20),
                  blurRadius: 32,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_creation_rounded, color: Colors.white, size: 44.sp),
                SizedBox(height: 4.h),
                Icon(Icons.favorite_rounded, color: WColors.accentPink, size: 18.sp),
              ],
            ),
          ),
          // Left person avatar
          Positioned(
            left: 8.w,
            top: 48.h,
            child: _IllustrationAvatar(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFF9B4FF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              glowColor: Color(0xFF7B61FF),
            ),
          ),
          // Right person avatar
          Positioned(
            right: 8.w,
            top: 48.h,
            child: _IllustrationAvatar(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B8A), Color(0xFFEB4B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              glowColor: Color(0xFFEB4B6B),
            ),
          ),
          // Floating heart — top
          Positioned(
            top: 20.h,
            left: 92.w,
            child: Icon(
              Icons.favorite_rounded,
              color: WColors.accentPink.withValues(alpha: 0.55),
              size: 14.sp,
            ),
          ),
          // Floating heart — bottom right
          Positioned(
            bottom: 28.h,
            right: 84.w,
            child: Icon(
              Icons.favorite_rounded,
              color: const Color(0xFFA94EF2).withValues(alpha: 0.5),
              size: 11.sp,
            ),
          ),
          // Sparkle — top right
          Positioned(
            top: 18.h,
            right: 74.w,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.28),
              size: 16.sp,
            ),
          ),
          // Sparkle — bottom left
          Positioned(
            bottom: 22.h,
            left: 74.w,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.22),
              size: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationAvatar extends StatelessWidget {
  final LinearGradient gradient;
  final Color glowColor;

  const _IllustrationAvatar({required this.gradient, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.40),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: 26.sp),
    );
  }
}

// ── Feature pills ─────────────────────────────────────────────────────────────

class _FeaturePills extends StatelessWidget {
  const _FeaturePills();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: const [
        _FeaturePill(icon: Icons.people_rounded, label: 'Social'),
        _FeaturePill(icon: Icons.movie_rounded, label: 'Movies & Series'),
        _FeaturePill(icon: Icons.favorite_rounded, label: 'Mutual Picks'),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: WColors.surfaceRaised,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: WColors.accentPurple, size: 14.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: WColors.mutedSecondary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF9B1C35), WColors.accentRed],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: WColors.accentRed.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: SizedBox(
            height: 54.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
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

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Material(
        color: WColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: SizedBox(
            height: 54.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: WColors.foreground, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: WColors.foreground,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
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

// ── Shared-axis route ─────────────────────────────────────────────────────────

Route<void> _sharedAxisRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
  );
}
