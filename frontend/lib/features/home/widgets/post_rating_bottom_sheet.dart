import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

// ─── Public entry point ───────────────────────────────────────────────────────

void showPostRatingSheet(
  BuildContext context, {
  required String movieTitle,
  required String movieImage,
  required String movieType,
  required double userRating,
  required String ratingLabel,
  required Color ratingColor,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => _PostRatingSheet(
      movieTitle: movieTitle,
      movieImage: movieImage,
      movieType: movieType,
      userRating: userRating,
      ratingLabel: ratingLabel,
      ratingColor: ratingColor,
    ),
  );
}

// ─── Root sheet ───────────────────────────────────────────────────────────────

class _PostRatingSheet extends StatefulWidget {
  final String movieTitle;
  final String movieImage;
  final String movieType;
  final double userRating;
  final String ratingLabel;
  final Color ratingColor;

  const _PostRatingSheet({
    required this.movieTitle,
    required this.movieImage,
    required this.movieType,
    required this.userRating,
    required this.ratingLabel,
    required this.ratingColor,
  });

  @override
  State<_PostRatingSheet> createState() => _PostRatingSheetState();
}

class _PostRatingSheetState extends State<_PostRatingSheet> {
  bool _showDiscover = false;

  // Smart suggestion selected state
  final Set<int> _selectedSuggestions = {0}; // first pre-selected
  // User lists selected state
  final Set<int> _selectedLists = {};

  static const _suggestions = [
    {
      'emoji': '❤️',
      'title': 'All-Time Favorites',
      'sub': 'Smart pick for this excellent title'
    },
    {
      'emoji': '🤯',
      'title': 'Mind-Blowing Endings',
      'sub': 'Smart pick for this excellent title'
    },
  ];

  static const _userLists = [
    {'emoji': '🚀', 'title': 'Best Sci-Fi'},
    {'emoji': '⛩️', 'title': 'Top Anime'},
    {'emoji': '📺', 'title': 'Binge-Worthy Series'},
    {'emoji': '🎬', 'title': 'Must-Watch Classics'},
  ];

  static const _recs = [
    {
      'title': 'Breaking Bad',
      'tag': 'SERIES',
      'rating': '9.5',
      'image':
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=400&auto=format&fit=crop'
    },
    {
      'title': 'Attack on Titan',
      'tag': 'ANIME',
      'rating': '9.1',
      'image':
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=400&auto=format&fit=crop'
    },
    {
      'title': 'Fullmetal Alchemist: Brotherhood',
      'tag': 'ANIME',
      'rating': '9.1',
      'image':
          'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=400&auto=format&fit=crop'
    },
    {
      'title': 'Steins;Gate',
      'tag': 'ANIME',
      'rating': '9.1',
      'image':
          'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?q=80&w=400&auto=format&fit=crop'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    // Rankings content is compact; Discover needs more room for poster cards
    final sheetHeight = _showDiscover ? screenH * 0.58 : screenH * 0.78;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      height: sheetHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          _DragHandle(),
          // Header
          _SheetHeader(
            title: widget.movieTitle,
            image: widget.movieImage,
            type: widget.movieType,
            rating: widget.userRating,
            ratingLabel: widget.ratingLabel,
            ratingColor: widget.ratingColor,
            onClose: () => Navigator.pop(context),
          ),
          SizedBox(height: 14.h),
          // Body
          Expanded(
            child: _showDiscover
                ? _DiscoverBody(
                    movieTitle: widget.movieTitle,
                    rating: widget.userRating,
                    recs: _recs,
                    scrollController: ScrollController(),
                  )
                : _RankingsBody(
                    suggestions: _suggestions,
                    userLists: _userLists,
                    selectedSuggestions: _selectedSuggestions,
                    selectedLists: _selectedLists,
                    onToggleSuggestion: (i) => setState(() =>
                        _selectedSuggestions.contains(i)
                            ? _selectedSuggestions.remove(i)
                            : _selectedSuggestions.add(i)),
                    onToggleList: (i) => setState(() =>
                        _selectedLists.contains(i)
                            ? _selectedLists.remove(i)
                            : _selectedLists.add(i)),
                    scrollController: ScrollController(),
                  ),
          ),
          // Bottom CTA
          if (!_showDiscover)
            _BottomCTA(
              ratingColor: widget.ratingColor,
              onTap: () => setState(() => _showDiscover = true),
            ),
        ],
      ),
    );
  }
}

