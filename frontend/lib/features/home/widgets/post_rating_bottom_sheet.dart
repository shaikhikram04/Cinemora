import 'package:cinemora/core/models/cinema_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/cards/vertical_poster_bookmark_card.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'package:cinemora/features/rankings/viewmodels/rankings_cubit.dart';
import 'package:cinemora/features/rankings/views/ranking_placement_view.dart';

// ─── Public entry point ───────────────────────────────────────────────────────

void showPostRatingSheet(
  BuildContext context, {
  required String movieTitle,
  required String movieImage,
  required String movieType,
  required double userRating,
  required String ratingLabel,
  required Color ratingColor,
  String movieYear = '',
  List<String> genres = const [],
}) {
  final rankingsCubit = context.read<RankingsCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => BlocProvider.value(
      value: rankingsCubit,
      child: _PostRatingSheet(
        movieTitle: movieTitle,
        movieImage: movieImage,
        movieType: movieType,
        movieYear: movieYear,
        userRating: userRating,
        ratingLabel: ratingLabel,
        ratingColor: ratingColor,
        genres: genres,
      ),
    ),
  );
}

// ─── Root sheet ───────────────────────────────────────────────────────────────

class _PostRatingSheet extends StatefulWidget {
  final String movieTitle;
  final String movieImage;
  final String movieType;
  final String movieYear;
  final double userRating;
  final String ratingLabel;
  final Color ratingColor;
  final List<String> genres;

  const _PostRatingSheet({
    required this.movieTitle,
    required this.movieImage,
    required this.movieType,
    required this.movieYear,
    required this.userRating,
    required this.ratingLabel,
    required this.ratingColor,
    required this.genres,
  });

  @override
  State<_PostRatingSheet> createState() => _PostRatingSheetState();
}

class _PostRatingSheetState extends State<_PostRatingSheet> {
  bool _showDiscover = false;
  String? _selectedTitle;

  bool get _hasSelection => _selectedTitle != null;

  // ── Genre-based suggestion pool (matched against TMDB genre names) ──────────
  static const _genrePool = [
    {
      'emoji': '😰',
      'title': 'Edge of Your Seat',
      'sub': 'Thrillers that kept you gripped',
      'genres': 'thriller,suspense'
    },
    {
      'emoji': '🤯',
      'title': 'GOAT Climax',
      'sub': 'Plot twists you never saw coming',
      'genres': 'mystery,crime'
    },
    {
      'emoji': '💥',
      'title': 'Action Legends',
      'sub': 'Pure adrenaline, start to finish',
      'genres': 'action,adventure'
    },
    {
      'emoji': '⚡',
      'title': 'Pure Adrenaline',
      'sub': 'Non-stop high-octane cinema',
      'genres': 'action,war'
    },
    {
      'emoji': '👻',
      'title': 'Nightmare Fuel',
      'sub': 'Horror that genuinely scared you',
      'genres': 'horror'
    },
    {
      'emoji': '😂',
      'title': 'Comedy Gold',
      'sub': 'Genuinely made you laugh out loud',
      'genres': 'comedy'
    },
    {
      'emoji': '😄',
      'title': 'Feel Good Picks',
      'sub': 'Always lifts your mood',
      'genres': 'family,music'
    },
    {
      'emoji': '😭',
      'title': 'Emotional Rollercoasters',
      'sub': 'Hit you right in the feelings',
      'genres': 'drama,romance'
    },
    {
      'emoji': '🎭',
      'title': 'Powerful Dramas',
      'sub': 'Stories that left a lasting mark',
      'genres': 'drama'
    },
    {
      'emoji': '🚀',
      'title': 'Sci-Fi Gems',
      'sub': 'The very best the genre has to offer',
      'genres': 'science fiction,sci-fi'
    },
    {
      'emoji': '🌌',
      'title': 'Mind-Expanding Sci-Fi',
      'sub': 'Left you questioning reality',
      'genres': 'science fiction'
    },
    {
      'emoji': '💕',
      'title': 'Love Stories',
      'sub': 'Romance done beautifully right',
      'genres': 'romance'
    },
    {
      'emoji': '⛩️',
      'title': 'Anime Masterclass',
      'sub': 'The pinnacle of the medium',
      'genres': 'animation'
    },
    {
      'emoji': '🕵️',
      'title': 'Crime Masterminds',
      'sub': 'The cleverest crime stories ever told',
      'genres': 'crime'
    },
    {
      'emoji': '🖤',
      'title': 'Dark & Intense',
      'sub': 'Gripping stories that go to dark places',
      'genres': 'thriller'
    },
    {
      'emoji': '🗡️',
      'title': 'Epic Fantasy',
      'sub': 'World-building at its very finest',
      'genres': 'fantasy'
    },
    {
      'emoji': '✨',
      'title': 'Magical Worlds',
      'sub': 'Rich and immersive cinematic universes',
      'genres': 'fantasy,animation'
    },
    {
      'emoji': '🔍',
      'title': 'Mystery & Suspense',
      'sub': 'Kept you guessing throughout',
      'genres': 'mystery'
    },
    {
      'emoji': '📽️',
      'title': 'Eye-Opening Docs',
      'sub': 'Changed how you see the world',
      'genres': 'documentary'
    },
    {
      'emoji': '🦸',
      'title': 'Superhero Hall of Fame',
      'sub': 'The very best of the genre',
      'genres': 'superhero'
    },
    {
      'emoji': '⚔️',
      'title': 'War Epics',
      'sub': 'Harrowing and powerful war stories',
      'genres': 'war'
    },
    {
      'emoji': '📜',
      'title': 'Historical Gems',
      'sub': 'History brought brilliantly to life',
      'genres': 'history'
    },
    {
      'emoji': '🧬',
      'title': 'Psychological Thrillers',
      'sub': 'Messed with your mind brilliantly',
      'genres': 'psychological'
    },
    {
      'emoji': '🎪',
      'title': 'Cinematic Spectacles',
      'sub': 'Made for the biggest screen possible',
      'genres': 'adventure'
    },
    {
      'emoji': '🌟',
      'title': 'Hidden Gems',
      'sub': 'Overlooked but truly brilliant',
      'genres': ''
    },
  ];

