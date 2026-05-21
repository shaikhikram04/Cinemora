import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  final List<RankingList> _lists = [
    RankingList(
      emoji: '❤️',
      title: 'All-Time Favorites',
      subtitle: 'The absolute best content I\'ve ever seen',
      count: 3,
      accent: WColors.accentRed,
      images: const [
        'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1779029314445-b20031dfd4e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      entries: const [
        RankingEntry(
          title: 'Oppenheimer',
          year: '2023',
          type: 'Movie',
          rating: '8.3',
          image:
              'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'The Dark Knight',
          year: '2008',
          type: 'Movie',
          rating: '9.0',
          image:
              'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Attack on Titan',
          year: '2013',
          type: 'Anime',
          rating: '9.1',
          image:
              'https://images.unsplash.com/photo-1779029314445-b20031dfd4e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ),
      ],
    ),
    RankingList(
      emoji: '🚀',
      title: 'Best Sci-Fi',
      subtitle: 'Mind-expanding science fiction',
      count: 4,
      accent: WColors.chartPurple,
      images: const [
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=300&q=80',
      ],
      entries: const [
        RankingEntry(
          title: 'Interstellar',
          year: '2014',
          type: 'Movie',
          rating: '8.7',
          image:
              'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Inception',
          year: '2010',
          type: 'Movie',
          rating: '8.8',
          image:
              'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Dune: Part Two',
          year: '2024',
          type: 'Movie',
          rating: '8.7',
          image:
              'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Blade Runner 2049',
          year: '2017',
          type: 'Movie',
          rating: '8.0',
          image:
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=300&q=80',
        ),
      ],
    ),
    RankingList(
      emoji: '⛩️',
      title: 'Top Anime',
      subtitle: 'Essential anime that never miss',
      count: 4,
      accent: WColors.accentRedSoft,
      images: const [
        'https://images.unsplash.com/photo-1779029314445-b20031dfd4e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
      ],
      entries: const [
        RankingEntry(
          title: 'Attack on Titan',
          year: '2013',
          type: 'Anime',
          rating: '9.1',
          image:
              'https://images.unsplash.com/photo-1779029314445-b20031dfd4e3?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ),
        RankingEntry(
          title: 'Fullmetal Alchemist',
          year: '2009',
          type: 'Anime',
          rating: '9.1',
          image:
              'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Frieren',
          year: '2023',
          type: 'Anime',
          rating: '9.1',
          image:
              'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Death Note',
          year: '2006',
          type: 'Anime',
          rating: '9.0',
          image:
              'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=300&q=80',
        ),
      ],
    ),
    RankingList(
      emoji: '🤯',
      title: 'Mind-Blowing',
      subtitle: 'Unforgettable finales and twists',
      count: 3,
      accent: WColors.accentPurple,
      images: const [
        'https://images.unsplash.com/photo-1528360983277-13d401cdc186?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=300&q=80',
      ],
      entries: const [
        RankingEntry(
          title: 'Shogun',
          year: '2024',
          type: 'Series',
          rating: '9.1',
          image:
              'https://images.unsplash.com/photo-1528360983277-13d401cdc186?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Dark',
          year: '2017',
          type: 'Series',
          rating: '8.7',
          image:
              'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Arrival',
          year: '2016',
          type: 'Movie',
          rating: '7.9',
          image:
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=300&q=80',
        ),
      ],
    ),
    RankingList(
      emoji: '📺',
      title: 'Binge-Worthy',
      subtitle: 'Can\'t stop watching',
      count: 3,
      accent: WColors.success,
      images: const [
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=300&q=80',
      ],
      entries: const [
        RankingEntry(
          title: 'Breaking Bad',
          year: '2008',
          type: 'Series',
          rating: '9.5',
          image:
              'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Succession',
          year: '2018',
          type: 'Series',
          rating: '8.9',
          image:
              'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'True Detective',
          year: '2014',
          type: 'Series',
          rating: '9.0',
          image:
              'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=300&q=80',
        ),
      ],
    ),
    RankingList(
      emoji: '🖤',
      title: 'Dark & Intense',
      subtitle: 'Psychologically gripping stories',
      count: 3,
      accent: WColors.mutedSecondaryDeep,
      images: const [
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=300&q=80',
      ],
      entries: const [
        RankingEntry(
          title: 'Mindhunter',
          year: '2017',
          type: 'Series',
          rating: '8.6',
          image:
              'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Parasite',
          year: '2019',
          type: 'Movie',
          rating: '8.5',
          image:
              'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=300&q=80',
        ),
        RankingEntry(
          title: 'Prisoners',
          year: '2013',
          type: 'Movie',
          rating: '8.1',
          image:
              'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=300&q=80',
        ),
      ],
    ),
  ];

  void _openCreateListSheet() {
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
      color: WColors.background,
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
                              color: WColors.foreground,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '$listCount curated lists',
                            style: TextStyle(
                              color: WColors.mutedSecondary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _openCreateListSheet,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              WColors.accentRed,
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
                      accent: WColors.accentRed,
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
                      return _NewListCard(onTap: _openCreateListSheet);
                    }

                    final list = _lists[index];
                    return _RankingCard(
                      list: list,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RankingDetailScreen(list: list),
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
          color: WColors.surfaceChip.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: WColors.surfaceChipBorder.withValues(alpha: 0.6),
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
                color: WColors.mutedSecondaryDeep,
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
          color: WColors.surfaceChip.withValues(alpha: 0.6),
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
                      color: WColors.foreground,
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
          final rotation = (drawIndex - 1) * 0.2; // subtle curve
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
        color: WColors.borderStrong,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: WColors.surfaceChip.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: WColors.accentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                  border:
                      Border.all(color: WColors.primary.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  Icons.add,
                  color: WColors.accentRed,
                  size: 20.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'New List',
                style: TextStyle(
                  color: WColors.accentRed,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Create ranking',
                style: TextStyle(
                  color: WColors.mutedSecondary,
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

class RankingDetailScreen extends StatefulWidget {
  final RankingList list;

  const RankingDetailScreen({super.key, required this.list});

  @override
  State<RankingDetailScreen> createState() => _RankingDetailScreenState();
}

class _RankingDetailScreenState extends State<RankingDetailScreen> {
  late List<RankingEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.of(widget.list.entries);
  }

  void _move(int index, int direction) {
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= _entries.length) return;
    setState(() {
      final item = _entries.removeAt(index);
      _entries.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WColors.background,
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
                        color: WColors.surfaceChip,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 18.sp,
                        color: WColors.foreground,
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
                              widget.list.emoji,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                inherit: false,
                                color: WColors.foreground,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '  ${widget.list.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: WColors.foreground,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${_entries.length} titles ranked',
                          style: TextStyle(
                            color: WColors.mutedSecondaryDeep,
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
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: widget.list.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: widget.list.accent.withValues(alpha: 0.15),
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
                          color: widget.list.accent.withValues(alpha: 0.8),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            widget.list.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.list.accent.withValues(alpha: 0.8),
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
                      color: widget.list.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Use \u2191\u2193 to reorder',
                          style: TextStyle(
                            color: widget.list.accent.withValues(alpha: 0.7),
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
                itemCount: _entries.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return _RankingEntryTile(
                    entry: entry,
                    rank: index + 1,
                    accent: widget.list.accent,
                    canMoveUp: index > 0,
                    canMoveDown: index < _entries.length - 1,
                    onMoveUp: () => _move(index, -1),
                    onMoveDown: () => _move(index, 1),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
        color: WColors.surfaceChip,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Row(
        children: [
          _Medal(rank: rank, color: accent),
          SizedBox(width: 8.w),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: WColors.backgroundAlt, width: 0.8),
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
                    color: WColors.foreground,
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
                      '\u2605 ${entry.rating}  \u00B7  ${entry.year}',
                      style: TextStyle(
                        color: WColors.mutedSecondary,
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
          color: enabled ? WColors.surface : null,
          borderRadius: BorderRadius.circular(8.r),
          border: enabled ? Border.all(color: WColors.borderStrong) : null,
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color:
              enabled ? WColors.mutedSecondary : WColors.mutedSecondaryHeader,
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
          color: WColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: WColors.borderStrong),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: WColors.mutedSecondaryDeep,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            Text(
              'Create New List',
              style: TextStyle(
                color: WColors.foreground,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Curate your perfect ranking',
              style: TextStyle(
                color: WColors.mutedSecondary,
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
                      ? WColors.primary.withValues(alpha: 0.9)
                      : WColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Center(
                  child: Text(
                    'Create List',
                    style: TextStyle(
                      color: canSubmit
                          ? WColors.foreground
                          : WColors.mutedSecondary,
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
    '\uD83C\uDFC6',
    '\u2764\uFE0F',
    '\uD83D\uDE80',
    '\u26E9\uFE0F',
    '\uD83D\uDCFA',
    '\uD83C\uDFAC',
    '\uD83E\uDD2F',
    '\uD83D\uDDA4',
    '\uD83D\uDC7B',
    '\uD83D\uDC8E',
    '\uD83D\uDD25',
    '\u2B50',
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
                  ? WColors.accentRed.withValues(alpha: 0.18)
                  : WColors.surfaceRaised,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? WColors.accentRed.withValues(alpha: 0.3)
                    : WColors.borderStrong,
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
        color: WColors.foreground,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      cursorHeight: 20.h,
      cursorColor: WColors.foreground,
      cursorWidth: 1,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: WColors.mutedSecondaryDeep,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: WColors.surfaceChip,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: WColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: WColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: WColors.border),
        ),
      ),
    );
  }
}

class RankingList {
  final String emoji;
  final String title;
  final String subtitle;
  final int count;
  final Color accent;
  final List<String> images;
  final List<RankingEntry> entries;

  const RankingList({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.accent,
    required this.images,
    required this.entries,
  });
}

class RankingEntry {
  final String title;
  final String year;
  final String type;
  final String rating;
  final String image;

  const RankingEntry({
    required this.title,
    required this.year,
    required this.type,
    required this.rating,
    required this.image,
  });
}
