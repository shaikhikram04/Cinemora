import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';

Future<void> showUnmarkWatchedDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
  double userRating = 0,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.78),
    transitionDuration: const Duration(milliseconds: 320),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.86, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        ),
        child: child,
      ),
    ),
    pageBuilder: (ctx, _, __) => Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        child:
            _UnmarkWatchedDialog(onConfirm: onConfirm, userRating: userRating),
      ),
    ),
  );
}

class _UnmarkWatchedDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final double userRating;

  const _UnmarkWatchedDialog({required this.onConfirm, this.userRating = 0});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasRating = userRating > 0;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232329), Color(0xFF19191F)],
          ),
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: colors.border, width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 64,
              offset: const Offset(0, 28),
            ),
            BoxShadow(
              color: colors.accentRed.withValues(alpha: 0.07),
              blurRadius: 64,
              spreadRadius: 6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 38.h, 24.w, 28.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Remove from\nWatched?',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: colors.foreground,
                        fontFamily: 'Inter',
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'This will remove it from your library entirely.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colors.mutedForeground,
                        fontFamily: 'Inter',
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (hasRating) ...[
                      SizedBox(height: 20.h),
                      _RatingLossChip(rating: userRating, colors: colors),
                    ],
                    SizedBox(height: 34.h),
                    _RemoveButton(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: colors.mutedForeground,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingLossChip extends StatelessWidget {
  final double rating;
  final AppColors colors;

  const _RatingLossChip({required this.rating, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
            color: colors.warning.withValues(alpha: 0.22), width: 0.8),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 16.sp, color: colors.warning),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'Inter',
                  height: 1.45,
                  color: colors.mutedForeground,
                ),
                children: [
                  const TextSpan(text: 'Your '),
                  TextSpan(
                    text: '${rating.toStringAsFixed(1)}★ rating',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.warning,
                    ),
                  ),
                  const TextSpan(text: ' will also be lost.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE84B57), Color(0xFFBF2D38)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'Yes, Remove',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFamily: 'Inter',
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
