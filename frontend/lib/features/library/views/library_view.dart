import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/library/viewmodels/library_state.dart';
import 'package:cinemora/features/library/widgets/library_list_item.dart';
import 'package:cinemora/core/models/watch_status.dart';
import 'package:cinemora/features/library/widgets/library_stats_card.dart';
import 'package:cinemora/features/library/widgets/shuffle_pick_sheet.dart';
import 'package:cinemora/common/widgets/icons/app_icon.dart';
import 'package:cinemora/core/constants/assets_path.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LibraryCubit, LibraryState>(
      listenWhen: (prev, curr) =>
          curr.mutationError != null &&
          curr.mutationError != prev.mutationError,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.mutationError!)),
        );
        context.read<LibraryCubit>().clearMutationError();
      },
      builder: (context, state) {
        final cubit = context.read<LibraryCubit>();

        // ── Loading ──────────────────────────────────────────────────
        if (state.status == LibraryStatus.loading ||
            state.status == LibraryStatus.initial) {
          return Container(
            color: context.colors.background,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // ── Error ────────────────────────────────────────────────────
        if (state.status == LibraryStatus.error) {
          return Container(
            color: context.colors.background,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 48.sp, color: context.colors.mutedSecondary),
                    SizedBox(height: 16.h),
                    Text(
                      state.errorMessage ?? 'Failed to load library.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colors.mutedSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: cubit.loadData,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: context.colors.accentRed,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Loaded ───────────────────────────────────────────────────
        final items = cubit.filteredEntries;

        return Container(
          color: context.colors.background,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(WSizes.screenPadding.w, 16.h,
                        WSizes.screenPadding.w, 0),
                    child: Builder(builder: (context) {
                      final watchlist = state.entries
                          .where((e) => e.status == WatchStatus.watchlist)
                          .toList();
                      return _LibraryHeader(
                        totalTitles: state.entries.length,
                        onShuffle: watchlist.isEmpty
                            ? null
                            : () => showShufflePick(context, watchlist),
                      );
                    }),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(WSizes.screenPadding.w, 16.h,
                        WSizes.screenPadding.w, 0),
                    child: LibraryStatsCard(
                      watchedCount: cubit.watchedCount,
                      totalEntries: cubit.totalEntries,
                      moviesWatched: cubit.moviesWatched,
                      seriesWatched: cubit.seriesWatched,
                      animeWatched: cubit.animeWatched,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(WSizes.screenPadding.w, 16.h,
                        WSizes.screenPadding.w, 0),
                    child: _LibrarySearchBar(
                      controller: _searchController,
                      onChanged: cubit.updateSearch,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 14.h),
                    child: _TypeFilterRow(
                      types: LibraryCubit.types,
                      selected: state.selectedType,
                      onSelected: cubit.selectType,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(WSizes.screenPadding.w, 10.h,
                        WSizes.screenPadding.w, 0),
                    child: _StatusFilterRow(
                      statuses: LibraryCubit.statuses,
                      counts: cubit.statusCounts,
                      selected: state.selectedStatus,
                      onSelected: cubit.selectStatus,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(WSizes.screenPadding.w, 16.h,
                        WSizes.screenPadding.w, 12.h),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${items.length}',
                                style:
                                    TextStyle(color: context.colors.foreground),
                              ),
                              const TextSpan(text: ' results'),
                            ],
                          ),
                          style: TextStyle(
                            color: context.colors.mutedSecondary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        _SortButton(
                          label: state.selectedSort,
                          onTap: cubit.toggleSortPanel,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.isSortOpen)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(WSizes.screenPadding.w, 0,
                          WSizes.screenPadding.w, 12.h),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _SortPanel(
                          selected: state.selectedSort,
                          options: LibraryCubit.sortOptions,
                          onSelected: cubit.selectSort,
                        ),
                      ),
                    ),
                  ),

                // ── Empty state or list ───────────────────────────────
                if (items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      status: state.selectedStatus,
                      type: state.selectedType,
                      hasSearch: state.searchQuery.isNotEmpty,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                        horizontal: WSizes.screenPadding.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = items[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: LibraryListItem(
                              entry: entry,
                              showWatchCount: state.selectedStatus == 'Watched',
                              fromWatchedTab: state.selectedStatus == 'Watched',
                            ),
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 40.h)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _LibraryHeader extends StatelessWidget {
  final int totalTitles;
  final VoidCallback? onShuffle;

  const _LibraryHeader({
    required this.totalTitles,
    this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'My ',
                      style: TextStyle(
                        color: context.colors.foreground,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontFamily: 'Inter',
                        height: 1.37,
                      ),
                    ),
                    TextSpan(
                      text: 'Library',
                      style: TextStyle(
                        color: context.colors.accentRed,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontFamily: 'Inter',
                        height: 1.37,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$totalTitles title${totalTitles == 1 ? '' : 's'}',
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onShuffle != null)
          GestureDetector(
            onTap: onShuffle,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: context.colors.surfaceRaised,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: context.colors.borderStrong),
              ),
              child: AppIcon(
                AppIcons.randomPick,
                size: 22.sp,
                color: context.colors.accentRed,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _LibrarySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _LibrarySearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        color: context.colors.foreground,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: context.colors.foreground,
      cursorWidth: 1.w,
      decoration: InputDecoration(
        hintText: 'Search your library...',
        hintStyle: TextStyle(
          color: context.colors.mutedSecondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: context.colors.mutedSecondary,
          size: 20.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: context.colors.borderStrong),
        ),
        isDense: true,
        fillColor: context.colors.surfaceRaised.withValues(alpha: 0.7),
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
              color: context.colors.accentRed.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

// ── Type Filter Row ───────────────────────────────────────────────────────────

class _TypeFilterRow extends StatelessWidget {
  final List<String> types;
  final String selected;
  final ValueChanged<String> onSelected;

  const _TypeFilterRow({
    required this.types,
    required this.selected,
    required this.onSelected,
  });

  static const _typeIcons = <String, String?>{
    'All': null,
    'Movies': AppIcons.movie,
    'Series': AppIcons.tvShow,
    'Anime': AppIcons.anime,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
        itemCount: types.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final t = types[index];
          final isSelected = t == selected;
          final icon = _typeIcons[t];

          return GestureDetector(
            onTap: () => onSelected(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: isSelected ? context.colors.accentRed : null,
                gradient: isSelected
                    ? null
                    : LinearGradient(
                        colors: [
                          context.colors.surfaceRaised,
                          context.colors.surfaceRaised.withValues(alpha: .4),
                          context.colors.surface,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : context.colors.borderStrong,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    AppIcon(
                      icon,
                      size: 18.sp,
                      color: isSelected
                          ? Colors.white
                          : context.colors.mutedForeground,
                    ),
                    SizedBox(width: 5.w),
                  ],
                  Text(
                    t,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : context.colors.mutedForeground,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Status Filter Row ─────────────────────────────────────────────────────────

class _StatusFilterRow extends StatelessWidget {
  final List<String> statuses;
  final Map<String, int> counts;
  final String selected;
  final ValueChanged<String> onSelected;

  const _StatusFilterRow({
    required this.statuses,
    required this.counts,
    required this.selected,
    required this.onSelected,
  });

  static const _statusIcons = {
    'Watchlist': Icons.bookmark_rounded,
    'Watched': Icons.check_rounded,
    'Dropped': Icons.close_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.surfaceRaised,
            context.colors.surfaceRaised.withValues(alpha: .4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(Radius.elliptical(22.r, 24.r)),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Row(
        children: statuses.map((s) {
          final isSelected = s == selected;
          final icon = _statusIcons[s]!;
          final count = counts[s] ?? 0;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.accentRed.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.elliptical(16.r, 18.r)),
                  border: isSelected
                      ? Border.all(
                          color:
                              context.colors.accentRed.withValues(alpha: 0.5),
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                context.colors.accentRed.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 13.sp,
                          color: isSelected
                              ? context.colors.accentRed
                              : context.colors.mutedSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          s,
                          style: TextStyle(
                            color: isSelected
                                ? context.colors.foreground
                                : context.colors.mutedSecondary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected
                            ? context.colors.accentRed
                            : context.colors.mutedSecondaryDeep,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Sort Button ───────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SortButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: context.colors.surfaceRaised,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: context.colors.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert_rounded,
                size: 15.sp, color: context.colors.mutedSecondaryVibe),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                color: context.colors.mutedSecondaryVibe,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 15.sp, color: context.colors.mutedSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Sort Panel ────────────────────────────────────────────────────────────────

class _SortPanel extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _SortPanel({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.surfaceRaised,
            context.colors.surfaceRaised.withValues(alpha: .5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort by',
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 10.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 10.w) / 2;
              return Wrap(
                spacing: 10.w,
                runSpacing: 2.h,
                children: options.map((option) {
                  final isSelected = option == selected;
                  return SizedBox(
                    width: itemWidth,
                    child: GestureDetector(
                      onTap: () => onSelected(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.accentRed.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.accentRed
                                    .withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (isSelected) ...[
                              Icon(
                                Icons.check_rounded,
                                size: 14.sp,
                                color: context.colors.accentRed,
                              ),
                              SizedBox(width: 6.w),
                            ],
                            Flexible(
                              child: Text(
                                option,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected
                                      ? context.colors.foreground
                                      : context.colors.mutedSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String status;
  final String type;
  final bool hasSearch;

  const _EmptyState({
    required this.status,
    required this.type,
    required this.hasSearch,
  });

  @override
  Widget build(BuildContext context) {
    final String title;
    final String subtitle;
    final IconData icon;

    if (hasSearch) {
      title = 'No results found';
      subtitle = 'Try a different search term or clear the filter.';
      icon = Icons.search_off_rounded;
    } else {
      switch (status) {
        case 'Watchlist':
          title = 'Your watchlist is empty';
          subtitle = 'Browse and add titles you want to watch.';
          icon = Icons.bookmark_border_rounded;
        case 'Watched':
          title = 'No watched titles yet';
          subtitle = 'Titles you finish will appear here.';
          icon = Icons.check_circle_outline_rounded;
        default: // Dropped
          title = 'No dropped titles';
          subtitle = 'Titles you dropped will appear here.';
          icon = Icons.cancel_outlined;
      }
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52.sp, color: context.colors.mutedSecondaryDeep),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.foreground,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.mutedSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
