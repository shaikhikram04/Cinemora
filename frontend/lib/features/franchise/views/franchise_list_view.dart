import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/buttons/circle_icon_button.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/router/app_router.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/discover/widgets/discover_search_bar.dart';
import 'package:cinemora/features/franchise/models/franchise_summary.dart';
import 'package:cinemora/features/franchise/repositories/franchise_repository.dart';
import 'package:cinemora/features/franchise/viewmodels/franchise_list_cubit.dart';
import 'package:cinemora/features/franchise/viewmodels/franchise_list_state.dart';
import 'package:cinemora/features/franchise/widgets/franchise_results_section.dart';

class FranchiseListView extends StatelessWidget {
  const FranchiseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FranchiseListCubit(context.read<FranchiseRepository>()),
      child: const _FranchiseListContent(),
    );
  }
}

class _FranchiseListContent extends StatefulWidget {
  const _FranchiseListContent();

  @override
  State<_FranchiseListContent> createState() => _FranchiseListContentState();
}

class _FranchiseListContentState extends State<_FranchiseListContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch(FranchiseListCubit cubit) {
    _searchController.clear();
    _focusNode.unfocus();
    cubit.clearSearch();
  }

  void _openFranchise(FranchiseSummary franchise) {
    context.push(
      AppRoutes.franchiseDetail,
      extra: FranchiseRouteArgs(
        collectionId: franchise.id,
        name: franchise.name,
        backdropUrl: franchise.backdropUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FranchiseListCubit, FranchiseListState>(
      builder: (context, state) {
        final cubit = context.read<FranchiseListCubit>();
        return Scaffold(
          backgroundColor: context.colors.background,
          body: GestureDetector(
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
                      child: Row(
                        children: [
                          WCircleIconButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Franchises',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: context.colors.foreground,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
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
                        onChanged: cubit.onSearchChanged,
                        onSubmitted: cubit.onSearchChanged,
                        onClear: () => _clearSearch(cubit),
                        isActive: state.isSearching,
                        onDismiss: () => _clearSearch(cubit),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                  if (!state.isSearching) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: WSizes.screenPadding.w,
                        ),
                        child: Text(
                          'Popular Franchises',
                          style: TextStyle(
                            color: context.colors.foreground,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 14.h)),
                    SliverToBoxAdapter(
                      child: FranchiseResultsSection(
                        status: state.featuredStatus,
                        items: state.featured,
                        onTap: _openFranchise,
                        emptyMessage: 'No franchises available right now.',
                        onRetry: cubit.retryFeatured,
                      ),
                    ),
                  ] else
                    SliverToBoxAdapter(
                      child: FranchiseResultsSection(
                        status: state.searchStatus,
                        items: state.searchResults,
                        onTap: _openFranchise,
                        query: state.searchQuery,
                        emptyMessage:
                            'No franchises found for "${state.searchQuery}"',
                        errorMessage: state.errorMessage,
                        onRetry: cubit.retrySearch,
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
