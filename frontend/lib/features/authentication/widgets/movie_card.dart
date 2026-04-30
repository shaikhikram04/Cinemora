import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';

class MovieCard extends StatelessWidget {
  final String image;
  final double width;
  final double height;
  final String? title;
  final String? rating;
  final double radius;

  const MovieCard({
    super.key,
    required this.image,
    required this.width,
    required this.height,
    this.title,
    this.rating,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: WColors.border),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              WColors.background.withAlpha(120),
              WColors.background.withAlpha(220),
            ],
          ),
        ),
        padding: EdgeInsets.all(8.w),
        alignment: Alignment.bottomLeft,
        child: title == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '★ $rating',
                    style: TextStyle(
                      color: WColors.tertiary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
