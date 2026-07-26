import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/features/tour/models/tour_step.dart';
import 'package:cinemora/features/tour/viewmodels/tour_cubit.dart';
import 'package:cinemora/features/tour/viewmodels/tour_state.dart';
import 'spotlight_painter.dart';

/// Renders the coach-mark scrim above everything the router shows.
///
/// Mounted once from [MaterialApp.router]'s builder, alongside the offline
/// banner. That's the only place whose subtree contains the Navigator, so it is
/// the only place a single overlay can sit above pushed routes *and* modal
/// bottom sheets — both of which the tour needs to reach.
///
/// While no tour is running this returns [child] untouched.
class TourOverlay extends StatefulWidget {
  final Widget child;

  const TourOverlay({super.key, required this.child});

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay>
    with TickerProviderStateMixin {
  /// Repeats for the ring. Also serves as the per-frame tick that re-reads the
  /// anchor's rect, so the spotlight tracks scrolling for free.
  late final AnimationController _pulse;

  /// Scrim fade-in on the first step.
  late final AnimationController _fade;

  /// Drives the glide from one step's hole to the next.
  late final AnimationController _morph;

  Rect? _displayedRect;
  Rect? _morphFrom;
  TourStep _lastStep = TourStep.inactive;

  static const _holePadding = 8.0;
  static const _holeRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _morph = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _fade.dispose();
    _morph.dispose();
    super.dispose();
  }

  void _onStepChanged(TourStep previous, TourStep current) {
    if (!current.isRunning) {
      _fade.reverse();
      _pulse.stop();
      _displayedRect = null;
      _morphFrom = null;
      return;
    }
    if (!previous.isRunning) {
      _fade.forward();
      _pulse.repeat();
    }
    // Glide from wherever the hole currently sits rather than snapping to the
    // new control — the movement is what tells the user the tour advanced.
    _morphFrom = _displayedRect;
    _morph.forward(from: 0);
  }

  /// Live rect of the step's anchor, in global coordinates. Null while the
  /// anchor is unmounted or has not laid out yet.
  Rect? _anchorRect(TourStep step) {
    final key = context.read<TourCubit>().anchorFor(step);
    final anchorContext = key?.currentContext;
    if (anchorContext == null) return null;
    final box = anchorContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return null;
    return (box.localToGlobal(Offset.zero) & box.size).inflate(_holePadding);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TourCubit, TourState>(
      listenWhen: (prev, curr) => prev.step != curr.step,
      listener: (_, state) {
        final previous = _lastStep;
        _lastStep = state.step;
        _onStepChanged(previous, state.step);
      },
      buildWhen: (prev, curr) =>
          prev.step != curr.step || prev.target != curr.target,
      builder: (context, state) {
        // The Stack is unconditional and the router always sits at index 0.
        // Swapping between `child` and `Stack(children: [child, ...])` would
        // move the router to a different depth, remounting every live route
        // and throwing away all their state the moment the tour started.
        // Adding and removing a trailing child is free by comparison.
        return Stack(
          children: [
            widget.child,
            if (state.step.isRunning)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_pulse, _fade, _morph]),
                  builder: (context, _) => _buildScrim(context, state),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildScrim(BuildContext context, TourState state) {
    final step = state.step;
    final copy = tourCopy[step]!;

    if (step == TourStep.celebrate) {
      return _CelebrationScrim(opacity: _fade.value, copy: copy);
    }

    final target = _anchorRect(step);
    // Anchor not laid out yet — mid-navigation, or a list still building.
    // Showing a scrim with no hole would block the whole screen, and holding a
    // stale rect would spotlight empty space, so drop out until it reappears.
    // The exception is a step change still in flight: the hole is mid-glide
    // and the destination is a frame or two away.
    if (target == null && !(_morph.isAnimating && _displayedRect != null)) {
      return const SizedBox.shrink();
    }

    final morphT = Curves.easeInOutCubic.transform(_morph.value);
    final hole = target == null
        ? _displayedRect!
        : (_morphFrom == null
            ? target
            : Rect.lerp(_morphFrom, target, morphT)!);
    _displayedRect = hole;

    final mq = MediaQuery.of(context);
    final size = mq.size;
    final blocking = step.isBlocking;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SpotlightPainter(
                  hole: hole,
                  holeRadius: _holeRadius,
                  scrimOpacity: _fade.value,
                  pulse: _pulse.value,
                  ringColor: context.colors.accentRed,
                  drawScrim: blocking,
                ),
              ),
            ),
          ),
          // Four blockers around the hole. Leaving the hole itself uncovered
          // lets taps reach the real control underneath with no custom hit
          // testing — the spotlit widget behaves exactly as it normally would.
          // A non-blocking step lays none of them down, so the screen scrolls
          // and responds as usual.
          if (blocking) ..._blockers(hole, size),
          _Caption(
            hole: hole,
            screenSize: size,
            bottomInset: mq.padding.bottom,
            step: step,
            copy: copy,
            opacity: _fade.value,
            morph: morphT,
          ),
        ],
      ),
    );
  }

  List<Widget> _blockers(Rect hole, Size size) {
    Widget block({
      double? left,
      double? top,
      double? right,
      double? bottom,
      double? width,
      double? height,
    }) =>
        Positioned(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          width: width,
          height: height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: const SizedBox.expand(),
          ),
        );

    final top = hole.top.clamp(0.0, size.height);
    final bottom = hole.bottom.clamp(0.0, size.height);
    final left = hole.left.clamp(0.0, size.width);
    final right = hole.right.clamp(0.0, size.width);

    return [
      block(left: 0, top: 0, right: 0, height: top),
      block(left: 0, top: bottom, right: 0, bottom: 0),
      block(left: 0, top: top, width: left, height: bottom - top),
      block(left: right, top: top, right: 0, height: bottom - top),
    ];
  }
}

