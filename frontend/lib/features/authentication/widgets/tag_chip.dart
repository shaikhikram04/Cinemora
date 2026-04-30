import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TagChip extends StatelessWidget {
  final String text;
  final Color background;
  final Color border;
  final Color textColor;
  final IconData icon;

  const TagChip({
    super.key,
    required this.text,
    required this.background,
    required this.border,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
