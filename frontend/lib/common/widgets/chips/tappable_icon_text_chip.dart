import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/icons/app_icon.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class TappableIconTextChip extends StatelessWidget {
  /// Pass exactly one of [icon] (a Material glyph) or [iconAsset] (a custom
  /// [AppIcons] asset); both tint identically to the chip's selected state.
  const TappableIconTextChip({
    super.key,
    required this.onTap,
    required this.selected,
    required this.label,
    this.icon,
    this.iconAsset,
    this.iconSize = 15,
    this.textSize = 13,
  }) : assert((icon == null) != (iconAsset == null),
            'Provide either icon or iconAsset, not both');

  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;
  final String? iconAsset;
  final String label;
  final double iconSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? context.colors.primary : context.colors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
          border: Border.all(
            color: selected
                ? context.colors.primary
                : context.colors.surfaceChipBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconAsset != null)
              AppIcon(
                iconAsset!,
                size: iconSize.sp,
                color: selected ? Colors.white : context.colors.mutedForeground,
              )
            else
              Icon(
                icon,
                size: iconSize.sp,
                color: selected ? Colors.white : context.colors.mutedForeground,
              ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color:
                    selected ? Colors.white : context.colors.mutedSecondaryAlt,
                fontSize: textSize.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
