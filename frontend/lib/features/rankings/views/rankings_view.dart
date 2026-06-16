import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'package:cinemora/features/rankings/viewmodels/ranking_detail_cubit.dart';
import 'package:cinemora/features/rankings/viewmodels/ranking_detail_state.dart';

// ─── Rankings list view ────────────────────────────────────────────────────────

class RankingsView extends StatelessWidget {
  const RankingsView({super.key});

  static const _lists = kRankingLists;

  void _openCreateListSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const _CreateListSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listCount = _lists.length;
    const rankedCount = 15;
    const topCount = 6;

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
                            '$listCount curated lists',
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
                              Color(0xFFC81B23),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              size: 16.sp,
                              color: Colors.white,
                            ),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  WSizes.screenPadding.w,
                  14.h,
                  WSizes.screenPadding.w,
                  0,
                ),
                child: Row(
                  children: [
                    _StatCard(
                      value: '$listCount',
                      label: 'Lists',
                      accent: context.colors.accentRed,
                    ),
                    SizedBox(width: 12.w),
                    _StatCard(
                      value: '$rankedCount',
                      label: 'Ranked',
                      accent: const Color(0xFF6077FA),
                    ),
                    SizedBox(width: 12.w),
                    _StatCard(
                      value: '$topCount',
                      label: 'Top #1s',
                      accent: const Color(0xFFDDA60F),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                WSizes.screenPadding.w,
                16.h,
                WSizes.screenPadding.w,
                18.h,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == _lists.length) {
                      return _NewListCard(
                        onTap: () => _openCreateListSheet(context),
                      );
                    }

                    final list = _lists[index];
                    return _RankingCard(
                      list: list,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RankingDetailView(list: list),
                          ),
                        );
                      },
                    );
                  },
                  childCount: _lists.length + 1,
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 80.h)),
          ],
        ),
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
                                list.subtitle,
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
                            Text(
                              'Use ↑↓ to reorder',
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
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      6.h,
                      WSizes.screenPadding.w,
                      16.h,
                    ),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _RankingEntryTile(
                        entry: entry,
                        rank: index + 1,
                        accent: list.accent,
                        canMoveUp: index > 0,
                        canMoveDown: index < entries.length - 1,
                        onMoveUp: () => cubit.move(index, -1),
                        onMoveDown: () => cubit.move(index, 1),
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

// ─── Shared private widgets ────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;

  const _StatCard({
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: context.colors.surfaceChip.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: context.colors.surfaceChipBorder.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: context.colors.mutedSecondaryDeep,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final RankingList list;
  final VoidCallback onTap;

  const _RankingCard({
    required this.list,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.colors.surfaceChip.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: list.accent.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageStack(images: list.images, accent: list.accent),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    list.emoji,
                    style: TextStyle(
                      inherit: false,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    list.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: list.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '${list.count} titles',
                    style: TextStyle(
                      color: list.accent,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 18.sp,
                  color: list.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageStack extends StatelessWidget {
  final List<String> images;
  final Color accent;

  const _ImageStack({required this.images, required this.accent});

  @override
  Widget build(BuildContext context) {
    final safeImages = images.take(3).toList();
    return SizedBox(
      height: 64.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(safeImages.length, (index) {
          final drawIndex = safeImages.length - 1 - index;
          final offset = drawIndex * 20.w;
          final rotation = (drawIndex - 1) * 0.2;
          return Positioned(
            left: offset,
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: 52.w,
                height: 64.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    safeImages[drawIndex],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NewListCard extends StatelessWidget {
  final VoidCallback onTap;

  const _NewListCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _DashedBorderBox(
        radius: 24.r,
        strokeWidth: 1.2,
        dashWidth: 6,
        dashGap: 6,
        color: context.colors.borderStrong,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: context.colors.surfaceChip.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: context.colors.accentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                  border:
                      Border.all(color: context.colors.primary.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  Icons.add,
                  color: context.colors.accentRed,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'New List',
                style: TextStyle(
                  color: context.colors.accentRed,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Create ranking',
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _RankingEntryTile extends StatelessWidget {
  final RankingEntry entry;
  final int rank;
  final Color accent;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _RankingEntryTile({
    required this.entry,
    required this.rank,
    required this.accent,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
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
              border: Border.all(color: context.colors.backgroundAlt, width: 0.8),
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
          Column(
            children: [
              _MoveButton(
                icon: Icons.keyboard_arrow_up_rounded,
                enabled: canMoveUp,
                onTap: onMoveUp,
              ),
              SizedBox(height: 4.h),
              _MoveButton(
                icon: Icons.keyboard_arrow_down_rounded,
                enabled: canMoveDown,
                onTap: onMoveDown,
              ),
            ],
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

class _MoveButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _MoveButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(
          color: enabled ? context.colors.surface : null,
          borderRadius: BorderRadius.circular(8.r),
          border: enabled ? Border.all(color: context.colors.borderStrong) : null,
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: enabled ? context.colors.mutedSecondary : context.colors.mutedSecondaryHeader,
        ),
      ),
    );
  }
}

class _CreateListSheet extends StatefulWidget {
  const _CreateListSheet();

  @override
  State<_CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends State<_CreateListSheet> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
            _EmojiPicker(),
            SizedBox(height: 18.h),
            _InputField(
              hint: 'List name (e.g. Best Horror)',
              controller: _nameController,
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 12.h),
            _InputField(hint: 'Short description...(optional)'),
            SizedBox(height: 24.h),
            InkWell(
              onTap: canSubmit ? () => Navigator.pop(context) : null,
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

class _EmojiPicker extends StatefulWidget {
  const _EmojiPicker();

  @override
  State<_EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<_EmojiPicker> {
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

  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.center,
      children: List.generate(_emojis.length, (index) {
        final emoji = _emojis[index];
        final isSelected = index == _selectedIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
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
                style: TextStyle(
                  inherit: false,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        );
      }),
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
