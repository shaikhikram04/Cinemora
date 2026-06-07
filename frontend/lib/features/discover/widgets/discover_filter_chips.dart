import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/common/widgets/chips/tappable_icon_text_chip.dart';
import 'package:watchary/common/widgets/chips/tappable_text_chip.dart';
import 'package:watchary/core/constants/sizes.dart';

// ── Top-level filter chips (All / Movies / Anime / Series) ─────────────────
class DiscoverFilterChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const DiscoverFilterChips({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _options = [
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
          final isSelected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _TopFilterChip(
              label: opt.label,
              icon: opt.icon,
              isGlobe: opt.isGlobe,
              selected: isSelected,
              onTap: () => onSelect(i),
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
    return TappableIconTextChip(
      onTap: onTap,
      selected: selected,
      icon: icon,
      label: label,
    );
  }
}

// ── Genre sub-filter chips (Action / Drama / Thriller / Sci-Fi / Horror) ───
class DiscoverGenreChips extends StatelessWidget {
  final List<int> selectedIndices;
  final ValueChanged<int> onToggle;

  const DiscoverGenreChips({
    super.key,
    required this.selectedIndices,
    required this.onToggle,
  });

  static const _genres = [
    'Action',
    'Drama',
    'Thriller',
    'Sci-Fi',
    'Horror',
    'Romance',
    'Comedy',
    'Mystery',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Row(
        children: List.generate(_genres.length, (i) {
          final isSelected = selectedIndices.contains(i);
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: TappableTextChip(
              onToggle: () => onToggle(i),
              isSelected: isSelected,
              text: _genres[i],
            ),
          );
        }),
      ),
    );
  }
}
