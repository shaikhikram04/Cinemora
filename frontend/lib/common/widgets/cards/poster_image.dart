import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/watch_status.dart';

typedef BadgeBuilder = Widget Function(BuildContext context, String rating);

class PosterImage extends StatelessWidget {
  final String image;
  final double height;
  final double? width;
  final double radius;
  final String? rating;
  final bool showBookmark;
  final WatchStatus? watchStatus;
  final VoidCallback? onAddToWatchlist;
  final BadgeBuilder? badgeBuilder;
  final String? tag;
  final Color? tagColor;
  final bool showAction;
  final bool actionAdded;
  final VoidCallback? onActionTap;
  final bool titleOnImage;
  final String? title;

  const PosterImage({
    super.key,
    required this.image,
    required this.height,
    this.width,
    this.radius = WSizes.radiusXxl,
    this.rating,
    this.showBookmark = false,
    this.watchStatus,
    this.onAddToWatchlist,
    this.badgeBuilder,
    this.tag,
    this.tagColor,
    this.showAction = false,
    this.actionAdded = false,
    this.onActionTap,
    this.titleOnImage = false,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final renderedHeight = height.h;
    return Container(
      height: renderedHeight,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadowMedium,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image,
              fit: BoxFit.cover,
              // Decode at the rendered size instead of the source resolution —
              // TMDB posters come in far larger than the ~100-140dp we display
              // them at, and decoding full-res per card is a major scroll-jank
              // source in image-heavy carousels. Only ONE of cacheWidth/
              // cacheHeight is ever set: passing both stretches the decode to
              // that exact box, distorting the image if its real aspect ratio
              // doesn't match — specifying just one lets the decoder scale
              // the other dimension to preserve the source's true proportions.
              cacheWidth: width != null ? (width! * dpr).round() : null,
              cacheHeight:
                  width == null ? (renderedHeight * dpr).round() : null,
              errorBuilder: (context, error, stackTrace) => Container(
                color: context.colors.surfaceMuted,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: context.colors.mutedSecondary,
                  size: 22.sp,
                ),
              ),
            ),
            const _PosterGradient(),
            if (showBookmark)
              Positioned.fill(
                child: _BookmarkOverlay(
                  watchStatus: watchStatus,
                  onToggle: onAddToWatchlist,
                ),
              ),
            if (tag != null && tag!.isNotEmpty)
              Positioned(
                left: 8.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: tagColor ?? context.colors.accentRed,
                    borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                  ),
                  child: Text(
                    tag!.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            if (badgeBuilder != null && rating != null)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: badgeBuilder!(context, rating!),
              ),
            if (titleOnImage && title != null)
              Positioned(
                left: 10.w,
                right: 10.w,
                bottom: 10.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: context.colors.tertiary,
                            size: 11.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            rating!,
                            style: TextStyle(
                              color: context.colors.tertiary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              height: (1.8).h,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            if (showAction)
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: GestureDetector(
                  onTap: onActionTap,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      actionAdded ? Icons.check_rounded : Icons.add,
                      color:
                          actionAdded ? context.colors.accentRed : Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PosterGradient extends StatelessWidget {
  const _PosterGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.78),
          ],
        ),
      ),
    );
  }
}

// ─── Animated bookmark overlay ────────────────────────────────────────────────

class _BookmarkOverlay extends StatefulWidget {
  final WatchStatus? watchStatus;
  final VoidCallback? onToggle;

  const _BookmarkOverlay({required this.watchStatus, this.onToggle});

  @override
  State<_BookmarkOverlay> createState() => _BookmarkOverlayState();
}

class _BookmarkOverlayState extends State<_BookmarkOverlay>
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
  void didUpdateWidget(_BookmarkOverlay old) {
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
          clipper: const _TopRightTriangleClipper(),
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

class _TopRightTriangleClipper extends CustomClipper<Path> {
  const _TopRightTriangleClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _TopRightTriangleClipper oldClipper) => false;
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
