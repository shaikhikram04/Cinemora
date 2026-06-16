import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/library/viewmodels/library_cubit.dart';
import 'package:cinemora/features/library/viewmodels/library_state.dart';
import 'package:cinemora/features/library/widgets/library_list_item.dart';
import 'package:cinemora/features/library/widgets/library_stats_card.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LibraryCubit(),
      child: const _LibraryContent(),
    );
  }
}

class _LibraryContent extends StatefulWidget {
  const _LibraryContent();

  @override
  State<_LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<_LibraryContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final cubit = context.read<LibraryCubit>();
        final items = cubit.sortedItems;

        return Container(
          color: context.colors.background,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      16.h,
                      WSizes.screenPadding.w,
                      0,
                    ),
                    child: const _LibraryHeader(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      16.h,
                      WSizes.screenPadding.w,
                      0,
                    ),
                    child: const LibraryStatsCard(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      16.h,
                      WSizes.screenPadding.w,
                      0,
                    ),
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
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      10.h,
                      WSizes.screenPadding.w,
                      0,
                    ),
                    child: _StatusFilterRow(
                      statuses: LibraryCubit.statuses,
                      counts: LibraryCubit.statusCounts,
                      selected: state.selectedStatus,
                      onSelected: cubit.selectStatus,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      16.h,
                      WSizes.screenPadding.w,
                      12.h,
                    ),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${items.length}',
                                style: TextStyle(color: context.colors.foreground),
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
                      padding: EdgeInsets.fromLTRB(
                        WSizes.screenPadding.w,
                        0,
                        WSizes.screenPadding.w,
                        12.h,
                      ),
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
                SliverPadding(
                  padding:
                      EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: LibraryListItem(item: items[index]),
                      ),
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
  const _LibraryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
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
              Row(
                children: [
                  Text(
                    '14 titles',
                    style: TextStyle(
                      color: context.colors.mutedSecondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 3.w,
                    height: 3.w,
                    margin: EdgeInsets.symmetric(horizontal: 7.w),
                    decoration: BoxDecoration(
                      color: context.colors.mutedSecondaryDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    '21h total',
                    style: TextStyle(
                      color: context.colors.mutedSecondary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
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
          borderSide:
              BorderSide(color: context.colors.accentRed.withValues(alpha: 0.5)),
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

  static const _typeIcons = {
    'All': null,
    'Movies': Icons.movie_outlined,
    'Series': Icons.tv_outlined,
    'Anime': Icons.auto_awesome_outlined,
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
                  color:
                      isSelected ? Colors.transparent : context.colors.borderStrong,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: 12.sp,
                        color: isSelected
                            ? Colors.white
                            : context.colors.mutedForeground),
                    SizedBox(width: 5.w),
                  ],
                  Text(
                    t,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : context.colors.mutedForeground,
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
    'Watched': Icons.check_rounded,
    'Watchlist': Icons.bookmark_rounded,
    'Dropped': Icons.close_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
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

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.accentRed.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.all(Radius.elliptical(16.r, 18.r)),
                  border: isSelected
                      ? Border.all(
                          color: context.colors.accentRed.withValues(alpha: 0.5),
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.colors.accentRed.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 15.sp,
                      color: isSelected
                          ? context.colors.accentRed
                          : context.colors.mutedSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      s,
                      style: TextStyle(
                        color: isSelected
                            ? context.colors.foreground
                            : context.colors.mutedSecondary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
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
                                ? context.colors.accentRed.withValues(alpha: 0.5)
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
