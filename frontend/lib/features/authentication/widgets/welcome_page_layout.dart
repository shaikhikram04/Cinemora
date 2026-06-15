import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/constants/colors.dart';
import 'package:cinemora/core/themes/custom_theme/text_theme.dart';

class WelcomePageLayout extends StatelessWidget {
  final Widget visual;
  final String label;
  final String title;
  final String subtitle;
  final String primaryButton;
  final String? secondaryButton;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool isLoading;

  const WelcomePageLayout({
    super.key,
    required this.visual,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.primaryButton,
    required this.onPrimaryPressed,
    this.secondaryButton,
    this.onSecondaryPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 360.h, child: Center(child: visual)),
          const Spacer(),
          const SizedBox(height: WSizes.defaultSpace),
          Text(
            label,
            style: WTextTheme.label,
          ),
          const SizedBox(height: WSizes.sm),
          Text(
            title,
            style: WTextTheme.h1,
          ),
          const SizedBox(height: WSizes.md),
          Text(
            subtitle,
            style: WTextTheme.body.copyWith(fontSize: 14.sp),
          ),
          const SizedBox(height: WSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50.h),
                backgroundColor: WColors.primary,
                foregroundColor: WColors.primaryForeground,
                textStyle: WTextTheme.button.copyWith(fontSize: 16.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                shadowColor: WColors.primary.withAlpha(120),
                elevation: 2,
              ),
              onPressed: isLoading ? null : onPrimaryPressed,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(primaryButton),
                        const SizedBox(width: WSizes.sm),
                        Icon(Icons.arrow_forward, size: 20.sp),
                      ],
                    ),
            ),
          ),
          if (secondaryButton != null) ...[
            const SizedBox(height: WSizes.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(58.h),
                  side: const BorderSide(
                      color: Color.fromARGB(28, 255, 255, 255)),
                  foregroundColor: WColors.foreground,
                  textStyle: WTextTheme.button.copyWith(fontSize: 16.sp),
                  backgroundColor:
                      const Color.fromARGB(255, 58, 58, 61).withAlpha(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                onPressed: isLoading ? null : onSecondaryPressed,
                child: Text(secondaryButton!),
              ),
            ),
          ],
          const SizedBox(height: WSizes.lg),
        ],
      ),
    );
  }
}
