import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/features/watch_together/views/watch_together_intro_view.dart';

class WatchTogetherCard extends StatefulWidget {
  const WatchTogetherCard({super.key});

  @override
  State<WatchTogetherCard> createState() => _WatchTogetherCardState();
}

class _WatchTogetherCardState extends State<WatchTogetherCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 580),
    );
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _TapScaleCard(
          onTap: () => Navigator.push(
            context,
            _sharedAxisPageRoute(const WatchTogetherIntroView()),
          ),
        ),
      ),
    );
  }
}

// ── Tap-to-scale wrapper ───────────────────────────────────────────────────────

class _TapScaleCard extends StatefulWidget {
  final VoidCallback onTap;
  const _TapScaleCard({required this.onTap});

  @override
  State<_TapScaleCard> createState() => _TapScaleCardState();
}

class _TapScaleCardState extends State<_TapScaleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.967)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: const _CardBody(),
      ),
    );
  }
}

// ── Card body ──────────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  const _CardBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B1259), // deep purple
            Color(0xFF6A1950), // mauve
            Color(0xFF9B1C35), // deep red
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA94EF2).withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: context.colors.accentRed.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 18),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Decorative glowing circles
            Positioned(
              right: -24.w,
              top: -24.h,
              child: _GlowCircle(size: 120.w, alpha: 0.06),
            ),
            Positioned(
              right: 64.w,
              bottom: -36.h,
              child: _GlowCircle(size: 80.w, alpha: 0.04),
            ),
            // Top highlight gloss
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45],
                  ),
                ),
              ),
            ),
            // Content row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  _AvatarStack(),
                  SizedBox(width: 16),
                  Expanded(child: _TextSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double alpha;
  const _GlowCircle({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

// ── Avatar illustration ────────────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68.w,
      height: 68.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Back avatar (right, purple)
          Positioned(
            left: 20.w,
            top: 0,
            child: _Avatar(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFF9B4FF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Front avatar (left, pink-red)
          Positioned(
            left: 0,
            top: 0,
            child: _Avatar(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B8A), Color(0xFFEB4B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Heart badge
          Positioned(
            left: 20.w,
            top: 36.h,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: context.colors.accentPink,
                size: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final LinearGradient gradient;
  const _Avatar({required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: 24.sp),
    );
  }
}

// ── Text section ───────────────────────────────────────────────────────────────

class _TextSection extends StatelessWidget {
  const _TextSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Watch Together',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          "Can't decide? Find movies\nboth of you will love.",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        SizedBox(height: 9.h),
        Row(
          children: [
            _SocialChip('Couples'),
            SizedBox(width: 5.w),
            _SocialChip('Friends'),
            SizedBox(width: 5.w),
            _SocialChip('Family'),
            const Spacer(),
            _StartPill(),
          ],
        ),
      ],
    );
  }
}

class _SocialChip extends StatelessWidget {
  final String label;
  const _SocialChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        '✓ $label',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.88),
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StartPill extends StatelessWidget {
  const _StartPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Start  →',
        style: TextStyle(
          color: const Color(0xFF2B1259),
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Shared-axis page route ────────────────────────────────────────────────────

Route<void> _sharedAxisPageRoute(Widget page) {
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
