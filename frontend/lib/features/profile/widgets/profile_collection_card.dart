import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/library_stats_model.dart';
import 'package:cinemora/features/profile/widgets/profile_shared.dart';

/// Ring chart breaking the library down by cinema type, with a legend.
class ProfileCollectionCard extends StatelessWidget {
  final LibraryStatsModel? stats;
  final bool isLoading;

  const ProfileCollectionCard({
    super.key,
    required this.stats,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats?.totalEntries ?? 0;
    final movies = stats?.movies ?? 0;
    final series = stats?.tvShows ?? 0;
    final anime = stats?.anime ?? 0;

    final movieFrac = total > 0 ? movies / total : 0.0;
    final seriesFrac = total > 0 ? series / total : 0.0;
    final animeFrac = total > 0 ? anime / total : 0.0;

    final moviePct = total > 0 ? '${((movies / total) * 100).round()}%' : '0%';
    final seriesPct = total > 0 ? '${((series / total) * 100).round()}%' : '0%';
    final animePct = total > 0 ? '${((anime / total) * 100).round()}%' : '0%';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: context.colors.surfaceChipBorder.withValues(alpha: 0.6),
        ),
      ),
      child: isLoading
          ? ProfileLoadingPlaceholder(height: 180.h + 80.h)
          : Column(
              children: [
                SizedBox(
                  width: 180.w,
                  height: 180.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(180.w, 180.w),
                        painter: total == 0
                            ? _RingChartPainter(
                                values: const [1.0],
                                colors: [
                                  context.colors.surfaceChipBorder,
                                ],
                              )
                            : _RingChartPainter(
                                values: [movieFrac, seriesFrac, animeFrac],
                                colors: [
                                  context.colors.accentRed,
                                  context.colors.chartPurple,
                                  context.colors.chartYellow,
                                ],
                              ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            total.toString(),
                            style: TextStyle(
                              color: context.colors.foreground,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'TITLES',
                            style: TextStyle(
                              color: context.colors.mutedSecondaryDeep,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _LegendItem(
                        label: 'Movies',
                        value: movies.toString(),
                        percent: moviePct,
                        color: context.colors.accentRed,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _LegendItem(
                        label: 'Series',
                        value: series.toString(),
                        percent: seriesPct,
                        color: context.colors.chartPurple,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _LegendItem(
                        label: 'Anime',
                        value: anime.toString(),
                        percent: animePct,
                        color: context.colors.chartYellow,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String value;
  final String percent;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised2,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: context.colors.foreground,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                percent,
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _RingChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 18.w;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    var start = -1.57;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] * 6.283185307179586;
      paint.color = colors[i];
      canvas.drawArc(rect.deflate(stroke / 2), start, sweep, false, paint);
      start += sweep + 0.06;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
