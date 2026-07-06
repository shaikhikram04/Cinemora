import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/discover/repositories/discover_repository.dart';
import 'package:cinemora/features/discover/viewmodels/discover_cubit.dart';
import 'package:cinemora/features/discover/viewmodels/discover_state.dart';
import 'package:cinemora/features/discover/widgets/discover_filter_chips.dart';
import 'package:cinemora/features/discover/widgets/discover_genre_grid.dart';
import 'package:cinemora/features/discover/widgets/discover_recent_searches.dart';
import 'package:cinemora/features/discover/widgets/discover_results_section.dart';
import 'package:cinemora/features/discover/widgets/discover_search_bar.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscoverCubit(
        context.read<DiscoverRepository>(),
        context.read<SharedPreferences>(),
      ),
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

  // Called by cubit.repeatSearch so the text field reflects the new term
  void _setSearchText(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.collapsed(offset: term.length);
  }

  void _clearSearch(DiscoverCubit cubit) {
    _searchController.clear();
    _focusNode.unfocus();
    cubit.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoverCubit, DiscoverState>(
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (context, state) {
        // Keep the text field in sync when cubit changes the query
        // (e.g. tapping a recent/trending chip)
        if (_searchController.text != state.searchQuery) {
          _setSearchText(state.searchQuery);
          if (state.searchQuery.isNotEmpty) _focusNode.requestFocus();
        }
      },
      builder: (context, state) {
        final cubit = context.read<DiscoverCubit>();
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      WSizes.screenPadding.w,
                      16.h,
                      WSizes.screenPadding.w,
                      0,
                    ),
                    child: _buildHeader(context, state, cubit),
                  ),
                ),

                // ── Search bar ───────────────────────────────────────────
                if (!state.isGenreBrowse)
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
                        onChanged: cubit.onSearchChanged,
                        onSubmitted: cubit.onSearchSubmitted,
                        onClear: () => _clearSearch(cubit),
                        onFocusGained: cubit.onSearchFocused,
                        isActive: state.isSearching,
                        onDismiss: () => _clearSearch(cubit),
                      ),
                    ),
                  ),

                // ── Filter chips ─────────────────────────────────────────
                if (!state.isGenreBrowse)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: DiscoverFilterChips(
                        selectedIndex: state.selectedFilterIndex,
                        onSelect: cubit.selectFilter,
                      ),
                    ),
                  ),

                // ── Mode-specific body ───────────────────────────────────
                if (state.isBrowsing) ..._browseSlivers(context, state, cubit),
                if (state.isSearching || state.isGenreBrowse)
                  ..._resultSlivers(context, state, cubit),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header row ─────────────────────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context, DiscoverState state, DiscoverCubit cubit) {
    if (state.isGenreBrowse) {
      // Genre browse header: back button + genre label
      return Row(
        children: [
          GestureDetector(
            onTap: cubit.exitGenreBrowse,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.colors.foreground,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            state.activeGenreLabel ?? 'Genre',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: context.colors.foreground,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
    }

    // Default title
    return Text(
      'Discover',
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        color: context.colors.foreground,
        letterSpacing: -0.5,
      ),
    );
  }

  // ── Browse mode slivers ────────────────────────────────────────────────────

  List<Widget> _browseSlivers(
      BuildContext context, DiscoverState state, DiscoverCubit cubit) {
    return [
      SliverToBoxAdapter(child: SizedBox(height: 24.h)),

      // Recent searches (hidden if empty)
      if (state.recentSearches.isNotEmpty)
        SliverToBoxAdapter(
          child: DiscoverRecentSearches(
            recentSearches: state.recentSearches,
            onTap: (term) {
              _setSearchText(term);
              cubit.repeatSearch(term);
            },
            onRemove: cubit.removeRecentSearch,
            onClearAll: cubit.clearAllRecentSearches,
          ),
        ),

      if (state.recentSearches.isNotEmpty)
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

      // Franchises entry point
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
          child: _FranchisesBanner(
            onTap: () => context.push(AppRoutes.franchiseList),
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 24.h)),

      // Genre grid
      SliverToBoxAdapter(
        child: DiscoverGenreGrid(
          onGenreTap: cubit.browseGenre,
        ),
      ),

      SliverToBoxAdapter(child: SizedBox(height: 32.h)),
    ];
  }

  // ── Search / genre results slivers ────────────────────────────────────────

  List<Widget> _resultSlivers(
      BuildContext context, DiscoverState state, DiscoverCubit cubit) {
    return [
      SliverToBoxAdapter(child: SizedBox(height: 20.h)),

      // Show recent searches when bar is focused but query is empty
      if (state.isSearching &&
          state.searchQuery.isEmpty &&
          state.recentSearches.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: DiscoverRecentSearches(
            recentSearches: state.recentSearches,
            onTap: (term) {
              _setSearchText(term);
              cubit.repeatSearch(term);
            },
            onRemove: cubit.removeRecentSearch,
            onClearAll: cubit.clearAllRecentSearches,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],

      // Results (loading / success / empty / failure)
      if (state.searchStatus != DiscoverSearchStatus.idle)
        SliverToBoxAdapter(
          child: DiscoverResultsSection(
            status: state.searchStatus,
            results: state.searchResults,
            query: state.isGenreBrowse
                ? state.activeGenreLabel ?? ''
                : state.searchQuery,
            errorMessage: state.errorMessage,
            onRetry: () {
              if (state.isGenreBrowse) {
                cubit.selectFilter(state.selectedFilterIndex);
              } else {
                cubit.onSearchSubmitted(state.searchQuery);
              }
            },
          ),
        ),
    ];
  }
}

// ── Franchises entry point ─────────────────────────────────────────────────

class _FranchisesBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _FranchisesBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.colors.surfaceChip,
          borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
          border: Border.all(
            color: context.colors.surfaceChipBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.collections_bookmark_rounded,
              color: context.colors.primary,
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Franchises',
                    style: TextStyle(
                      color: context.colors.foreground,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Browse movie collections like John Wick',
                    style: TextStyle(
                      color: context.colors.mutedForeground,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.mutedForeground,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
