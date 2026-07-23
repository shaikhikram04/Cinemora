import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/chips/tappable_icon_text_chip.dart';
import 'package:cinemora/common/widgets/chips/tappable_text_chip.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/constants/assets_path.dart';

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
    _FilterOption(label: 'Movies', iconAsset: AppIcons.movie),
    _FilterOption(label: 'Anime', iconAsset: AppIcons.anime),
    _FilterOption(label: 'Series', iconAsset: AppIcons.tvShow),
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
              iconAsset: opt.iconAsset,
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
  final IconData? icon;
  final String? iconAsset;
  final bool isGlobe;
  const _FilterOption({
    required this.label,
    this.icon,
    this.iconAsset,
    this.isGlobe = false,
  });
}

class _TopFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? iconAsset;
  final bool isGlobe;
  final bool selected;
  final VoidCallback onTap;

  const _TopFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconAsset,
    this.isGlobe = false,
  });

  @override
  Widget build(BuildContext context) {
    return TappableIconTextChip(
      onTap: onTap,
      selected: selected,
      icon: icon,
      iconAsset: iconAsset,
      iconSize: iconAsset != null ? 20 : 15,
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
