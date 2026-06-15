import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/colors.dart';

class DiscoverSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const DiscoverSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48.h,
      decoration: BoxDecoration(
        color: WColors.surfaceChip,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: WColors.surfaceChipBorder, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          Icon(
            Icons.search_rounded,
            color: WColors.mutedForeground,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: TextStyle(
                color: WColors.foreground,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              cursorWidth: 1.w,
              cursorColor: WColors.foreground,
              decoration: InputDecoration(
                hintText: 'Movies, anime, series, genres…',
                hintStyle: TextStyle(
                  color: WColors.mutedForeground,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
                isDense: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Icon(
                    Icons.close_rounded,
                    color: WColors.mutedForeground,
                    size: 18.sp,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
