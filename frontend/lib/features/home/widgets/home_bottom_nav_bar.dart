import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/common/widgets/icons/app_icon.dart';
import 'package:cinemora/core/constants/assets_path.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          _NavItem(
            label: 'Home',
            icon: Icons.home_rounded,
            selected: currentIndex == 0,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            label: 'Discover',
            icon: Icons.search_rounded,
            selected: currentIndex == 1,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            label: 'Library',
            icon: Icons.bookmark_border_rounded,
            selected: currentIndex == 2,
            onTap: () => onChanged(2),
          ),
          _NavItem(
            label: 'Rankings',
            iconAsset: AppIcons.ranking,
            selected: currentIndex == 3,
            onTap: () => onChanged(3),
          ),
          _NavItem(
            label: 'Profile',
            icon: Icons.person_outline_rounded,
            selected: currentIndex == 4,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? iconAsset;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconAsset,
  }) : assert((icon == null) != (iconAsset == null),
            'Provide either icon or iconAsset, not both');

  @override
  Widget build(BuildContext context) {
    final activeColor = context.colors.accentRed;
    final inactiveColor = context.colors.mutedSecondaryHeader;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              margin: EdgeInsets.symmetric(horizontal: 8.w).copyWith(top: 4.h),
              width: double.infinity,
              decoration: BoxDecoration(
                color: selected
                    ? activeColor.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconAsset != null)
                    AppIcon(
                      iconAsset!,
                      size: 23.sp,
                      color: selected ? activeColor : inactiveColor,
                    )
                  else
                    Icon(
                      icon,
                      size: 22.sp,
                      color: selected ? activeColor : inactiveColor,
                    ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: selected ? activeColor : inactiveColor,
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
