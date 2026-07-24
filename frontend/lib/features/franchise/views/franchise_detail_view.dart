import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/common/widgets/detail/detail_hero_shell.dart';
import 'package:cinemora/common/widgets/states/on_reconnect.dart';
import 'package:cinemora/common/widgets/states/w_error_state.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/cinema_type.dart';
import 'package:cinemora/core/models/library_entry_model.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/franchise/models/franchise_detail.dart';
import 'package:cinemora/features/franchise/repositories/franchise_repository.dart';
import 'package:cinemora/features/franchise/viewmodels/franchise_detail_cubit.dart';
import 'package:cinemora/features/franchise/viewmodels/franchise_detail_state.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';

class FranchiseDetailView extends StatelessWidget {
  final int collectionId;
  final String? name;
  final String? backdropUrl;

  const FranchiseDetailView({
    super.key,
    required this.collectionId,
    this.name,
    this.backdropUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FranchiseDetailCubit(
        context.read<FranchiseRepository>(),
        context.read<LibraryCubit>(),
        collectionId,
      ),
      child: _FranchiseDetailContent(
        fallbackName: name,
        fallbackBackdrop: backdropUrl,
      ),
    );
  }
}

class _FranchiseDetailContent extends StatelessWidget {
  final String? fallbackName;
  final String? fallbackBackdrop;

  const _FranchiseDetailContent({this.fallbackName, this.fallbackBackdrop});

  WatchStatus? _statusFor(List<LibraryEntryModel> entries, int movieId) {
    for (final entry in entries) {
      if (entry.tmdbId == movieId && entry.cinemaType == CinemaType.movie) {
        return entry.status;
      }
    }
    return null;
  }

  void _openMovie(BuildContext context, FranchiseMovieItem movie) {
    context.push(
      AppRoutes.movieDetails,
      extra: MovieRouteArgs(
        title: movie.title,
        image: movie.posterUrl,
        rating: movie.ratingDisplay,
        id: movie.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FranchiseDetailCubit, FranchiseDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        final libraryEntries = context.watch<LibraryCubit>().state.entries;

        if (state.status == FranchiseDetailStatus.failure) {
          return OnReconnect(
            onReconnect: () => context.read<FranchiseDetailCubit>().retry(),
            child: Scaffold(
              backgroundColor: context.colors.background,
              body: WErrorState.fullScreen(
                message: 'Could not load this franchise.',
                onRetry: () => context.read<FranchiseDetailCubit>().retry(),
              ),
            ),
          );
        }

        final heroBackdrop = detail?.backdropUrl.isNotEmpty == true
            ? detail!.backdropUrl
            : (fallbackBackdrop ?? '');

        return Scaffold(
          backgroundColor: context.colors.background,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailHeroShell(
                  imageUrl: heroBackdrop,
                  bottomContent: Text(
                    detail?.name ?? fallbackName ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: WSizes.screenPadding.w,
                  ),
                  child: state.status == FranchiseDetailStatus.loading
                      ? const _LoadingBody()
                      : _MoviesBody(
                          detail: detail!,
                          statusFor: (id) => _statusFor(libraryEntries, id),
                          onTap: (movie) => _openMovie(context, movie),
                          onBookmark: (movie, {required isWatchlisted}) =>
                              context
                                  .read<FranchiseDetailCubit>()
                                  .toggleWatchlist(
                                    movie,
                                    isWatchlisted: isWatchlisted,
                                  ),
                          isBulkAdding: state.isBulkAdding,
                          onAddAllToWatchlist: () {
                            final pending = detail.movies
                                .where((m) =>
                                    _statusFor(libraryEntries, m.id) == null)
                                .toList();
                            context
                                .read<FranchiseDetailCubit>()
                                .addAllToWatchlist(pending);
                          },
                        ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoviesBody extends StatelessWidget {
  final FranchiseDetail detail;
  final WatchStatus? Function(int movieId) statusFor;
  final ValueChanged<FranchiseMovieItem> onTap;
  final void Function(FranchiseMovieItem movie, {required bool isWatchlisted})
      onBookmark;
  final bool isBulkAdding;
  final VoidCallback onAddAllToWatchlist;

  const _MoviesBody({
    required this.detail,
    required this.statusFor,
    required this.onTap,
    required this.onBookmark,
    required this.isBulkAdding,
    required this.onAddAllToWatchlist,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        detail.movies.where((m) => statusFor(m.id) == null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.overview.isNotEmpty) ...[
          Text(
            detail.overview,
            style: TextStyle(
              color: context.colors.mutedForeground,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${detail.movies.length} Movie${detail.movies.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (pendingCount > 0)
              _AddAllButton(
                isLoading: isBulkAdding,
                onTap: onAddAllToWatchlist,
              ),
          ],
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: WSizes.imageCarouselHeight.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: detail.movies.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, i) {
              final movie = detail.movies[i];
              return VerticalPosterBookmarkCard(
                title: movie.title,
                rating: movie.ratingDisplay,
                image: movie.posterUrl,
                width: WSizes.posterImageWidth.w,
                imageHeight: WSizes.posterImageHeight.h,
                cinemaType: CinemaType.movie,
                year: movie.year,
                watchStatus: statusFor(movie.id),
                onTap: () => onTap(movie),
                onBookmark: () => onBookmark(
                  movie,
                  isWatchlisted: statusFor(movie.id) == WatchStatus.watchlist,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddAllButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _AddAllButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: isLoading ? 0.6 : 1),
          borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 12.sp,
                height: 12.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(Icons.bookmark_add_rounded,
                  color: Colors.white, size: 14.sp),
            SizedBox(width: 6.w),
            Text(
              isLoading ? 'Adding…' : 'Add All to Watchlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: CircularProgressIndicator(color: context.colors.primary),
      ),
    );
  }
}
