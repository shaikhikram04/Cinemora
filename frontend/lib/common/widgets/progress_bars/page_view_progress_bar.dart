import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/headers/branding_hero.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class PageViewProgressBar extends StatelessWidget {
  const PageViewProgressBar({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.showBackButton = false,
    this.onBack,
    this.onSkip,
  });

  final int totalPages;
  final int currentPage;
  final bool showBackButton;
  final VoidCallback? onBack;

  /// When provided, a Skip chip is shown in the header (hidden on the last page).
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: WSizes.sm),
        _buildProgressDots(context, currentPage),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WSizes.md),
      child: Row(
        children: [
          if (showBackButton)
            if (currentPage > 0) ...[
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceRaised,
                    border: Border.all(color: context.colors.border),
                    borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: context.colors.foreground,
                    size: 18.sp,
                  ),
                ),
              ),
            ] else
              SizedBox(width: 36.w),
          Expanded(
            child: BrandHero(
              iconSize: 32.w,
              fontSize: 20.sp,
              centered: showBackButton,
            ),
          ),
          if (onSkip != null && currentPage < totalPages - 1)
            GestureDetector(
              onTap: onSkip,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                  border: Border.all(color: context.colors.border),
                  color: context.colors.card.withValues(alpha: 0.5),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.colors.mutedForeground,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressDots(BuildContext context, int currentPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WSizes.md),
      child: Row(
        children: List.generate(totalPages, (index) {
          final isActive = index == currentPage;
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              height: 3.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99.r),
                color: isActive ? context.colors.primary : Colors.white.withAlpha(70),
              ),
            ),
          );
        }),
      ),
    );
  }
}
