import 'package:cinemora/common/widgets/custom_clipper/triangle_clipper.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookmarkOverlay extends StatefulWidget {
  final WatchStatus? watchStatus;
  final VoidCallback? onToggle;

  const BookmarkOverlay({super.key, required this.watchStatus, this.onToggle});

  @override
  State<BookmarkOverlay> createState() => _BookmarkOverlayState();
}

class _BookmarkOverlayState extends State<BookmarkOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Corner: fades + shrinks out as controller goes 0 → 1
  late final Animation<double> _cornerOpacity;
  late final Animation<double> _cornerScale;

  // Ribbon: scales + fades in as controller goes 0 → 1
  late final Animation<double> _ribbonOpacity;
  late final Animation<double> _ribbonScale;

  bool get _inWatchlist => widget.watchStatus == WatchStatus.watchlist;
  bool get _isWatched => widget.watchStatus == WatchStatus.watched;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _cornerOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _cornerScale = Tween<double>(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ribbonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.2, 1.0, curve: Curves.easeIn)),
    );
    _ribbonScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    if (_inWatchlist) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(BookmarkOverlay old) {
    super.didUpdateWidget(old);
    final wasWatchlist = old.watchStatus == WatchStatus.watchlist;
    if (_inWatchlist != wasWatchlist) {
      _inWatchlist ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_isWatched) ...[
          // Corner "+" — visible when NOT in watchlist
          Positioned(
            right: 0,
            top: 0,
            child: IgnorePointer(
              ignoring: _inWatchlist,
              child: FadeTransition(
                opacity: _cornerOpacity,
                child: ScaleTransition(
                  scale: _cornerScale,
                  alignment: Alignment.topRight,
                  child: _AddToWatchlistCorner(onTap: widget.onToggle),
                ),
              ),
            ),
          ),
          // Ribbon — visible when IN watchlist
          Positioned(
            right: -30.w,
            top: 24.h,
            child: IgnorePointer(
              ignoring: !_inWatchlist,
              child: FadeTransition(
                opacity: _ribbonOpacity,
                child: ScaleTransition(
                  scale: _ribbonScale,
                  child: GestureDetector(
                    onTap: widget.onToggle,
                    child: Transform.rotate(
                      angle: 0.785398,
                      child: const _WatchlistRibbon(label: 'IN WATCHLIST'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (_isWatched)
          Positioned(
            right: -30.w,
            top: 24.h,
            child: Transform.rotate(
              angle: 0.785398,
              child: const _WatchlistRibbon(
                label: 'WATCHED',
                color: Color(0xFF059669),
                horizontalPadding: 40,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Corner "+" button with tap-scale feedback ────────────────────────────────

class _AddToWatchlistCorner extends StatefulWidget {
  final VoidCallback? onTap;

  const _AddToWatchlistCorner({this.onTap});

  @override
  State<_AddToWatchlistCorner> createState() => _AddToWatchlistCornerState();
}

class _AddToWatchlistCornerState extends State<_AddToWatchlistCorner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tap;

  @override
  void initState() {
    super.initState();
    _tap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 80),
    );
  }

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _tap.forward();
    _tap.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.8).animate(
          CurvedAnimation(parent: _tap, curve: Curves.easeOut),
        ),
        alignment: Alignment.topRight,
        child: ClipPath(
          clipper: const TopRightTriangleClipper(),
          child: Container(
            width: 46.w,
            height: 46.w,
            color: context.colors.surfaceMuted.withValues(alpha: 0.7),
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 8.h, right: 8.w),
              child: Icon(Icons.add, color: Colors.white, size: 16.sp),
            ),
          ),
        ),
      ),
    );
  }
}

class _WatchlistRibbon extends StatelessWidget {
  final String label;
  final Color? color;
  final double? horizontalPadding;

  const _WatchlistRibbon({
    required this.label,
    this.color,
    this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? context.colors.accentRed,
      padding: EdgeInsets.symmetric(
        vertical: 2.h,
        horizontal: (horizontalPadding ?? 28).w,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
