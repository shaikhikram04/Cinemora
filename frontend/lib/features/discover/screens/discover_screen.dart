import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/features/discover/widgets/discover_search_bar.dart';
import 'package:watchary/features/discover/widgets/discover_filter_chips.dart';
import 'package:watchary/features/discover/widgets/discover_recent_searches.dart';
import 'package:watchary/features/discover/widgets/discover_trending_section.dart';
import 'package:watchary/features/discover/widgets/discover_genre_grid.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
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

            // ── Search Bar ──────────────────────────────────────────
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

            // ── Filter Chips (All / Movies / Anime / Series) ────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: const DiscoverFilterChips(),
              ),
            ),

            // ── Genre sub-filter chips ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: const DiscoverGenreChips(),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            // ── Recent Searches ─────────────────────────────────────
            const SliverToBoxAdapter(
              child: DiscoverRecentSearches(),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            // ── Trending Searches ───────────────────────────────────
            const SliverToBoxAdapter(
              child: DiscoverTrendingSection(),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 28.h)),

            // ── Browse by Genre ─────────────────────────────────────
            const SliverToBoxAdapter(
              child: DiscoverGenreGrid(),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }
}
