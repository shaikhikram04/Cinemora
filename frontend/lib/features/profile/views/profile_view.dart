import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_state.dart';
import 'package:cinemora/features/profile/viewmodels/profile_cubit.dart';
import 'package:cinemora/features/profile/viewmodels/profile_state.dart';
import 'package:cinemora/features/profile/widgets/profile_activity_card.dart';
import 'package:cinemora/features/profile/widgets/profile_collection_card.dart';
import 'package:cinemora/features/profile/widgets/profile_header_card.dart';
import 'package:cinemora/features/profile/widgets/profile_ranking_grid.dart';
import 'package:cinemora/features/profile/widgets/profile_section_header.dart';
import 'package:cinemora/features/profile/widgets/profile_stat_grid.dart';
import 'package:cinemora/features/profile/widgets/profile_taste_section.dart';
import 'package:cinemora/features/profile/widgets/profile_top_bar.dart';
import 'package:cinemora/features/profile/widgets/profile_top_favorites_row.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_cubit.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ProfileCubit(ctx.read<UserRepository>())..loadProfile(),
      child: const _ProfileContent(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppAuthCubit, AppAuthState>(
      builder: (context, authState) {
        final UserModel? user =
            authState is AppAuthAuthenticated ? authState.user : null;

        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<RankingsCubit, RankingsState>(
              builder: (context, rankingsState) {
                final isLoading = profileState.status == ProfileStatus.loading;
                final rankingLists = rankingsState.lists.take(4).toList();

                return Container(
                  color: context.colors.background,
                  child: SafeArea(
                    bottom: false,
                    child: RefreshIndicator(
                      color: context.colors.accentRed,
                      backgroundColor: context.colors.surfaceRaised,
                      onRefresh: () =>
                          context.read<ProfileCubit>().loadProfile(),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          WSizes.screenPadding.w,
                          12.h,
                          WSizes.screenPadding.w,
                          90.h,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          const ProfileTopBar(),
                          SizedBox(height: 14.h),
                          ProfileHeaderCard(user: user),
                          SizedBox(height: 14.h),
                          ProfileStatGrid(
                            stats: profileState.stats,
                            isLoading: isLoading,
                          ),
                          SizedBox(height: 32.h),
                          const ProfileSectionHeader(
                            title: 'Collection',
                            subtitle: 'Your library at a glance',
                          ),
                          SizedBox(height: 10.h),
                          ProfileCollectionCard(
                            stats: profileState.stats,
                            isLoading: isLoading,
                          ),
                          SizedBox(height: 32.h),
                          const ProfileSectionHeader(
                            title: 'Taste Profile',
                            subtitle: 'What defines your watch list',
                          ),
                          SizedBox(height: 10.h),
                          ProfileTasteSection(
                            user: user,
                            era: profileState.favoriteEra,
                          ),
                          SizedBox(height: 32.h),
                          const ProfileSectionHeader(
                            title: 'Top Favorites',
                            subtitle: 'Your trophy shelf',
                          ),
                          SizedBox(height: 16.h),
                          ProfileTopFavoritesRow(
                            entries: profileState.topFavorites,
                            watchedCount: profileState.watchedCount,
                            isLoading: isLoading,
                          ),
                          SizedBox(height: 32.h),
                          ProfileSectionHeader(
                            title: 'My Rankings',
                            subtitle: 'Curated lists',
                            trailing: rankingsState.lists.length >= 4
                                ? const ProfileSeeAllChip(label: 'See all')
                                : null,
                          ),
                          SizedBox(height: 16.h),
                          ProfileRankingGrid(lists: rankingLists),
                          SizedBox(height: 32.h),
                          const ProfileSectionHeader(
                            title: 'Recent Activity',
                            subtitle: 'The latest from your archive',
                          ),
                          SizedBox(height: 10.h),
                          ProfileActivityCard(
                            entries: profileState.recentActivity,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