// ─── Drag handle ─────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
        child: Container(
          width: 36.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: context.colors.surfaceChipBorder,
            borderRadius: BorderRadius.circular(99.r),
          ),
        ),
      );
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final String title, image, type, ratingLabel;
  final double rating;
  final Color ratingColor;
  final VoidCallback onClose;

  const _SheetHeader({
    required this.title,
    required this.image,
    required this.type,
    required this.rating,
    required this.ratingLabel,
    required this.ratingColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Row(
        children: [
          // Poster thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              image,
              width: 52.w,
              height: 66.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52.w,
                height: 66.h,
                color: context.colors.surfaceMuted,
                child: Icon(Icons.movie,
                    color: context.colors.mutedForeground, size: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.movie_creation_outlined,
                        size: 11.sp, color: context.colors.mutedSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.mutedSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.foreground,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: ratingColor),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.star_rounded, size: 13.sp, color: ratingColor),
                    SizedBox(width: 6.w),
                    Text(
                      ratingLabel,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: ratingColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: context.colors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close,
                  size: 16.sp, color: context.colors.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rankings body ────────────────────────────────────────────────────────────

class _RankingsBody extends StatelessWidget {
  final List<Map<String, String>> suggestions;
  final List<Map<String, String>> userLists;
  final Set<int> selectedSuggestions;
  final Set<int> selectedLists;
  final ValueChanged<int> onToggleSuggestion;
  final ValueChanged<int> onToggleList;
  final ScrollController scrollController;

  const _RankingsBody({
    required this.suggestions,
    required this.userLists,
    required this.selectedSuggestions,
    required this.selectedLists,
    required this.onToggleSuggestion,
    required this.onToggleList,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        // Smart Suggestions label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
          child: Row(
            children: [
              Icon(
                Icons.wb_incandescent_rounded,
                color: context.colors.chartPurple,
                size: 16.sp,
              ),
              SizedBox(width: 5.w),
              Text(
                'SMART SUGGESTIONS',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: context.colors.chartPurple,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Suggestion cards
        ...List.generate(suggestions.length, (i) {
          final selected = selectedSuggestions.contains(i);
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: WSizes.screenPadding.w, vertical: 5.h),
            child: _SuggestionCard(
              emoji: suggestions[i]['emoji']!,
              title: suggestions[i]['title']!,
              sub: suggestions[i]['sub']!,
              selected: selected,
              index: i,
              onTap: () => onToggleSuggestion(i),
            ),
          );
        }),
        SizedBox(height: 18.h),
        // All Lists label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
          child: Text(
            'ALL LISTS',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.mutedSecondary,
              letterSpacing: 1.1,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // User list items inside a constrained box with inner scroll
        Container(
          margin: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
          decoration: BoxDecoration(
            color: context.colors.surfaceMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            children: List.generate(userLists.length, (i) {
              final selected = selectedLists.contains(i);
              final isLast = i == userLists.length - 1;
              return Column(
                children: [
                  _ListRow(
                    emoji: userLists[i]['emoji']!,
                    title: userLists[i]['title']!,
                    selected: selected,
                    onTap: () => onToggleList(i),
                  ),
                  if (!isLast)
                    Divider(
                        height: 1,
                        thickness: 0.6,
                        color: context.colors.border,
                        indent: 16.w,
                        endIndent: 16.w),
                ],
              );
            }),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String emoji, title, sub;
  final bool selected;
  final int index;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.selected,
    required this.index,
    required this.onTap,
  });

  static const _selectedBgs = [
    Color(0xFF3A1A1E), // red-ish for index 0
    Color(0xFF1E1A3A), // purple-ish for index 1
  ];

  List<Color> _resolvedCheckColors(BuildContext context) =>
      [context.colors.accentRed, context.colors.accentPurple];

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? _selectedBgs[index % _selectedBgs.length]
        : context.colors.surfaceMuted;
    final checkColor = _resolvedCheckColors(context)[index % 2];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color:
                selected ? checkColor.withValues(alpha: 0.3) : context.colors.border,
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.foreground),
                  ),
                  SizedBox(height: 3.h),
                  Text(sub,
                      style: TextStyle(
                          fontSize: 11.sp, color: context.colors.mutedSecondary)),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: selected ? checkColor : context.colors.surfaceRaised,
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? checkColor : context.colors.borderStrong,
                    width: 1.5),
              ),
              child: selected
                  ? Icon(Icons.check_rounded, size: 16.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  final String emoji, title;
  final bool selected;
  final VoidCallback onTap;

  const _ListRow(
      {required this.emoji,
      required this.title,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: context.colors.surfaceRaised,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child:
                  Center(child: Text(emoji, style: TextStyle(fontSize: 16.sp))),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colors.foreground),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: selected ? context.colors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? context.colors.success : context.colors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Icon(Icons.check_rounded,
                      size: 14.sp, color: const Color(0xFF0D1F1A))
                  : Icon(Icons.add_rounded,
                      size: 14.sp, color: context.colors.mutedSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Discover body ────────────────────────────────────────────────────────────

class _DiscoverBody extends StatelessWidget {
  final String movieTitle;
  final double rating;
  final List<Map<String, String>> recs;
  final ScrollController scrollController;

  const _DiscoverBody({
    required this.movieTitle,
    required this.rating,
    required this.recs,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: 12.h),
        // Subtitle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 13.sp,
                  color: context.colors.mutedSecondary,
                  fontFamily: 'Inter'),
              children: [
                const TextSpan(text: 'Because you rated '),
                TextSpan(
                  text: movieTitle,
                  style: TextStyle(
                      color: context.colors.success, fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' ${rating.toStringAsFixed(1)}★',
                  style: TextStyle(
                      color: context.colors.success, fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ', try these:'),
              ],
            ),
          ),
        ),
        SizedBox(height: 14.h),
        // Rec cards horizontal scroll
        SizedBox(
          height: WSizes.imageCarouselHeight.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
            itemCount: recs.length,
            separatorBuilder: (_, i) => SizedBox(width: 8.w),
            itemBuilder: (_, i) => VerticalPosterBookmarkCard(
              title: recs[i]['title']!,
              rating: recs[i]['rating']!,
              image: recs[i]['image']!,
              width: WSizes.posterImageWidth.w,
              imageHeight: WSizes.posterImageHeight.h,
              cinemaType: CinemaType.anime,
              year: '2020',
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

// ─── Bottom CTA ───────────────────────────────────────────────────────────────

class _BottomCTA extends StatelessWidget {
  final VoidCallback onTap;
  final Color ratingColor;

  const _BottomCTA({required this.onTap, required this.ratingColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E24),
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
                color: ratingColor.withValues(alpha: 0.4), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Discover Similar Content',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: ratingColor),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.trending_up_rounded,
                color: ratingColor,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
