import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/common/widgets/icons/app_icon.dart';
import 'package:cinemora/core/constants/assets_path.dart';

void showShufflePick(BuildContext context, List<LibraryEntryModel> watchlist) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => _ShufflePickSheet(watchlist: watchlist),
  );
}

// ── Poster geometry ─────────────────────────────────────────────────────────
const double _kPosterW = 150;
const double _kPosterH = 225; // 2:3

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
  late LibraryEntryModel _pick;
  int? _lastPickIndex;
  final _rng = Random();
  int _spinGeneration = 0;
  bool _didPrecache = false;

  // The reel: a sequence of posters that whir through the frame, the LAST of
  // which is always the winning pick — so the spin lands on it, never cuts.
  late List<LibraryEntryModel> _reel;
  int _reelIndex = 0;
  bool _showMeta = false;
  // Each slide lasts as long as its poster stays on screen, so the reel keeps
  // moving — the slowdown reads as longer slides, not slides with dead gaps.
  Duration _slideDur = const Duration(milliseconds: 150);

  // Settle animation: subtle scale bounce + a soft accent glow bloom.
  late AnimationController _settleCtrl;
  late Animation<double> _settleScale;
  late Animation<double> _glow;

  // Slot-machine slowdown: fast → slow → stop. One entry per reel step.
  static const _intervals = [65, 65, 75, 85, 105, 135, 175, 230, 300, 390];

  @override
  void initState() {
    super.initState();
    _settleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
    );
    _settleScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_settleCtrl);
    _glow = CurvedAnimation(parent: _settleCtrl, curve: Curves.easeOut);

    _pick = _pickRandom();
    _reel = _buildReel();

    // A single-item watchlist has nothing to spin — reveal it straight away.
    if (widget.watchlist.length == 1) {
      _reelIndex = _reel.length - 1;
      _phase = _Phase.settled;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _settleCtrl.forward();
        setState(() => _showMeta = true);
      });
    } else {
      _runSpin(0, _spinGeneration);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) return;
    _didPrecache = true;
    // Warm the winner + every poster the reel will flash, so the landing frame
    // is crisp artwork and the spin never stalls on a network fetch. Best-effort.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cw = (_kPosterW.w * dpr).round();
    final seen = <String>{};
    for (final e in _reel) {
      if (e.posterUrl.isEmpty || !seen.add(e.posterUrl)) continue;
      precacheImage(
        ResizeImage(NetworkImage(e.posterUrl), width: cw),
        context,
      ).catchError((_) {});
    }
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

  // Random posters to flash, ending on the pick, with no back-to-back repeats
  // (so every reel step visibly changes the frame).
  List<LibraryEntryModel> _buildReel() {
    final wl = widget.watchlist;
    final n = _intervals.length + 1;
    final list = <LibraryEntryModel>[];
    for (var i = 0; i < n - 1; i++) {
      LibraryEntryModel e;
      do {
        e = wl[_rng.nextInt(wl.length)];
      } while (wl.length > 1 && list.isNotEmpty && identical(e, list.last));
      list.add(e);
    }
    list.add(_pick);
    // Avoid the very last spin frame matching the pick (would look like a stall).
    if (wl.length > 1 && list.length >= 2 && identical(list[n - 2], _pick)) {
      LibraryEntryModel e;
      do {
        e = wl[_rng.nextInt(wl.length)];
      } while (identical(e, _pick));
      list[n - 2] = e;
    }
    return list;
  }

  void _runSpin(int step, int generation) {
    if (step >= _intervals.length) {
      if (generation == _spinGeneration) _settle(generation);
      return;
    }
    Future.delayed(Duration(milliseconds: _intervals[step]), () {
      if (!mounted || generation != _spinGeneration) return;
      final next = step + 1;
      if (next < _reel.length) {
        HapticFeedback.selectionClick();
        // This poster is on screen until the next arrives (_intervals[next]),
        // or ~260ms for the final pick — stretch its slide to fill that window.
        final durMs = next < _intervals.length ? _intervals[next] : 260;
        setState(() {
          _slideDur = Duration(milliseconds: max(90, durMs));
          _reelIndex = next;
        });
      }
      _runSpin(next, generation);
    });
  }

  void _settle(int generation) {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    _settleCtrl.forward(from: 0);
    setState(() => _phase = _Phase.settled);
    // Let the poster land, then bring the details up under it.
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted || generation != _spinGeneration) return;
      setState(() => _showMeta = true);
    });
  }

  void _reshuffle() {
    _spinGeneration++;
    _pick = _pickRandom();
    _reel = _buildReel();
    _settleCtrl.reset();
    setState(() {
      _phase = _Phase.spinning;
      _showMeta = false;
      _reelIndex = 0;
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
    _settleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settled = _phase == _Phase.settled;
    // The pick's poster backs the sheet the whole time; the scrim hides it while
    // spinning and lightens on settle for a cinematic reveal.
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
          if (bgUrl.isNotEmpty) Positioned.fill(child: _BlurredBg(url: bgUrl)),
          // Scrim — heavy during spin, lighter when settled.
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: settled
                      ? [const Color(0xBB0E0E12), const Color(0xEE000000)]
                      : [const Color(0xEE0E0E12), const Color(0xF8000000)],
                ),
              ),
            ),
          ),
          // Handle.
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
          // Content.
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 34.h, 24.w, 30.h),
            child: Column(
              children: [
                SizedBox(height: 6.h),
                // Label — fades in on settle.
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: settled ? 1 : 0,
                  child: _Label(),
                ),
                SizedBox(height: 18.h),
                // The persistent poster stage — spins, then settles into place.
                _PosterStage(
                  entry: _reel[_reelIndex],
                  reelIndex: _reelIndex,
                  slideDur: _slideDur,
                  scale: _settleScale,
                  glow: _glow,
                  ctrl: _settleCtrl,
                  accent: context.colors.accentRed,
                ),
                SizedBox(height: 20.h),
                // Lower region: spin caption → pick details. Centered and
                // overflow-safe (scaleDown) so long titles never blow the layout.
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 340),
                        switchInCurve: Curves.easeOut,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: settled && _showMeta
                            ? _MetaBlock(
                                key: const ValueKey('meta'),
                                entry: _pick,
                              )
                            : const _SpinCaption(key: ValueKey('caption')),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Actions — reserved space; fade in on settle.
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 360),
                  opacity: _showMeta ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_showMeta,
                    child: _Actions(
                      onView: () => _openDetail(context),
                      onReshuffle: _reshuffle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Poster stage ──────────────────────────────────────────────────────────────
// One frame that lives through both phases: reel posters slide up through it
// while spinning, and the winner settles in with a bounce + glow.

class _PosterStage extends StatelessWidget {
  final LibraryEntryModel entry;
  final int reelIndex;
  final Duration slideDur;
  final Animation<double> scale;
  final Animation<double> glow;
  final Listenable ctrl;
  final Color accent;

  const _PosterStage({
    required this.entry,
    required this.reelIndex,
    required this.slideDur,
    required this.scale,
    required this.glow,
    required this.ctrl,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final w = _kPosterW.w;
    final h = _kPosterH.h;
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, child) {
        final g = glow.value;
        return Transform.scale(
          scale: scale.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.42 * g),
                  blurRadius: 44 * g,
                  spreadRadius: 1.5 * g,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: w,
        height: h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedSwitcher(
            duration: slideDur,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) {
              // Incoming rises from below; outgoing exits upward → a reel scroll.
              return AnimatedBuilder(
                animation: anim,
                builder: (_, c) {
                  final incoming = anim.status == AnimationStatus.forward ||
                      anim.status == AnimationStatus.completed;
                  final dy = incoming
                      ? (1 - anim.value) * 0.6
                      : -(1 - anim.value) * 0.6;
                  return FractionalTranslation(
                    translation: Offset(0, dy),
                    child: Opacity(opacity: anim.value.clamp(0, 1), child: c),
                  );
                },
                child: child,
              );
            },
            child: _Poster(
              key: ValueKey(reelIndex),
              url: entry.posterUrl,
              width: w,
              height: h,
            ),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  const _Poster({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _Fallback(width: width, height: height);
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      // Width only — see poster_image.dart for why passing both dims can
      // distort the decode.
      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).round(),
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _Fallback(width: width, height: height),
    );
  }
}

// ── Spin caption ──────────────────────────────────────────────────────────────

class _SpinCaption extends StatelessWidget {
  const _SpinCaption({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4.h),
        Text(
          'Picking your night…',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Shuffling your watchlist',
          style: TextStyle(
            color: context.colors.mutedSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Settled details ───────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(AppIcons.movie,
            size: 15.sp, color: context.colors.mutedSecondary),
        SizedBox(width: 6.w),
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
    );
  }
}

class _MetaBlock extends StatelessWidget {
  final LibraryEntryModel entry;
  const _MetaBlock({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (entry.releaseYear != null) entry.releaseYear!,
      if (entry.genres.isNotEmpty) entry.genres.first,
    ].join(' · ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TypeBadge(type: entry.cinemaType),
        SizedBox(height: 12.h),
        Text(
          entry.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 23.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        if (meta.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            meta,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (entry.tmdbRating != null) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded,
                  size: 15.sp, color: context.colors.warning),
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
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onReshuffle;
  const _Actions({required this.onView, required this.onReshuffle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                AppIcon(AppIcons.randomPick,
                    size: 22.sp, color: context.colors.mutedSecondary),
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
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _BlurredBg extends StatelessWidget {
  final String url;
  static final _filter = ImageFilter.blur(sigmaX: 32, sigmaY: 32);
  const _BlurredBg({required this.url});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    // Isolated layer so the spin motion doesn't force this heavy gaussian blur
    // to repaint every frame — it only changes when the pick's bg changes.
    return RepaintBoundary(
      child: ImageFiltered(
        imageFilter: _filter,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          // Width only — see poster_image.dart for why passing both dims can
          // distort the decode (harmless under this much blur, but kept
          // consistent with the rest of the app).
          cacheWidth: (size.width * dpr).round(),
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

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
      child: AppIcon(AppIcons.movie,
          size: 28.sp, color: context.colors.mutedSecondary),
    );
  }
}
