import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/features/library/widgets/library_stats_card.dart';
import 'package:watchary/features/library/widgets/library_list_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedType = 'All';
  String _selectedStatus = 'Watchlist';
  String _selectedSort = 'Recently added';
  bool _isSortOpen = false;
  final TextEditingController _searchController = TextEditingController();

  static const _types = ['All', 'Movies', 'Series', 'Anime'];
  static const _statuses = ['Watchlist', 'Watched', 'Dropped'];
  static const _sortOptions = [
    'Recently added',
    'Recently watched',
    'Highest rated',
    'Lowest rated',
    'Release date',
    'Alphabetical',
    'Runtime',
  ];

  static const _statusCounts = {
    'Watched': 9,
    'Watchlist': 3,
    'Dropped': 2,
  };

  static final List<LibraryItem> _allItems = [
    LibraryItem(
      title: 'The Bear',
      year: '2022',
      type: 'Series',
      genres: ['Drama'],
      rating: '8.7',
      userRating: 4.5,
      status: 'Watchlist',
      progress: 0.45,
      progressLabel: 'S3 · E4 of 10',
      addedAt: DateTime(2026, 5, 12),
      lastWatchedAt: DateTime(2026, 5, 15),
      runtimeMinutes: 30,
      image:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Shōgun',
      year: '2024',
      type: 'Series',
      genres: ['Drama'],
      rating: '9.1',
      userRating: 5.0,
      status: 'Watchlist',
      progress: 0.70,
      progressLabel: 'S1 · E7 of 10',
      addedAt: DateTime(2026, 5, 10),
      lastWatchedAt: DateTime(2026, 5, 14),
      runtimeMinutes: 55,
      image:
          'https://images.unsplash.com/photo-1528360983277-13d401cdc186?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Attack on Titan',
      year: '2013',
      type: 'Anime',
      genres: ['Action'],
      rating: '9',
      userRating: 5.0,
      status: 'Watchlist',
      progress: 0.78,
      progressLabel: 'Final · E22 of 28',
      addedAt: DateTime(2026, 5, 8),
      lastWatchedAt: DateTime(2026, 5, 13),
      runtimeMinutes: 24,
      image:
          'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a0b9?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Dune: Part Two',
      year: '2024',
      type: 'Movies',
      genres: ['Sci-Fi'],
      rating: '8.5',
      userRating: 4.5,
      status: 'Watched',
      progress: 1.0,
      progressLabel: '',
      addedAt: DateTime(2026, 5, 6),
      lastWatchedAt: DateTime(2026, 5, 6),
      runtimeMinutes: 166,
      image:
          'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Death Note',
      year: '2006',
      type: 'Anime',
      genres: ['Thriller'],
      rating: '9.0',
      userRating: 4.5,
      status: 'Watched',
      progress: 1.0,
      progressLabel: '',
      addedAt: DateTime(2026, 4, 22),
      lastWatchedAt: DateTime(2026, 5, 2),
      runtimeMinutes: 23,
      image:
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Frieren',
      year: '2023',
      type: 'Anime',
      genres: ['Fantasy'],
      rating: '9.1',
      userRating: 0,
      status: 'Watched',
      progress: 0.0,
      progressLabel: '',
      addedAt: DateTime(2026, 4, 18),
      lastWatchedAt: DateTime(2026, 4, 18),
      runtimeMinutes: 25,
      image:
          'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Oppenheimer',
      year: '2023',
      type: 'Movies',
      genres: ['Drama', 'History'],
      rating: '8.9',
      userRating: 4.0,
      status: 'Watched',
      progress: 1.0,
      progressLabel: '',
      addedAt: DateTime(2026, 4, 12),
      lastWatchedAt: DateTime(2026, 4, 12),
      runtimeMinutes: 180,
      image:
          'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Breaking Bad',
      year: '2008',
      type: 'Series',
      genres: ['Crime', 'Drama'],
      rating: '9.5',
      userRating: 5.0,
      status: 'Watched',
      progress: 1.0,
      progressLabel: '',
      addedAt: DateTime(2026, 4, 5),
      lastWatchedAt: DateTime(2026, 4, 5),
      runtimeMinutes: 47,
      image:
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Inception',
      year: '2010',
      type: 'Movies',
      genres: ['Sci-Fi', 'Action'],
      rating: '8.8',
      userRating: 5.0,
      status: 'Watched',
      progress: 1.0,
      progressLabel: '',
      addedAt: DateTime(2026, 3, 26),
      lastWatchedAt: DateTime(2026, 3, 26),
      runtimeMinutes: 148,
      image:
          'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Chainsaw Man',
      year: '2022',
      type: 'Anime',
      genres: ['Action'],
      rating: '8.5',
      userRating: 0,
      status: 'Watched',
      progress: 0.0,
      progressLabel: '',
      addedAt: DateTime(2026, 3, 18),
      lastWatchedAt: DateTime(2026, 3, 18),
      runtimeMinutes: 23,
      image:
          'https://images.unsplash.com/photo-1616530940355-351fabd9524b?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'The Dark Knight',
      year: '2008',
      type: 'Movies',
      genres: ['Action', 'Crime'],
      rating: '9.0',
      userRating: 5.0,
      status: 'Watched',
      progress: 1.0,
      progressLabel: '',
      addedAt: DateTime(2026, 2, 22),
      lastWatchedAt: DateTime(2026, 2, 22),
      runtimeMinutes: 152,
      image:
          'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Succession',
      year: '2018',
      type: 'Series',
      genres: ['Drama'],
      rating: '8.9',
      userRating: 0,
      status: 'Dropped',
      progress: 0.3,
      progressLabel: 'S1 · E4 of 10',
      addedAt: DateTime(2026, 2, 9),
      lastWatchedAt: DateTime(2026, 2, 12),
      runtimeMinutes: 60,
      image:
          'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'Parasite',
      year: '2019',
      type: 'Movies',
      genres: ['Thriller'],
      rating: '8.5',
      userRating: 4.5,
      status: 'Watched',
      progress: 1.0,
      progressLabel: '',
      addedAt: DateTime(2026, 1, 28),
      lastWatchedAt: DateTime(2026, 1, 28),
      runtimeMinutes: 132,
      image:
          'https://images.unsplash.com/photo-1574267432553-4b4628081c31?auto=format&fit=crop&w=400&q=80',
    ),
    LibraryItem(
      title: 'True Detective',
      year: '2014',
      type: 'Series',
      genres: ['Crime'],
      rating: '9.0',
      userRating: 0,
      status: 'Dropped',
      progress: 0.2,
      progressLabel: 'S1 · E2 of 8',
      addedAt: DateTime(2026, 1, 14),
      lastWatchedAt: DateTime(2026, 1, 20),
      runtimeMinutes: 55,
      image:
          'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  List<LibraryItem> get _filteredItems {
    return _allItems.where((item) {
      final typeMatch = _selectedType == 'All' || item.type == _selectedType;
      final statusMatch =
          _selectedStatus == 'All' || item.status == _selectedStatus;
      final searchMatch = _searchController.text.isEmpty ||
          item.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return typeMatch && statusMatch && searchMatch;
    }).toList();
  }

  List<LibraryItem> get _sortedItems {
    final items = _filteredItems.toList();

    switch (_selectedSort) {
      case 'Recently watched':
        items.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));
        break;
      case 'Highest rated':
        items.sort((a, b) => _ratingValue(b).compareTo(_ratingValue(a)));
        break;
      case 'Lowest rated':
        items.sort((a, b) => _ratingValue(a).compareTo(_ratingValue(b)));
        break;
      case 'Release date':
        items.sort((a, b) => int.parse(b.year).compareTo(int.parse(a.year)));
        break;
      case 'Alphabetical':
        items.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Runtime':
        items.sort((a, b) => b.runtimeMinutes.compareTo(a.runtimeMinutes));
        break;
      case 'Recently added':
      default:
        items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
    }

    return items;
  }

  double _ratingValue(LibraryItem item) {
    return double.tryParse(item.rating) ?? 0.0;
  }

  void _toggleSortPanel() {
    setState(() => _isSortOpen = !_isSortOpen);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _sortedItems;

    return Container(
      color: WColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  WSizes.screenPadding.w,
                  16.h,
                  WSizes.screenPadding.w,
                  0,
                ),
                child: _LibraryHeader(),
              ),
            ),

            // ── Stats Card ───────────────────────────────────────────
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

            // ── Search Bar ───────────────────────────────────────────
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
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

            // ── Type filter chips ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: _TypeFilterRow(
                  types: _types,
                  selected: _selectedType,
                  onSelected: (t) => setState(() => _selectedType = t),
                ),
              ),
            ),

            // ── Status filter row ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  WSizes.screenPadding.w,
                  10.h,
                  WSizes.screenPadding.w,
                  0,
                ),
                child: _StatusFilterRow(
                  statuses: _statuses,
                  counts: _statusCounts,
                  selected: _selectedStatus,
                  onSelected: (s) => setState(() => _selectedStatus = s),
                ),
              ),
            ),

            // ── Results bar ──────────────────────────────────────────
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
                            style: TextStyle(color: WColors.foreground),
                          ),
                          TextSpan(text: ' results'),
                        ],
                      ),
                      style: TextStyle(
                        color: WColors.mutedSecondary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _SortButton(
                      label: _selectedSort,
                      onTap: _toggleSortPanel,
                    ),
                  ],
                ),
              ),
            ),

            if (_isSortOpen)
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
                      selected: _selectedSort,
                      options: _sortOptions,
                      onSelected: (value) {
                        setState(() {
                          _selectedSort = value;
                          _isSortOpen = false;
                        });
                      },
                    ),
                  ),
                ),
              ),

            // ── Content ──────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: WSizes.screenPadding.w,
              ),
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
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

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
                        color: WColors.foreground,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Library',
                      style: TextStyle(
                        color: WColors.accentRed,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
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
                      color: WColors.mutedSecondary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 3.w,
                    height: 3.w,
                    margin: EdgeInsets.symmetric(horizontal: 7.w),
                    decoration: const BoxDecoration(
                      color: WColors.mutedSecondaryDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    '21h total',
                    style: TextStyle(
                      color: WColors.mutedSecondary,
                      fontSize: 13.sp,
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

// ── Search Bar ───────────────────────────────────────────────────────────────

class _LibrarySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _LibrarySearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(
              color: WColors.foreground,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: WColors.foreground,
            cursorWidth: 1.w,
            decoration: InputDecoration(
              hintText: 'Search your library...',
              hintStyle: TextStyle(
                color: WColors.mutedSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: WColors.mutedSecondary,
                size: 20.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: WColors.borderStrong),
              ),
              isDense: true,
              fillColor: WColors.surfaceRaised.withValues(alpha: 0.7),
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide:
                    BorderSide(color: WColors.accentRed.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Type Filter Row ──────────────────────────────────────────────────────────

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
                color: isSelected ? WColors.accentRed : null,
                gradient: isSelected
                    ? null
                    : LinearGradient(
                        colors: [
                          WColors.surfaceRaised,
                          WColors.surfaceRaised.withValues(alpha: .4),
                          WColors.surface,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : WColors.borderStrong,
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
                            : WColors.mutedForeground),
                    SizedBox(width: 5.w),
                  ],
                  Text(
                    t,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : WColors.mutedForeground,
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

// ── Status Filter Row ────────────────────────────────────────────────────────

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
            WColors.surfaceRaised,
            WColors.surfaceRaised.withValues(alpha: .4)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(Radius.elliptical(22.r, 24.r)),
        border: Border.all(color: WColors.borderStrong),
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
                      ? WColors.accentRed.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.elliptical(16.r, 18.r)),
                  border: isSelected
                      ? Border.all(
                          color: WColors.accentRed.withValues(alpha: 0.5),
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: WColors.accentRed.withValues(alpha: 0.1),
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
                          ? WColors.accentRed
                          : WColors.mutedSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      s,
                      style: TextStyle(
                        color: isSelected
                            ? WColors.foreground
                            : WColors.mutedSecondary,
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

// ── Sort Button ──────────────────────────────────────────────────────────────

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
          color: WColors.surfaceRaised,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: WColors.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert_rounded,
                size: 15.sp, color: WColors.mutedSecondaryVibe),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                color: WColors.mutedSecondaryVibe,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 15.sp, color: WColors.mutedSecondary),
          ],
        ),
      ),
    );
  }
}

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
            WColors.surfaceRaised,
            WColors.surfaceRaised.withValues(alpha: .5)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: WColors.borderStrong),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort by',
            style: TextStyle(
              color: WColors.mutedSecondary,
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
                              ? WColors.accentRed.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999.r),
                          border: Border.all(
                            color: isSelected
                                ? WColors.accentRed.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected) ...[
                              Icon(
                                Icons.check_rounded,
                                size: 14.sp,
                                color: WColors.accentRed,
                              ),
                              SizedBox(width: 6.w),
                            ],
                            Flexible(
                              child: Text(
                                option,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected
                                      ? WColors.foreground
                                      : WColors.mutedSecondary,
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

// ── Data Model ───────────────────────────────────────────────────────────────

class LibraryItem {
  final String title;
  final String year;
  final String type;
  final List<String> genres;
  final String rating;
  final double userRating;
  final String status;
  final double progress;
  final String progressLabel;
  final DateTime addedAt;
  final DateTime lastWatchedAt;
  final int runtimeMinutes;
  final String image;

  const LibraryItem({
    required this.title,
    required this.year,
    required this.type,
    required this.genres,
    required this.rating,
    required this.userRating,
    required this.status,
    required this.progress,
    required this.progressLabel,
    required this.addedAt,
    required this.lastWatchedAt,
    required this.runtimeMinutes,
    required this.image,
  });
}
