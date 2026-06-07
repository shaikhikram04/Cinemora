import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class SettingsTopBar extends StatelessWidget {
  final String title;

  const SettingsTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          WSizes.screenPadding.w, 12.h, WSizes.screenPadding.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: WColors.surfaceRaised.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: WColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: WColors.mutedSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: WColors.foreground,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
