import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/containers/circular_avatar.dart';
import 'package:cinemora/common/widgets/shimmer/shimmer.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/home/models/tmdb_detail.dart';

// Row geometry: the strip's height is the avatar plus its text lines, so crew
// gets a taller box than cast for its two-line role. The label width is what
// keeps a wrapped name from crowding its neighbour.
const double _rowHeight = 145.0;
const double _labelWidth = 74.0;

// Skeleton shapes stand in for the loaded card, so they carry their own
// slightly smaller placeholder geometry.
const double _skeletonAvatarSize = 64.0;
const double _skeletonNameWidth = 60.0;
const double _skeletonRoleWidth = 44.0;
const double _skeletonLineHeight = 12.0;
const double _skeletonLineRadius = 6.0;

/// One avatar tile in a [CreditsSection] — whatever the source model, the strip
/// only needs a name, a secondary line and an optional photo.
class CreditPerson {
  final String name;
  final String subtitle;
  final String? imageUrl;

  const CreditPerson({
    required this.name,
    required this.subtitle,
    this.imageUrl,
  });
}

/// Horizontally scrolling strip of circular portraits under a section heading,
/// shared by the cast and crew blocks of the detail screens. Use the [cast] and
/// [crew] constructors rather than the raw one — they carry the per-variant
/// heading, palette and row height.
class CreditsSection extends StatelessWidget {
  final String title;
  final List<CreditPerson>? people;
  final bool isLoading;

  /// Cycled through for people with no photo, so adjacent initials tiles don't
  /// repeat a color.
  final List<Color> Function(AppColors colors) palette;

  /// Crew roles ("Executive Producer") wrap where character names rarely do.
  final int skeletonCount;

  const CreditsSection({
    super.key,
    required this.title,
    required this.people,
    required this.palette,
    this.isLoading = false,
    this.skeletonCount = 6,
  });

  CreditsSection.cast({
    super.key,
    required List<CastMember>? cast,
    this.isLoading = false,
  })  : title = 'Cast',
        people = cast
            ?.map((m) => CreditPerson(
                  name: m.name,
                  subtitle: m.character,
                  imageUrl: m.profileUrl,
                ))
            .toList(),
        palette = _castPalette,
        skeletonCount = 6;

  CreditsSection.crew({
    super.key,
    required List<CrewMember>? crew,
    this.isLoading = false,
  })  : title = 'Creators',
        people = crew
            ?.map((m) => CreditPerson(
                  name: m.name,
                  subtitle: m.role,
                  imageUrl: m.profileUrl,
                ))
            .toList(),
        palette = _crewPalette,
        skeletonCount = 3;

  /// Cast falls back to the accent palette, theme-resolved so the tiles stay in
  /// palette in light mode too.
  static List<Color> _castPalette(AppColors colors) => [
        colors.accentBlueMuted,
        colors.accentPink,
        colors.warning,
        colors.accentRed,
        colors.mutedSecondaryAlt,
      ];

  /// Crew falls back to its own muted set, deliberately quieter than the cast's
  /// so the two strips stay visually distinct. These have no theme equivalents,
  /// and sit under white initials in both themes, so they are fixed values.
  static List<Color> _crewPalette(AppColors colors) => const [
        Color(0xFF4A6FA5),
        Color(0xFF6B8F71),
        Color(0xFF9B6B9B),
        Color(0xFF8B7355),
        Color(0xFF5B8FA8),
      ];

  @override
  Widget build(BuildContext context) {
    final members = people ?? const [];
    if (!isLoading && members.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final fallbackColors = palette(colors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: AppSizes.fontSize16.sp,
            fontWeight: FontWeight.bold,
            color: colors.foreground,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: AppSizes.space12.h),
        SizedBox(
          height: _rowHeight.h,
          child: isLoading && members.isEmpty
              ? _CreditsSkeletons(itemCount: skeletonCount)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) => _CreditTile(
                    person: members[index],
                    fallbackColor:
                        fallbackColors[index % fallbackColors.length],
                  ),
                ),
        ),
      ],
    );
  }
}

class _CreditTile extends StatelessWidget {
  const _CreditTile({
    required this.person,
    required this.fallbackColor,
  });

  final CreditPerson person;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(right: AppSizes.space16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCircularAvatar(
            imageUrl: person.imageUrl,
            initial: person.name,
            fallbackColor: fallbackColor,
          ),
          SizedBox(height: AppSizes.space8.h),
          SizedBox(
            width: _labelWidth.w,
            child: Text(
              person.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppSizes.fontSize12.sp,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(height: AppSizes.space4.h),
          SizedBox(
            width: _labelWidth.w,
            child: Text(
              person.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppSizes.fontSize10.sp,
                color: colors.mutedForeground,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditsSkeletons extends StatelessWidget {
  const _CreditsSkeletons({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(right: AppSizes.space16.w),
          child: Column(
            children: [
              Container(
                width: _skeletonAvatarSize.w,
                height: _skeletonAvatarSize.h,
                // Shimmer masks the child's shapes with its own base and
                // highlight colors, so these placeholders stay plain white
                // rather than taking a theme color.
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSizes.space8.h),
              _SkeletonLine(width: _skeletonNameWidth.w),
              SizedBox(height: AppSizes.space4.h),
              _SkeletonLine(width: _skeletonRoleWidth.w),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;

  const _SkeletonLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _skeletonLineHeight.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_skeletonLineRadius.r),
      ),
    );
  }
}