  // ── Rating-tier suggestions (slot 2) — scale: 0.5 to 5.0 stars ──────────────
  static const _ratingTiers = [
    {
      'min': '4.5',
      'emoji': '🏆',
      'title': 'Masterpieces',
      'sub': 'Reserved for the absolute elite'
    },
    {
      'min': '4.0',
      'emoji': '❤️',
      'title': 'All-Time Favorites',
      'sub': 'Your personal hall of fame'
    },
    {
      'min': '3.5',
      'emoji': '⭐',
      'title': 'Top Picks',
      'sub': 'Titles that truly delivered'
    },
    {
      'min': '3.0',
      'emoji': '👌',
      'title': 'Worth the Watch',
      'sub': 'Solid titles you\'d recommend'
    },
    {
      'min': '2.0',
      'emoji': '🎬',
      'title': 'Decent Watches',
      'sub': 'Enjoyable but not unforgettable'
    },
    {
      'min': '0.0',
      'emoji': '😅',
      'title': 'Guilty Pleasures',
      'sub': 'Flawed but oddly still fun'
    },
  ];

  static Map<String, String>? _matchGenre(
      List<String> genres, String movieType) {
    final search = [
      ...genres.map((g) => g.toLowerCase()),
      movieType.toLowerCase(),
    ];
    for (final item in _genrePool) {
      final tags = (item['genres'] ?? '')
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty);
      if (tags.any((t) => search.any((s) => s.contains(t) || t.contains(s)))) {
        return item;
      }
    }
    return _genrePool.last; // "Hidden Gems" fallback
  }

  static Map<String, String> _matchRating(double rating) {
    for (final tier in _ratingTiers) {
      if (rating >= double.parse(tier['min']!)) return tier;
    }
    return _ratingTiers.last;
  }

  void _handlePlaceInRankings(BuildContext context) {
    if (_selectedTitle == null) return;
    final cubit = context.read<RankingsCubit>();
    var targetList =
        cubit.state.lists.where((l) => l.title == _selectedTitle).firstOrNull;

    if (targetList == null) {
      // Suggested list doesn't exist yet — find emoji from either pool
      final allPools = [..._genrePool, ..._ratingTiers];
      final poolItem =
          allPools.where((s) => s['title'] == _selectedTitle).firstOrNull;
      cubit.createList(
        emoji: poolItem?['emoji'] ?? '🏆',
        title: _selectedTitle!,
        subtitle: poolItem?['sub'] ?? '',
      );
      targetList =
          cubit.state.lists.firstWhere((l) => l.title == _selectedTitle);
    }

    final newEntry = RankingEntry(
      title: widget.movieTitle,
      year: widget.movieYear,
      type: widget.movieType,
      rating: widget.userRating.toStringAsFixed(1),
      image: widget.movieImage,
    );

    // If this title already exists, strip it from the battle list so the
    // placement runs against the remaining entries. RankingsCubit is NOT
    // modified here — it only gets updated when the user explicitly completes
    // the battle (Done / X / View Full Ranking). If they abandon mid-battle,
    // the original list is preserved untouched.
    final existingIndex = targetList.entries.indexWhere(
      (e) => e.title.toLowerCase() == widget.movieTitle.toLowerCase(),
    );
    final listForBattle = existingIndex == -1
        ? targetList
        : RankingList(
            emoji: targetList.emoji,
            title: targetList.title,
            subtitle: targetList.subtitle,
            count: targetList.count,
            accent: targetList.accent,
            images: targetList.images,
            entries: List.of(targetList.entries)..removeAt(existingIndex),
          );

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: RankingPlacementView(
            list: listForBattle,
            newEntry: newEntry,
          ),
        ),
      ),
    );
  }

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
            child: Builder(
              builder: (ctx) {
                if (_showDiscover) {
                  return _DiscoverBody(
                    movieTitle: widget.movieTitle,
                    rating: widget.userRating,
                    recs: _recs,
                    scrollController: ScrollController(),
                  );
                }
                final lists = ctx.read<RankingsCubit>().state.lists;
                final existingTitles = lists.map((l) => l.title).toSet();

                Map<String, String> toSuggestion(Map<String, String> pool) {
                  final exists = existingTitles.contains(pool['title']);
                  return {
                    'emoji': pool['emoji']!,
                    'title': pool['title']!,
                    'sub': exists ? 'Add to your existing list' : pool['sub']!,
                    'isNew': exists ? 'false' : 'true',
                  };
                }

                // Slot 1: best genre match
                final genreMatch =
                    _matchGenre(widget.genres, widget.movieType)!;
                // Slot 2: rating tier — skip if same title as slot 1
                final ratingMatch = _matchRating(widget.userRating);
                final suggestions = [
                  toSuggestion(genreMatch),
                  if (ratingMatch['title'] != genreMatch['title'])
                    toSuggestion(ratingMatch),
                ];

                final userLists = lists
                    .map((l) => {
                          'emoji': l.emoji,
                          'title': l.title,
                        })
                    .toList();
                return _RankingsBody(
                  suggestions: suggestions,
                  userLists: userLists,
                  selectedTitle: _selectedTitle,
                  onToggle: (title) => setState(() =>
                      _selectedTitle = _selectedTitle == title ? null : title),
                  scrollController: ScrollController(),
                );
              },
            ),
          ),
          // Bottom CTA
          if (!_showDiscover)
            _BottomCTA(
              ratingColor: widget.ratingColor,
              hasSelection: _hasSelection,
              onPlaceTap: () => _handlePlaceInRankings(context),
              onDiscoverTap: () => setState(() => _showDiscover = true),
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
  final String? selectedTitle;
  final ValueChanged<String> onToggle;
  final ScrollController scrollController;

  const _RankingsBody({
    required this.suggestions,
    required this.userLists,
    required this.selectedTitle,
    required this.onToggle,
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
        if (suggestions.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: WSizes.screenPadding.w, vertical: 8.h),
            child: Text(
              'No ranking lists yet — create one in the Rankings tab.',
              style: TextStyle(
                  fontSize: 12.sp, color: context.colors.mutedSecondary),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...List.generate(suggestions.length, (i) {
            final title = suggestions[i]['title']!;
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: WSizes.screenPadding.w, vertical: 5.h),
              child: _SuggestionCard(
                emoji: suggestions[i]['emoji']!,
                title: title,
                sub: suggestions[i]['sub']!,
                selected: selectedTitle == title,
                isNew: suggestions[i]['isNew'] == 'true',
                index: i,
                onTap: () => onToggle(title),
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
        // User list items
        if (userLists.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: WSizes.screenPadding.w, vertical: 8.h),
            child: Text(
              'Create ranking lists to organise your cinema.',
              style: TextStyle(
                  fontSize: 12.sp, color: context.colors.mutedSecondary),
              textAlign: TextAlign.center,
            ),
          )
        else
          Container(
            margin: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
            decoration: BoxDecoration(
              color: context.colors.surfaceMuted.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: List.generate(userLists.length, (i) {
                final title = userLists[i]['title']!;
                final isLast = i == userLists.length - 1;
                return Column(
                  children: [
                    _ListRow(
                      emoji: userLists[i]['emoji']!,
                      title: title,
                      selected: selectedTitle == title,
                      onTap: () => onToggle(title),
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
  final bool isNew;
  final int index;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.selected,
    required this.isNew,
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
            color: selected
                ? checkColor.withValues(alpha: 0.3)
                : context.colors.border,
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: 22.sp,
                inherit: false,
              ),
            ),
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
                          fontSize: 11.sp,
                          color: context.colors.mutedSecondary)),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            if (isNew && !selected)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9A3).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: const Color(0xFF00D9A3).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  'CREATE',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00D9A3),
                    letterSpacing: 0.6,
                  ),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: selected ? checkColor : context.colors.surfaceRaised,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color:
                          selected ? checkColor : context.colors.borderStrong,
                      width: 1.5),
                ),
                child: selected
                    ? Icon(Icons.check_rounded,
                        size: 16.sp, color: Colors.white)
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
                  color: selected
                      ? context.colors.success
                      : context.colors.borderStrong,
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
                      color: context.colors.success,
                      fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' ${rating.toStringAsFixed(1)}★',
                  style: TextStyle(
                      color: context.colors.success,
                      fontWeight: FontWeight.w700),
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
  final Color ratingColor;
  final bool hasSelection;
  final VoidCallback onPlaceTap;
  final VoidCallback onDiscoverTap;

  const _BottomCTA({
    required this.ratingColor,
    required this.hasSelection,
    required this.onPlaceTap,
    required this.onDiscoverTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E24),
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary: Place in Rankings (only shown when a list is selected)
          if (hasSelection) ...[
            GestureDetector(
              onTap: onPlaceTap,
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.accentRed,
                      const Color(0xFFC81B23),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Place in Rankings',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18.sp),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
          // Secondary: Discover Similar
          GestureDetector(
            onTap: onDiscoverTap,
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
                  Icon(Icons.trending_up_rounded,
                      color: ratingColor, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
