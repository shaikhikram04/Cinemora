import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';

void showShufflePick(BuildContext context, List<LibraryEntryModel> watchlist) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => _ShufflePickSheet(watchlist: watchlist),
  );
}

// ── Sheet ─────────────────────────────────────────────────────────────────────

class _ShufflePickSheet extends StatefulWidget {
  final List<LibraryEntryModel> watchlist;
  const _ShufflePickSheet({required this.watchlist});

  @override
  State<_ShufflePickSheet> createState() => _ShufflePickSheetState();
}

enum _Phase { spinning, settled }

class _ShufflePickSheetState extends State<_ShufflePickSheet>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.spinning;
  int _spinIndex = 0;
  late LibraryEntryModel _pick;
  int? _lastPickIndex;
  final _rng = Random();
  int _spinGeneration = 0;

  late AnimationController _diceCtrl;

  // Slot-machine slowdown: fast → slow → stop
  static const _intervals = [65, 65, 75, 85, 105, 135, 175, 230, 300, 390];

  @override
  void initState() {
    super.initState();
    _diceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..repeat();
    _pick = _pickRandom();
    _runSpin(0, _spinGeneration);
  }

  LibraryEntryModel _pickRandom() {
    if (widget.watchlist.length == 1) return widget.watchlist.first;
    int idx;
    do {
      idx = _rng.nextInt(widget.watchlist.length);
    } while (idx == _lastPickIndex);
    _lastPickIndex = idx;
    return widget.watchlist[idx];
  }

  void _runSpin(int tick, int generation) {
    if (tick >= _intervals.length) {
      if (generation == _spinGeneration) _settle();
      return;
    }
    Future.delayed(Duration(milliseconds: _intervals[tick]), () {
      if (!mounted || generation != _spinGeneration) return;
      setState(() => _spinIndex = _rng.nextInt(widget.watchlist.length));
      _runSpin(tick + 1, generation);
    });
  }

  void _settle() {
    if (!mounted) return;
    _diceCtrl.stop();
    setState(() => _phase = _Phase.settled);
  }

  void _reshuffle() {
    _pick = _pickRandom();
    _spinGeneration++;
    _diceCtrl.repeat();
    setState(() {
      _phase = _Phase.spinning;
      _spinIndex = _rng.nextInt(widget.watchlist.length);
    });
    _runSpin(0, _spinGeneration);
  }

  void _openDetail(BuildContext ctx) {
    final router = GoRouter.of(ctx);
    Navigator.pop(ctx);
    final e = _pick;
    if (e.cinemaType == CinemaType.movie) {
      router.push(AppRoutes.movieDetails,
          extra: MovieRouteArgs(
            title: e.title,
            image: e.posterUrl,
            rating: e.tmdbRating?.toStringAsFixed(1) ?? '—',
            id: e.tmdbId,
          ));
    } else {
      router.push(AppRoutes.seriesDetails,
          extra: SeriesRouteArgs(
            title: e.title,
            image: e.posterUrl,
            rating: e.tmdbRating?.toStringAsFixed(1) ?? '—',
            id: e.tmdbId,
            source: e.cinemaType == CinemaType.anime ? 'jikan' : 'tmdb',
          ));
    }
  }

  @override
  void dispose() {
    _diceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use the final pick's poster as the bg — the scrim hides it during
    // spinning and lightens on settle, creating a cinematic reveal.
    final bgUrl = _pick.posterUrl;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E12),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // ── Blurred background (stable key — no duplicate) ──────────
          if (bgUrl.isNotEmpty)
            Positioned.fill(
              child: _BlurredBg(url: bgUrl),
            ),
          // ── Gradient scrim — heavy during spin, lighter when settled ─
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _phase == _Phase.spinning
                      ? [const Color(0xEE0E0E12), const Color(0xF8000000)]
                      : [const Color(0xBB0E0E12), const Color(0xEE000000)],
                ),
              ),
            ),
          ),
          // ── Handle ──────────────────────────────────────────────────
          Positioned(
            top: 12.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          // ── Phase content ────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: _phase == _Phase.spinning
                ? _SpinView(
                    key: const ValueKey('spin'),
                    diceCtrl: _diceCtrl,
                    title: widget.watchlist[_spinIndex].title,
                  )
                : _ResultView(
                    key: const ValueKey('result'),
                    entry: _pick,
                    onView: () => _openDetail(context),
                    onReshuffle: _reshuffle,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Blurred background ────────────────────────────────────────────────────────

class _BlurredBg extends StatelessWidget {
  final String url;
  static final _filter = ImageFilter.blur(sigmaX: 32, sigmaY: 32);
  const _BlurredBg({required this.url});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    // Isolated in its own compositing layer so the spin animation (rotating
    // dice icon, gradient scrim, rapid title swaps) doesn't force this heavy
    // gaussian blur to be repainted every frame — it only needs to repaint
    // when the picked entry (and therefore the bg image) actually changes.
    return RepaintBoundary(
      child: ImageFiltered(
        imageFilter: _filter,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          // Width only — see poster_image.dart for why passing both dims
          // can distort the decode (harmless here anyway under this much
          // blur, but kept consistent with the rest of the app).
          cacheWidth: (size.width * dpr).round(),
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// ── Spinning view ─────────────────────────────────────────────────────────────

class _SpinView extends StatelessWidget {
  final AnimationController diceCtrl;
  final String title;
  const _SpinView({super.key, required this.diceCtrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: diceCtrl,
            child: Icon(
              Icons.casino_outlined,
              size: 76.sp,
              color: context.colors.accentRed,
            ),
          ),
          SizedBox(height: 32.h),
          SizedBox(
            height: 32.h,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 70),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                title,
                key: ValueKey(title),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Shuffling your watchlist...',
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result view ───────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final LibraryEntryModel entry;
  final VoidCallback onView;
  final VoidCallback onReshuffle;

  const _ResultView({
    super.key,
    required this.entry,
    required this.onView,
    required this.onReshuffle,
  });

  @override
  Widget build(BuildContext context) {
    final hasPoster = entry.posterUrl.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 44.h, 24.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Icon(Icons.local_movies_outlined,
                  size: 11.sp, color: context.colors.mutedSecondary),
              SizedBox(width: 5.w),
              Text(
                "TONIGHT'S PICK",
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          // Poster + info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: hasPoster
                    ? Image.network(
                        entry.posterUrl,
                        width: 104.w,
                        height: 156.h,
                        fit: BoxFit.cover,
                        // Width only — see poster_image.dart for why
                        // passing both dims can distort the decode.
                        cacheWidth:
                            (104.w * MediaQuery.of(context).devicePixelRatio)
                                .round(),
                        errorBuilder: (_, __, ___) =>
                            _Fallback(width: 104.w, height: 156.h),
                      )
                    : _Fallback(width: 104.w, height: 156.h),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TypeBadge(type: entry.cinemaType),
                    SizedBox(height: 8.h),
                    Text(
                      entry.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    if (entry.releaseYear != null ||
                        entry.genres.isNotEmpty) ...[
                      Text(
                        [
                          if (entry.releaseYear != null) entry.releaseYear!,
                          if (entry.genres.isNotEmpty) entry.genres.first,
                        ].join(' · '),
                        style: TextStyle(
                          color: context.colors.mutedSecondary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                    ],
                    if (entry.tmdbRating != null)
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 14.sp, color: context.colors.warning),
                          SizedBox(width: 4.w),
                          Text(
                            entry.tmdbRating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: context.colors.foreground,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // View Details
          GestureDetector(
            onTap: onView,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              decoration: BoxDecoration(
                color: context.colors.accentRed,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_rounded,
                      size: 16.sp, color: Colors.white),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Shuffle Again
          GestureDetector(
            onTap: onReshuffle,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino_outlined,
                      size: 15.sp, color: context.colors.mutedSecondary),
                  SizedBox(width: 8.w),
                  Text(
                    'Shuffle Again',
                    style: TextStyle(
                      color: context.colors.mutedSecondary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final CinemaType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      CinemaType.movie => ('MOVIE', context.colors.accentRed),
      CinemaType.tv => ('SERIES', context.colors.accentPurple),
      CinemaType.anime => ('ANIME', context.colors.warning),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final double width;
  final double height;
  const _Fallback({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Icons.movie_outlined,
          size: 28.sp, color: context.colors.mutedSecondary),
    );
  }
}
