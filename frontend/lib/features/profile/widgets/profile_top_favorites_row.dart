import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/profile/widgets/profile_shared.dart';

/// Horizontal carousel of the user's highest-rated watched titles.
class ProfileTopFavoritesRow extends StatelessWidget {
  final List<LibraryEntryModel> entries;
  final int watchedCount;
  final bool isLoading;

  const ProfileTopFavoritesRow({
    super.key,
    required this.entries,
    required this.watchedCount,
    required this.isLoading,
  });

  void _onSeeAll(BuildContext context) {
    context.read<LibraryCubit>().selectStatus('Watched');
    context.read<LibraryCubit>().selectSort('Highest rated');
    context.go(AppRoutes.library);
  }

  void _openDetail(BuildContext context, LibraryEntryModel entry) {
    if (entry.cinemaType == CinemaType.movie) {
      context.push(
        AppRoutes.movieDetails,
        extra: MovieRouteArgs(
          title: entry.title,
          image: entry.posterUrl,
          rating: entry.tmdbRating?.toStringAsFixed(1) ?? '—',
          id: entry.tmdbId,
        ),
      );
    } else {
      final focusSeason =
          entry.seasons.length == 1 ? entry.seasons.first.seasonNumber : null;
      context.push(
        AppRoutes.seriesDetails,
        extra: SeriesRouteArgs(
          title: entry.title,
          image: entry.posterUrl,
          rating: entry.tmdbRating?.toStringAsFixed(1) ?? '—',
          id: entry.tmdbId,
          source: entry.cinemaType == CinemaType.anime ? 'jikan' : 'tmdb',
          focusSeason: focusSeason,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: WSizes.imageCarouselHeight.h,
        child: const Center(child: ProfileLoadingSpinner()),
      );
    }

    if (entries.isEmpty) {
      return Container(
        height: 80.h,
        alignment: Alignment.center,
        child: Text(
          'Rate watched titles to see your top favorites.',
          style:
              TextStyle(color: context.colors.mutedSecondary, fontSize: 13.sp),
        ),
      );
    }

    final showSeeAll = watchedCount > 5;
    final itemCount = entries.length + (showSeeAll ? 1 : 0);

    return SizedBox(
      height: WSizes.imageCarouselHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (showSeeAll && index == entries.length) {
            return _SeeAllFavoritesCard(
              watchedCount: watchedCount,
              onTap: () => _onSeeAll(context),
            );
          }
          final entry = entries[index];
          return VerticalPosterBookmarkCard(
            image: entry.posterUrl,
            width: WSizes.posterImageWidth,
            imageHeight: WSizes.posterImageHeight,
            title: entry.title,
            rating: (entry.userRating ?? 0).toStringAsFixed(1),
            cinemaType: entry.cinemaType,
            year: entry.releaseYear ?? '',
            watchStatus: entry.status,
            onTap: () => _openDetail(context, entry),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
      ),
    );
  }
}

class _SeeAllFavoritesCard extends StatelessWidget {
  final int watchedCount;
  final VoidCallback onTap;

  const _SeeAllFavoritesCard({
    required this.watchedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GestureDetector(
        onTap: onTap,
        child: Align(
          alignment: Alignment.topCenter,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        context.colors.accentRed,
                        context.colors.accentRedAlt,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: context.colors.primaryForeground,
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'See all',
                  style: TextStyle(
                    color: context.colors.foreground,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
