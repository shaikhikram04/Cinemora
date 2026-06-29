import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'package:cinemora/features/rankings/viewmodels/ranking_detail_cubit.dart';
import 'package:cinemora/features/rankings/viewmodels/ranking_detail_state.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_cubit.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_state.dart';

// ─── Rankings list view ────────────────────────────────────────────────────────

class RankingsView extends StatelessWidget {
  const RankingsView({super.key});

  void _openCreateListSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<RankingsCubit>(),
        child: const _CreateListSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RankingsCubit, RankingsState>(
      builder: (context, state) {
        final lists = state.lists;
        final listCount = lists.length;
        final rankedCount = state.totalRanked;

        return Container(
          color: context.colors.background,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      16.h,
                      WSizes.screenPadding.w,
                      0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Rankings',
                                style: TextStyle(
                                  color: context.colors.foreground,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                listCount == 0
                                    ? 'No lists yet'
                                    : '$listCount ${listCount == 1 ? 'list' : 'lists'} · $rankedCount titles ranked',
                                style: TextStyle(
                                  color: context.colors.mutedSecondary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openCreateListSheet(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.colors.accentRed,
                                  const Color(0xFFC81B23),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add,
                                    size: 16.sp, color: Colors.white),
                                SizedBox(width: 6.w),
                                Text(
                                  'New List',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (listCount > 0) ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      16.h,
                      WSizes.screenPadding.w,
                      18.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == lists.length) {
                            return _NewListCard(
                              onTap: () => _openCreateListSheet(context),
                            );
                          }
                          final list = lists[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _RankingCard(
                              list: list,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<RankingsCubit>(),
                                      child: RankingDetailView(list: list),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: lists.length + 1,
                      ),
                    ),
                  ),
                ] else ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyRankingsState(
                      onCreateTap: () => _openCreateListSheet(context),
                    ),
                  ),
                ],
                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Tab-level empty state (no lists) ────────────────────────────────────────

class _EmptyRankingsState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyRankingsState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 82.w,
            height: 82.w,
            decoration: BoxDecoration(
              color: context.colors.accentRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.accentRed.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.accentRed.withValues(alpha: 0.12),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child:
                  Text('🏆', style: TextStyle(fontSize: 34.sp, inherit: false)),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'No rankings yet',
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create a list and start ranking your favourite movies & series.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 28.h),
          GestureDetector(
            onTap: onCreateTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 13.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.accentRed, const Color(0xFFC81B23)],
                ),
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentRed.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Create your first list',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail-level empty state (list exists but has no entries) ────────────────

class _EmptyDetailState extends StatelessWidget {
  final RankingList list;
  const _EmptyDetailState({required this.list});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 82.w,
            height: 82.w,
            decoration: BoxDecoration(
              color: list.accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: list.accent.withValues(alpha: 0.22),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: list.accent.withValues(alpha: 0.12),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                list.emoji,
                style: TextStyle(inherit: false, fontSize: 34.sp),
              ),
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'Nothing ranked yet',
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Open any movie or series and add it to this list to start building your ranking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: list.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: list.accent.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13.sp,
                  color: list.accent.withValues(alpha: 0.7),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Rate a title → "Add to ranking"',
                  style: TextStyle(
                    color: list.accent.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
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

// ─── Ranking detail view ───────────────────────────────────────────────────────

class RankingDetailView extends StatelessWidget {
  final RankingList list;

  const RankingDetailView({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RankingDetailCubit(entries: list.entries),
      child: _RankingDetailContent(list: list),
    );
  }
}

class _RankingDetailContent extends StatelessWidget {
  final RankingList list;

  const _RankingDetailContent({required this.list});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RankingDetailCubit, RankingDetailState>(
      builder: (context, state) {
        final cubit = context.read<RankingDetailCubit>();
        final entries = state.entries;
        return Scaffold(
          backgroundColor: context.colors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    WSizes.screenPadding.w,
                    8.h,
                    WSizes.screenPadding.w,
                    0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: context.colors.surfaceChip,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 18.sp,
                            color: context.colors.foreground,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  list.emoji,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    inherit: false,
                                    color: context.colors.foreground,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '  ${list.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.colors.foreground,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${entries.length} titles ranked',
                              style: TextStyle(
                                color: context.colors.mutedSecondaryDeep,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (entries.isNotEmpty)
                  Container(
                    margin: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      14.h,
                      WSizes.screenPadding.w,
                      12.h,
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: list.accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: list.accent.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 16.sp,
                                color: list.accent.withValues(alpha: 0.8),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  list.subtitle.isNotEmpty
                                      ? list.subtitle
                                      : list.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: list.accent.withValues(alpha: 0.8),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: list.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.drag_handle_rounded,
                                size: 12.sp,
                                color: list.accent.withValues(alpha: 0.7),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Hold & drag to reorder',
                                style: TextStyle(
                                  color: list.accent.withValues(alpha: 0.7),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: entries.isEmpty
                      ? _EmptyDetailState(list: list)
                      : ReorderableListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            WSizes.screenPadding.w,
                            6.h,
                            WSizes.screenPadding.w,
                            16.h,
                          ),
                          buildDefaultDragHandles: false,
                          onReorder: (oldIndex, newIndex) {
                            cubit.reorder(oldIndex, newIndex);
                            context.read<RankingsCubit>().reorderEntries(
                                  list.title,
                                  oldIndex,
                                  newIndex,
                                );
                          },
                          proxyDecorator: (child, _, animation) =>
                              AnimatedBuilder(
                            animation: animation,
                            builder: (_, __) => Material(
                              color: Colors.transparent,
                              elevation: 8,
                              borderRadius: BorderRadius.circular(16.r),
                              child: child,
                            ),
                          ),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Padding(
                              key: ValueKey('${entry.title}_$index'),
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _RankingEntryTile(
                                entry: entry,
                                rank: index + 1,
                                accent: list.accent,
                                index: index,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Ranking card (full-width horizontal) ─────────────────────────────────────

class _RankingCard extends StatelessWidget {
  final RankingList list;
  final VoidCallback onTap;

  const _RankingCard({required this.list, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceChip.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: list.accent.withValues(alpha: 0.22)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left accent bar — stretches full height via Positioned
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4.w,
                decoration: BoxDecoration(
                  color: list.accent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    bottomLeft: Radius.circular(20.r),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _PosterFan(
                    images: list.images,
                    accent: list.accent,
                    emoji: list.emoji,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              list.emoji,
                              style: TextStyle(inherit: false, fontSize: 14.sp),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: Text(
                                list.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.colors.foreground,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (list.subtitle.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            list.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.mutedSecondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: list.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                list.count == 0
                                    ? 'Empty'
                                    : '${list.count} ${list.count == 1 ? 'title' : 'titles'}',
                                style: TextStyle(
                                  color: list.accent,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18.sp,
                              color: list.accent.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Poster fan ───────────────────────────────────────────────────────────────

class _PosterFan extends StatelessWidget {
  final List<String> images;
  final Color accent;
  final String emoji;

  const _PosterFan({
    required this.images,
    required this.accent,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        width: 68.w,
        height: 68.h,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(inherit: false, fontSize: 26.sp)),
        ),
      );
    }

    final safe = images.take(3).toList();

    if (safe.length == 1) {
      return _buildPoster(safe[0], 46.w, 66.h);
    }

    return SizedBox(
      width: 76.w,
      height: 68.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (safe.length >= 3)
            Positioned(
              right: 0,
              top: 5.h,
              child: Transform.rotate(
                angle: 0.18,
                child: _buildPoster(safe[2], 42.w, 58.h),
              ),
            ),
          if (safe.length >= 2)
            Positioned(
              right: 14.w,
              top: 2.h,
              child: Transform.rotate(
                angle: 0.07,
                child: _buildPoster(safe[1], 44.w, 62.h),
              ),
            ),
          Positioned(
            left: 0,
            top: 0,
            child: _buildPoster(safe[0], 46.w, 66.h),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(String url, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.r),
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}

// ─── New list card (full-width dashed row) ────────────────────────────────────

class _NewListCard extends StatelessWidget {
  final VoidCallback onTap;

  const _NewListCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _DashedBorderBox(
        radius: 20.r,
        strokeWidth: 1.2,
        dashWidth: 6,
        dashGap: 5,
        color: context.colors.borderStrong,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            color: context.colors.surfaceChip.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: context.colors.accentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.add,
                  color: context.colors.accentRed,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Create a new ranking list',
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dashed border ────────────────────────────────────────────────────────────

class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final Color color;

  const _DashedBorderBox({
    required this.child,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRoundedRectPainter(
        radius: radius,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashGap: dashGap,
        color: color,
      ),
      child: child,
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final Color color;

  const _DashedRoundedRectPainter({
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final length = dashWidth.clamp(0.0, metric.length - distance);
        final segment = metric.extractPath(distance, distance + length);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap ||
        color != oldDelegate.color;
  }
}

// ─── Ranking entry tile ───────────────────────────────────────────────────────

class _RankingEntryTile extends StatelessWidget {
  final RankingEntry entry;
  final int rank;
  final Color accent;
  final int index;

  const _RankingEntryTile({
    required this.entry,
    required this.rank,
    required this.accent,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceChip,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Row(
        children: [
          _Medal(rank: rank, color: accent),
          SizedBox(width: 8.w),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border:
                  Border.all(color: context.colors.backgroundAlt, width: 0.8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.network(
                entry.image,
                width: 46.w,
                height: 64.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        entry.type.toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '★ ${entry.rating}  ·  ${entry.year}',
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
          ),
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Icon(
                Icons.drag_handle_rounded,
                size: 20.sp,
                color: context.colors.mutedSecondaryDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Medal extends StatelessWidget {
  final int rank;
  final Color color;

  const _Medal({required this.rank, required this.color});

  @override
  Widget build(BuildContext context) {
    final rankString = rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank';
    final size = rank <= 3 ? 22.sp : 16.sp;

    return SizedBox(
      width: 32.w,
      child: Text(
        rankString,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

// ─── Create list sheet ────────────────────────────────────────────────────────

class _CreateListSheet extends StatefulWidget {
  const _CreateListSheet();

  @override
  State<_CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends State<_CreateListSheet> {
  static const _hintPool = [
    'All-Time Favorites',
    'Hidden Gems',
    'Comfort Watches',
    'Mind-Blowing Endings',
    'Best Thrillers',
    'Feel-Good Films',
    'Masterpieces Only',
    'Guilty Pleasures',
    'Award Winners',
    'Underrated Classics',
    'Weekend Picks',
    'Date Night Films',
    'Best Horror',
    'Animated Favorites',
    'Crime & Mystery',
    'Binge-Worthy Series',
    'Dark & Intense',
    'Best Sci-Fi',
    'Top Anime',
    'Tearjerkers',
    'Action Packed',
    'Foreign Language Favorites',
    'Based on True Events',
    'Best Documentaries',
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedEmoji = '🏆';
  late final String _hint;

  @override
  void initState() {
    super.initState();
    final existing = context
        .read<RankingsCubit>()
        .state
        .lists
        .map((l) => l.title.toLowerCase())
        .toSet();
    final available =
        _hintPool.where((h) => !existing.contains(h.toLowerCase())).toList();
    final pool = available.isNotEmpty ? available : _hintPool;
    _hint = pool[Random().nextInt(pool.length)];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _nameController.text.trim();
    if (title.isEmpty) return;
    context.read<RankingsCubit>().createList(
          emoji: _selectedEmoji,
          title: title,
          subtitle: _descController.text.trim(),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: context.colors.borderStrong),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: context.colors.mutedSecondaryDeep,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            Text(
              'Create New List',
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Curate your perfect ranking',
              style: TextStyle(
                color: context.colors.mutedSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 14.h),
            _EmojiPicker(
              selected: _selectedEmoji,
              onSelect: (e) => setState(() => _selectedEmoji = e),
            ),
            SizedBox(height: 18.h),
            _InputField(
              hint: _hint,
              controller: _nameController,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 12.h),
            _InputField(
              hint: 'Short description... (optional)',
              controller: _descController,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: canSubmit ? _submit : null,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: canSubmit
                      ? context.colors.primary.withValues(alpha: 0.9)
                      : context.colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Center(
                  child: Text(
                    'Create List',
                    style: TextStyle(
                      color: canSubmit
                          ? context.colors.foreground
                          : context.colors.mutedSecondary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
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

class _EmojiPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _EmojiPicker({required this.selected, required this.onSelect});

  static const List<String> _emojis = [
    '🏆',
    '❤️',
    '🚀',
    '⛩️',
    '📺',
    '🎬',
    '🤯',
    '🖤',
    '👻',
    '💎',
    '🔥',
    '⭐',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.center,
      children: _emojis.map((emoji) {
        final isSelected = emoji == selected;
        return GestureDetector(
          onTap: () => onSelect(emoji),
          child: Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.accentRed.withValues(alpha: 0.18)
                  : context.colors.surfaceRaised,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? context.colors.accentRed.withValues(alpha: 0.3)
                    : context.colors.borderStrong,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(inherit: false, fontSize: 16.sp),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.hint,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        color: context.colors.foreground,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      cursorHeight: 20.h,
      cursorColor: context.colors.foreground,
      cursorWidth: 1,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.colors.mutedSecondaryDeep,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: context.colors.surfaceChip,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: context.colors.border),
        ),
      ),
    );
  }
}
