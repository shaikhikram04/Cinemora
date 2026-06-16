import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/assets_path.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/themes/custom_theme/text_theme.dart';

class BrandHero extends StatelessWidget {
  const BrandHero({
    super.key,
    required this.iconSize,
    required this.fontSize,
    this.spacing = WSizes.sm,
    this.centered = false,
  });

  final double iconSize;
  final double fontSize;
  final double spacing;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment:
            centered ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Image.asset(
            AppIcons.cinemoraTransparent,
            width: iconSize.w,
            height: iconSize.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: spacing.w),
          Text(
            'Cinemora',
            style: WTextTheme.of(context).h1.copyWith(fontSize: fontSize.sp),
          ),
          SizedBox(width: WSizes.md.w),
        ],
      ),
    );
  }
}
