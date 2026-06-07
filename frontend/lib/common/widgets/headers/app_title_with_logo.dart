import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';

class AppTitleWithLogo extends StatelessWidget {
  const AppTitleWithLogo({super.key, this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: WColors.primary,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
        const SizedBox(width: WSizes.sm),
        const Text(
          'Watchary',
          style: TextStyle(
            color: WColors.foreground,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            height: 2.4,
          ),
        ),
      ],
    );
  }
}
