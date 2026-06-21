import 'package:cinemora/core/models/cinema_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/home/widgets/discover_chip.dart';

class DetailRecommendationsSection extends StatefulWidget {
  const DetailRecommendationsSection({super.key});

  @override
  State<DetailRecommendationsSection> createState() =>
      _DetailRecommendationsSectionState();
}

class _DetailRecommendationsSectionState
    extends State<DetailRecommendationsSection> {
  int _selectedTab = 0;

  static const _tabs = [
    'Similar Titles',
    'Same Director',
    'Same Genre',
    'Trending Now',
  ];

  static const _items = [
    {
      'title': 'Breaking Bad',
      'rating': '9.5',
      'year': '2008',
      'image':
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'The Last of Us',
      'rating': '8.8',
      'year': '2023',
      'image':
          'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Interstellar',
      'rating': '8.7',
      'year': '2014',
      'image':
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=600&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DISCOVER',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.accentRed,
            letterSpacing: 1.2,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Because You Loved This',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: context.colors.foreground,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Viewing all recommendations...')),
              ),
              child: Text(
                'See all >',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: DiscoverChip(
                    label: _tabs[i],
                    selected: _selectedTab == i,
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: WSizes.imageCarouselHeight.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, i) {
              return VerticalPosterBookmarkCard(
                title: _items[i]['title']!,
                rating: _items[i]['rating']!,
                image: _items[i]['image']!,
                width: WSizes.posterImageWidth.w,
                imageHeight: WSizes.posterImageHeight.h,
                cinemaType: CinemaType.tv,
                year: _items[i]['year']!,
              );
            },
          ),
        ),
      ],
    );
  }
}