// ─── Caption card ─────────────────────────────────────────────────────────────

class _Caption extends StatelessWidget {
  final Rect hole;
  final Size screenSize;
  final TourStep step;
  final TourCopy copy;
  final double opacity;
  final double morph;

  /// Bottom safe-area inset, so a pinned card clears the gesture bar.
  final double bottomInset;

  const _Caption({
    required this.hole,
    required this.screenSize,
    required this.bottomInset,
    required this.step,
    required this.copy,
    required this.opacity,
    required this.morph,
  });

  static const _gap = 14.0;
  static const _caret = 9.0;

  @override
  Widget build(BuildContext context) {
    // Hugging the spotlight is right when the screen behind is dimmed anyway.
    // On a non-blocking step it isn't: the card would sit straight over the
    // content the user has just been invited to read. Those pin to the bottom
    // edge instead, well clear of the body, and drop the caret — a tail
    // pointing at something halfway up the screen reads as a mistake.
    final pinned = !step.isBlocking;
    final below = hole.center.dy < screenSize.height / 2;
    final margin = 20.w;

    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!pinned && below)
          _Caret(pointsUp: true, holeCenterX: hole.center.dx, margin: margin),
        _CaptionCard(step: step, copy: copy),
        if (!pinned && !below)
          _Caret(pointsUp: false, holeCenterX: hole.center.dx, margin: margin),
      ],
    );

    // Fades and slides in from the spotlight's side, trailing the hole's glide.
    final entrance = Curves.easeOutCubic.transform(morph.clamp(0.0, 1.0));
    final slideFrom = pinned ? 12.0 : (below ? 12.0 : -12.0);
    final animated = Opacity(
      opacity: opacity * entrance,
      child: Transform.translate(
        offset: Offset(0, slideFrom * (1 - entrance)),
        child: card,
      ),
    );

    if (pinned) {
      return Positioned(
        left: margin,
        right: margin,
        bottom: bottomInset + 16.h,
        child: animated,
      );
    }

    return Positioned(
      left: margin,
      right: margin,
      top: below ? hole.bottom + _gap : null,
      bottom: below ? null : screenSize.height - hole.top + _gap,
      child: animated,
    );
  }
}

class _CaptionCard extends StatelessWidget {
  final TourStep step;
  final TourCopy copy;

  const _CaptionCard({required this.step, required this.copy});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final position = step.position;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (position != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: colors.accentRed.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '$position of ${TourStep.sequence.length}',
                style: TextStyle(
                  color: colors.accentRed,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
          Text(
            copy.title,
            style: TextStyle(
              color: colors.foreground,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            copy.body,
            style: TextStyle(
              color: colors.mutedSecondary,
              fontSize: 12.5.sp,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.read<TourCubit>().skip(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                child: Text(
                  'Skip tour',
                  style: TextStyle(
                    color: colors.mutedSecondaryDeep,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Little triangle tying the card to the spotlight, so the caption reads as
/// pointing at the control rather than floating near it.
class _Caret extends StatelessWidget {
  final bool pointsUp;
  final double holeCenterX;
  final double margin;

  const _Caret({
    required this.pointsUp,
    required this.holeCenterX,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _Caption._caret,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Keep the caret inside the card's rounded corners even when the
          // spotlight sits hard against a screen edge.
          final x = (holeCenterX - margin)
              .clamp(22.0, constraints.maxWidth - 22.0);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: x - _Caption._caret,
                child: CustomPaint(
                  size: const Size(_Caption._caret * 2, _Caption._caret),
                  painter: _CaretPainter(
                    pointsUp: pointsUp,
                    color: context.colors.surfaceRaised,
                    border: context.colors.borderStrong,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CaretPainter extends CustomPainter {
  final bool pointsUp;
  final Color color;
  final Color border;

  const _CaretPainter({
    required this.pointsUp,
    required this.color,
    required this.border,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    } else {
      path
        ..moveTo(size.width / 2, size.height)
        ..lineTo(size.width, 0)
        ..lineTo(0, 0)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(_CaretPainter old) =>
      old.pointsUp != pointsUp || old.color != color || old.border != border;
}

// ─── Closing card ─────────────────────────────────────────────────────────────

class _CelebrationScrim extends StatelessWidget {
  final double opacity;
  final TourCopy copy;

  const _CelebrationScrim({required this.opacity, required this.copy});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Container(
          // Heavier than the spotlight scrim: nothing behind this one needs
          // reading, the card is the whole screen's content.
          color: Colors.black.withValues(alpha: 0.6 * opacity),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Opacity(
            opacity: opacity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1),
              duration: const Duration(milliseconds: 480),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 16.h),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: colors.borderStrong),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎬', style: TextStyle(fontSize: 40.sp)),
                    SizedBox(height: 12.h),
                    Text(
                      copy.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.foreground,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      copy.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.mutedSecondary,
                        fontSize: 13.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () =>
                          context.read<TourCubit>().dismissCelebration(),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: colors.accentRed,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Center(
                          child: Text(
                            'Start exploring',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
