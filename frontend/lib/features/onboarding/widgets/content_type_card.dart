import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class ContentTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ContentTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              color: const Color(0xBB000000),
              colorBlendMode: BlendMode.multiply,
              errorBuilder: (_, __, ___) =>
                  ColoredBox(color: context.colors.surfaceRaised),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xF0141418)],
                  stops: [0.15, 1.0],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              color: isSelected
                  ? context.colors.primary.withAlpha(50)
                  : Colors.transparent,
            ),
            Padding(
              padding: EdgeInsets.all(WSizes.md.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
                      color: isSelected
                          ? context.colors.primary.withAlpha(60)
                          : Colors.white.withAlpha(18),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: Center(
                      child: IconTheme(
                        data: IconThemeData(
                          color: isSelected
                              ? Colors.white
                              : context.colors.mutedSecondaryVibe,
                        ),
                        child: icon,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(160),
                      fontSize: 10.sp,
                      height: 1.3,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary.withAlpha(220)
                        : Colors.white.withAlpha(20),
                    width: isSelected ? 1.5 : 1,
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
