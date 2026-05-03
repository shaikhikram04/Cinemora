import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class WMediaProgressCard extends StatelessWidget {
  final String image;
  final String title;
  final String progressLabel;
  final double progress;
  final double width;
  final VoidCallback? onTap;

  const WMediaProgressCard({
    super.key,
    required this.image,
    required this.title,
    required this.progressLabel,
    required this.progress,
    required this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: WColors.surfaceRaised2),
        boxShadow: const [
          BoxShadow(
            color: WColors.shadowMedium,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: WColors.surfaceMuted,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.24),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      height: 0.95,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3.h,
                      backgroundColor: Colors.white.withValues(alpha: 0.26),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        WColors.accentRed,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    progressLabel,
                    style: TextStyle(
                      color: WColors.mutedSecondarySoft,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}