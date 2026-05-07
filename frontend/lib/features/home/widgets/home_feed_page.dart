import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/common/widgets/buttons/action_button.dart';
import 'package:watchary/common/widgets/cards/horizontal_progress_card.dart';
import 'package:watchary/common/widgets/cards/vertical_poster_card.dart';
import 'package:watchary/common/widgets/section_header.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/features/home/screens/movie_details.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  String? _selectedMood;

  static const _heroImage =
      'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=1200&q=80';

  static const _profileImage =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80';

  final List<_MoviePoster> _trending = const [
    _MoviePoster(
      title: 'Inception',
      rating: '8.8',
      image:
          'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=700&q=80',
    ),
    _MoviePoster(
      title: 'The Dark Knight',
      rating: '9',
      image:
          'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
    _MoviePoster(
      title: 'Dune: Part Two',
      rating: '8.7',
      image:
          'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=700&q=80',
    ),
  ];

  final List<_MoviePoster> _recommended = const [
    _MoviePoster(
      title: 'Everything Everywhere All ...',
      rating: '7.8',
      image:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=700&q=80',
    ),
    _MoviePoster(
      title: 'Parasite',
      rating: '8.5',
      image:
          'https://images.unsplash.com/photo-1505685296765-3a2736de412f?auto=format&fit=crop&w=700&q=80',
    ),
    _MoviePoster(
      title: 'The Batman',
      rating: '7.9',
      image:
          'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=700&q=80',
    ),
  ];

  final List<_MoodOption> _moods = const [
    _MoodOption(label: 'Emotional', emoji: '🥲'),
    _MoodOption(label: 'Mind-Blown', emoji: '🤯'),
    _MoodOption(label: 'Scared', emoji: '😱'),
  ];

  final List<_ContinueWatchingItem> _continueWatching = const [
    _ContinueWatchingItem(
      title: 'The Dark Knight',
      progressLabel: '68% watched',
      progress: 0.68,
      image:
          'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ),
  ];

  void _selectMood(String label) {
    setState(() {
      _selectedMood = _selectedMood == label ? null : label;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: WColors.background,
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            WSizes.screenPadding.w,
            6.h,
            WSizes.screenPadding.w,
            124.h,
          ),
          physics: const BouncingScrollPhysics(),
          children: [
            _Header(profileImage: _profileImage),
            SizedBox(height: 14.h),
            _HeroCard(
              image: _heroImage,
              onDetailsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MovieDetailsScreen(
                      movieTitle: 'Inception',
                      movieImage:
                          'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=1200&q=80',
                      rating: '8.8',
                    ),
                  ),
                );
              },
              onWatchlistPressed: () {},
            ),
            SizedBox(height: 22.h),
            const WSectionHeader(
              icon: Icons.access_time_rounded,
              iconColor: WColors.warning,
              title: 'Continue Watching',
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 112.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _continueWatching.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final item = _continueWatching[index];
                  return HorizontalProgressCard(
                    image: item.image,
                    title: item.title,
                    progressLabel: item.progressLabel,
                    progress: item.progress,
                    width: 168.w,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(
                            movieTitle: item.title,
                            movieImage: item.image,
                            rating: '8.8',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            const WSectionHeader(
              icon: Icons.local_fire_department_rounded,
              iconColor: WColors.accentRed,
              title: 'Trending Now',
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 218.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _trending.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final item = _trending[index];
                  return VerticalPosterCard(
                    image: item.image,
                    width: 104.w,
                    title: item.title,
                    rating: item.rating,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(
                            movieTitle: item.title,
                            movieImage: item.image,
                            rating: item.rating,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 18.h),
            _MoodPickerCard(
              selectedMood: _selectedMood,
              moods: _moods,
              onSelected: _selectMood,
            ),
            SizedBox(height: 18.h),
            const WSectionHeader(
              icon: Icons.star_rounded,
              iconColor: WColors.tertiary,
              title: 'Recommended',
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 218.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _recommended.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final item = _recommended[index];
                  return VerticalPosterCard(
                    image: item.image,
                    width: 104.w,
                    title: item.title,
                    rating: item.rating,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(
                            movieTitle: item.title,
                            movieImage: item.image,
                            rating: item.rating,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String profileImage;

  const _Header({required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: WColors.accentRedSoft, width: 2),
            image: DecorationImage(
              image: NetworkImage(profileImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good evening',
              style: TextStyle(
                color: WColors.mutedForeground,
                fontSize: 13.sp,
                height: 1.1,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Hey, Ikram 👋',
              style: TextStyle(
                color: WColors.foreground,
                fontSize: 20.sp,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.elliptical(16, 18)),
                color: WColors.surfaceMuted,
                border: Border.all(color: WColors.borderStrong),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: WColors.foreground,
                size: 21.sp,
              ),
            ),
            Positioned(
              right: 11.w,
              top: 11.w,
              child: Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: WColors.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String image;
  final VoidCallback onDetailsPressed;
  final VoidCallback onWatchlistPressed;

  const _HeroCard({
    required this.image,
    required this.onDetailsPressed,
    required this.onWatchlistPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 284.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: WColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 26,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.34),
                    Colors.black.withValues(alpha: 0.80),
                  ],
                  stops: const [0.0, 0.60, 1.0],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: WColors.accentRed,
                        borderRadius: BorderRadius.circular(999.r),
                        boxShadow: [
                          BoxShadow(
                            color: WColors.accentRed.withValues(alpha: 0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              size: 13.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'TRENDING #1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: WColors.tertiary, size: 16.sp),
                      SizedBox(width: 3.w),
                      Text(
                        '8.8',
                        style: TextStyle(
                          color: WColors.tertiary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Sci-Fi',
                        style: TextStyle(
                          color: WColors.mutedSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Action',
                        style: TextStyle(
                          color: WColors.mutedSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '2h 28m',
                        style: TextStyle(
                          color: WColors.mutedSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Inception',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: WActionButton(
                          label: 'Details',
                          icon: Icons.play_arrow_rounded,
                          filled: true,
                          onTap: onDetailsPressed,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: WActionButton(
                          label: 'Watchlist',
                          icon: Icons.add_rounded,
                          filled: false,
                          onTap: onWatchlistPressed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodPickerCard extends StatelessWidget {
  final String? selectedMood;
  final List<_MoodOption> moods;
  final ValueChanged<String> onSelected;

  const _MoodPickerCard({
    required this.selectedMood,
    required this.moods,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final showPick = selectedMood == 'Emotional';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: WColors.surfaceMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: WColors.surfaceBorderAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [WColors.accentPurple, WColors.accentPink],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 17.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Mood Picker',
                    style: TextStyle(
                      color: WColors.foreground,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "What's your vibe tonight?",
                    style: TextStyle(
                      color: WColors.mutedSecondaryDeep,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: moods.map((mood) {
              final selected = selectedMood == mood.label;
              return _MoodChip(
                text: '${mood.emoji} ${mood.label}',
                selected: selected,
                onTap: () => onSelected(mood.label),
              );
            }).toList(),
          ),
          if (showPick) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: WColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: WColors.surfaceBorderAlt),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 54.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?auto=format&fit=crop&w=400&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Pick for you',
                          style: TextStyle(
                            color: WColors.mutedSecondaryHighlight,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Oppenheimer',
                          style: TextStyle(
                            color: WColors.foreground,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: WColors.tertiary,
                              size: 13.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '8.3',
                              style: TextStyle(
                                color: WColors.tertiary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Drama',
                              style: TextStyle(
                                color: WColors.mutedSecondaryAlt,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: WColors.accentRed,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'View',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? WColors.accentRed : WColors.surfaceChip,
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected ? Colors.transparent : WColors.surfaceChipBorder,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : WColors.mutedSecondaryVibe,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoviePoster {
  final String title;
  final String rating;
  final String image;

  const _MoviePoster({
    required this.title,
    required this.rating,
    required this.image,
  });
}

class _MoodOption {
  final String label;
  final String emoji;

  const _MoodOption({required this.label, required this.emoji});
}

class _ContinueWatchingItem {
  final String title;
  final String progressLabel;
  final double progress;
  final String image;

  const _ContinueWatchingItem({
    required this.title,
    required this.progressLabel,
    required this.progress,
    required this.image,
  });
}
