import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';

class LibraryStatsCard extends StatelessWidget {
  final int watchedCount;
  final int totalEntries;
  final int moviesWatched;
  final int seriesWatched;
  final int animeWatched;

  const LibraryStatsCard({
    super.key,
    required this.watchedCount,
    required this.totalEntries,
    required this.moviesWatched,
    required this.seriesWatched,
    required this.animeWatched,
  });

  double get _ringProgress =>
      totalEntries == 0 ? 0.0 : (watchedCount / totalEntries).clamp(0.0, 1.0);

  int get _completionPct => (_ringProgress * 100).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Stack(
        children: [
          // Ambient glow blobs
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentPurple.withValues(alpha: 0.4),
                    blurRadius: 100,
                    offset: const Offset(0, 10),
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentRed.withValues(alpha: 0.4),
                    blurRadius: 100,
                    offset: const Offset(0, 10),
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              // ── Ring + completion % ───────────────────────────────
              Row(
                children: [
                  SizedBox(
                    width: 90.w,
                    height: 90.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(90.w, 90.w),
                          painter: _RingPainter(
                            progress: _ringProgress,
                            trackColor: context.colors.surfaceRaised,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$watchedCount/$totalEntries',
                              style: TextStyle(
                                color: context.colors.foreground,
                                fontSize: totalEntries >= 100 ? 14.sp : 18.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'watched',
                              style: TextStyle(
                                color: context.colors.mutedSecondary,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COMPLETION',
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$_completionPct',
                                style: TextStyle(
                                  color: context.colors.accentRed,
                                  fontSize: 42.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  height: 1.0,
                                ),
                              ),
                              TextSpan(
                                text: '%',
                                style: TextStyle(
                                  color: context.colors.accentRed,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'of your library has been watched',
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              // ── Category breakdown ────────────────────────────────────
              Row(
                children: [
                  _CategoryChip(
                    icon: Icons.movie_outlined,
                    iconColor: context.colors.accentRed,
                    label: 'MOVIES',
                    value: '$moviesWatched watched',
                  ),
                  SizedBox(width: 8.w),
                  _CategoryChip(
                    icon: Icons.tv_outlined,
                    iconColor: context.colors.accentPurple,
                    label: 'SERIES',
                    value: '$seriesWatched watched',
                  ),
                  SizedBox(width: 8.w),
                  _CategoryChip(
                    icon: Icons.auto_awesome_outlined,
                    iconColor: context.colors.warning,
                    label: 'ANIME',
                    value: '$animeWatched watched',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _CategoryChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: context.colors.surfaceOverlay.withValues(alpha: 0.12),
          borderRadius: BorderRadius.all(Radius.elliptical(20.r, 18.r)),
          border: Border.all(color: context.colors.borderStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12.sp, color: iconColor),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: TextStyle(
                    color: context.colors.mutedSecondary,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ring painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;

  const _RingPainter({required this.progress, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 8;
    const strokeW = 8.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    if (progress > 0) {
      final arcPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFE7847), Color(0xFFE63946)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.trackColor != trackColor;
}
