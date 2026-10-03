import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrailerButton extends StatelessWidget {
  final VoidCallback onTap;

  const TrailerButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foregroundColor = colors.primaryForeground;
    final borderRadius = BorderRadius.circular(AppSizes.radius16.r);

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.accentRed, colors.accentRedDeep],
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
          ),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: colors.accentRed.withValues(alpha: 0.38),
              blurRadius: AppSizes.radius10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            splashColor: foregroundColor.withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.buttonHorizontalPadding,
                vertical: AppSizes.buttonVerticalPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: foregroundColor,
                    size: AppSizes.icon22.sp,
                  ),
                  SizedBox(width: AppSizes.space10.w),
                  Text(
                    'WATCH TRAILER',
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: AppSizes.fontSize13.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
