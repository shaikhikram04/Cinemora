import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/discover/viewmodels/discover_cubit.dart';
import 'package:cinemora/features/discover/viewmodels/discover_state.dart';
import 'package:cinemora/features/discover/widgets/discover_filter_chips.dart';
import 'package:cinemora/features/discover/widgets/discover_genre_grid.dart';
import 'package:cinemora/features/discover/widgets/discover_recent_searches.dart';
import 'package:cinemora/features/discover/widgets/discover_search_bar.dart';
import 'package:cinemora/features/discover/widgets/discover_trending_section.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoverCubit(),
      child: const _DiscoverContent(),
    );
  }
}

class _DiscoverContent extends StatefulWidget {
  const _DiscoverContent();

  @override
  State<_DiscoverContent> createState() => _DiscoverContentState();
}

class _DiscoverContentState extends State<_DiscoverContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        final cubit = context.read<DiscoverCubit>();
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
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
                    child: Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: WColors.foreground,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      14.h,
                      WSizes.screenPadding.w,
                      0,
                    ),
                    child: DiscoverSearchBar(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: (_) {},
                      onClear: () => _searchController.clear(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: DiscoverFilterChips(
                      selectedIndex: state.selectedFilterIndex,
                      onSelect: cubit.selectFilter,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: DiscoverGenreChips(
                      selectedIndices: state.selectedGenreIndices,
                      onToggle: cubit.toggleGenre,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                SliverToBoxAdapter(
                  child: DiscoverRecentSearches(
                    recentSearches: state.recentSearches,
                    onRemove: cubit.removeRecentSearch,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                const SliverToBoxAdapter(
                  child: DiscoverTrendingSection(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 28.h)),
                const SliverToBoxAdapter(
                  child: DiscoverGenreGrid(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            ),
          ),
        );
      },
    );
  }
}
