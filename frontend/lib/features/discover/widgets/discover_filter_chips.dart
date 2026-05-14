import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

// ── Top-level filter chips (All / Movies / Anime / Series) ─────────────────
class DiscoverFilterChips extends StatefulWidget {
  const DiscoverFilterChips({super.key});

  @override
  State<DiscoverFilterChips> createState() => _DiscoverFilterChipsState();
}

class _DiscoverFilterChipsState extends State<DiscoverFilterChips> {
  int _selected = 0;

  final List<_FilterOption> _options = const [
    _FilterOption(label: 'All', icon: Icons.apps_rounded, isGlobe: true),
    _FilterOption(label: 'Movies', icon: Icons.movie_filter_outlined),
    _FilterOption(label: 'Anime', icon: Icons.animation_outlined),
    _FilterOption(label: 'Series', icon: Icons.live_tv_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Row(
        children: List.generate(_options.length, (i) {
          final opt = _options[i];
          final isSelected = i == _selected;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _TopFilterChip(
              label: opt.label,
              icon: opt.icon,
              isGlobe: opt.isGlobe,
              selected: isSelected,
              onTap: () => setState(() => _selected = i),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterOption {
  final String label;
  final IconData icon;
  final bool isGlobe;
  const _FilterOption({
    required this.label,
    required this.icon,
    this.isGlobe = false,
  });
}

class _TopFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isGlobe;
  final bool selected;
  final VoidCallback onTap;

  const _TopFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.isGlobe = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? WColors.primary : WColors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
          border: Border.all(
            color: selected ? WColors.primary : WColors.surfaceChipBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15.sp,
              color: selected ? Colors.white : WColors.mutedForeground,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : WColors.mutedSecondaryAlt,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Genre sub-filter chips (Action / Drama / Thriller / Sci-Fi / Horror) ───
class DiscoverGenreChips extends StatefulWidget {
  const DiscoverGenreChips({super.key});

  @override
  State<DiscoverGenreChips> createState() => _DiscoverGenreChipsState();
}

class _DiscoverGenreChipsState extends State<DiscoverGenreChips> {
  final List<String> _genres = const [
    'Action',
    'Drama',
    'Thriller',
    'Sci-Fi',
    'Horror',
    'Romance',
    'Comedy',
    'Mystery',
  ];

  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Row(
        children: List.generate(_genres.length, (i) {
          final isSelected = _selected.contains(i);
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => setState(() {
                if (isSelected) {
                  _selected.remove(i);
                } else {
                  _selected.add(i);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? WColors.primary.withValues(alpha: 0.15)
                      : WColors.surfaceChip.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                  border: Border.all(
                    color: isSelected
                        ? WColors.primary.withValues(alpha: 0.6)
                        : WColors.surfaceChipBorder,
                  ),
                ),
                child: Text(
                  _genres[i],
                  style: TextStyle(
                    color: isSelected
                        ? WColors.primary
                        : WColors.mutedSecondaryAlt,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
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
