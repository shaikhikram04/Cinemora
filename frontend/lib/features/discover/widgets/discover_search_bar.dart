import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';

class DiscoverSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback? onFocusGained;

  const DiscoverSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.onFocusGained,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48.h,
      decoration: BoxDecoration(
        color: context.colors.surfaceChip,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.colors.surfaceChipBorder, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 14.w),
          Icon(
            Icons.search_rounded,
            color: context.colors.mutedForeground,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onTap: onFocusGained,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              cursorWidth: 1.w,
              cursorColor: context.colors.foreground,
              decoration: InputDecoration(
                hintText: 'Movies, anime, series, genres…',
                hintStyle: TextStyle(
                  color: context.colors.mutedForeground,
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
                    color: context.colors.mutedForeground,
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
