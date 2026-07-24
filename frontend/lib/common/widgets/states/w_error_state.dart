import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

/// The one place a failed fetch is drawn. Replaces five near-identical
/// wifi-off + Retry blocks that had drifted apart in icon, size and copy.
///
/// Two shapes: [WErrorState.fullScreen] centres itself in whatever space it is
/// given, [WErrorState.card] draws a bordered surface for slotting into a feed
/// where the surrounding layout should stay intact.
class WErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  /// Card variant only — matches the slot the widget is standing in for.
  final double? height;
  final bool _isCard;

  const WErrorState.fullScreen({
    super.key,
    this.message,
    this.onRetry,
  })  : height = null,
        _isCard = false;

  const WErrorState.card({
    super.key,
    this.message,
    this.onRetry,
    this.height,
  }) : _isCard = true;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: (_isCard ? 36 : 48).sp,
          color: context.colors.mutedForeground,
        ),
        SizedBox(height: _isCard ? 12.h : 16.h),
        Text(
          message ?? 'Something went wrong.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _isCard
                ? context.colors.mutedForeground
                : context.colors.foreground,
            fontSize: _isCard ? 14.sp : 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onRetry != null) ...[
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (!_isCard) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: content,
        ),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: context.colors.surfaceBorder),
      ),
      child: Center(child: content),
    );
  }
}
