import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';

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
            label: 'Search',
            icon: Icons.search_rounded,
            selected: currentIndex == 1,
            onTap: () => onChanged(1),
          ),
          _NavItem(
            label: 'Watchlist',
            icon: Icons.bookmark_border_rounded,
            selected: currentIndex == 2,
            onTap: () => onChanged(2),
          ),
          _NavItem(
            label: 'Profile',
            icon: Icons.person_outline_rounded,
            selected: currentIndex == 3,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = WColors.accentRed;
    final inactiveColor = WColors.mutedSecondaryHeader;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: selected ? activeColor : inactiveColor,
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
      ),
    );
  }
}
