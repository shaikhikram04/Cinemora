import 'package:cinemora/core/models/cinema_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/home/models/similar_item.dart';
import 'package:cinemora/features/home/repositories/home_repository.dart';

class DetailRecommendationsSection extends StatefulWidget {
  final CinemaType cinemaType;
  final int? sourceId;

  const DetailRecommendationsSection({
    super.key,
    required this.cinemaType,
    required this.sourceId,
  });

  @override
  State<DetailRecommendationsSection> createState() =>
      _DetailRecommendationsSectionState();
}

class _DetailRecommendationsSectionState
    extends State<DetailRecommendationsSection> {
  late Future<List<SimilarItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant DetailRecommendationsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceId != widget.sourceId ||
        oldWidget.cinemaType != widget.cinemaType) {
      setState(() => _future = _load());
    }
  }

  Future<List<SimilarItem>> _load() async {
    final id = widget.sourceId;
    if (id == null) return const [];
    try {
      return await context.read<HomeRepository>().fetchSimilar(
            widget.cinemaType,
            id,
          );
    } catch (_) {
      return const [];
    }
  }

  void _navigate(BuildContext context, SimilarItem item) {
    if (item.cinemaType == 'movie') {
      context.push(
        AppRoutes.movieDetails,
        extra: MovieRouteArgs(
          title: item.title,
          image: item.posterUrl,
          rating: item.ratingDisplay,
          id: item.sourceId,
        ),
      );
    } else {
      context.push(
        AppRoutes.seriesDetails,
        extra: SeriesRouteArgs(
          title: item.title,
          image: item.posterUrl,
          rating: item.ratingDisplay,
          id: item.sourceId,
          source: item.source,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SimilarItem>>(
      future: _future,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final items = snapshot.data ?? const [];
        if (!isLoading && items.isEmpty) return const SizedBox.shrink();

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
            Text(
              'More Like This',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.colors.foreground,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: WSizes.imageCarouselHeight.h,
              child: isLoading
                  ? _LoadingRow()
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return VerticalPosterBookmarkCard(
                          title: item.title,
                          rating: item.ratingDisplay,
                          image: item.posterUrl,
                          width: WSizes.posterImageWidth.w,
                          imageHeight: WSizes.posterImageHeight.h,
                          cinemaType: CinemaType.fromJson(item.cinemaType),
                          year: item.year ?? '',
                          onTap: () => _navigate(context, item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _LoadingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(width: 12.w),
      itemBuilder: (context, i) => Container(
        width: WSizes.posterImageWidth.w,
        decoration: BoxDecoration(
          color: context.colors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusXxl.r),
        ),
      ),
    );
  }
}
