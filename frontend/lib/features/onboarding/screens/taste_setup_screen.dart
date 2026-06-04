import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/features/onboarding/screens/taste_setup_success_screen.dart';

class TasteSetupScreen extends StatefulWidget {
  const TasteSetupScreen({super.key});

  @override
  State<TasteSetupScreen> createState() => _TasteSetupScreenState();
}

class _TasteSetupScreenState extends State<TasteSetupScreen> {
  late final PageController _pageController;
  int _currentStep = 0;
  static const int _totalSteps = 5;

  final Set<String> _selectedContentTypes = {};
  final Set<String> _selectedGenres = {};
  final Set<String> _selectedLanguages = {};
  final Set<String> _selectedPlatforms = {};
  // final List<String> _selectedActors = [];
  // final List<String> _selectedDirectors = [];
  final TextEditingController _actorController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  // String _actorQuery = '';
  // String _directorQuery = '';

  static const _contentTypes = [
    {
      'key': 'Movies',
      'title': 'Movies',
      'subtitle': 'Feature films from\naround the world',
      'useEmoji': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=450&q=80',
    },
    {
      'key': 'Web Series',
      'title': 'Web Series',
      'subtitle': 'Binge-worthy episodic\nstorytelling',
      'useEmoji': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?auto=format&fit=crop&w=450&q=80',
    },
    {
      'key': 'Anime',
      'title': 'Anime',
      'subtitle': 'Japanese animation &\nmanga adaptations',
      'useEmoji': true,
      'imageUrl':
          'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=450&q=80',
    },
    {
      'key': 'Documentaries',
      'title': 'Documentaries',
      'subtitle': 'Real stories from\nthe real world',
      'useEmoji': false,
      'imageUrl':
          'https://images.unsplash.com/photo-1470115636492-6d2b56f9146d?auto=format&fit=crop&w=450&q=80',
    },
  ];

  static const _genres = [
    {'key': 'Action', 'emoji': '💥'},
    {'key': 'Thriller', 'emoji': '🔪'},
    {'key': 'Sci-Fi', 'emoji': '🚀'},
    {'key': 'Comedy', 'emoji': '😂'},
    {'key': 'Romance', 'emoji': '❤️'},
    {'key': 'Horror', 'emoji': '👻'},
    {'key': 'Drama', 'emoji': '🎭'},
    {'key': 'Mystery', 'emoji': '🔍'},
    {'key': 'Fantasy', 'emoji': '🧙'},
    {'key': 'Crime', 'emoji': '🦹'},
    {'key': 'Adventure', 'emoji': '🌍'},
    {'key': 'Animation', 'emoji': '✨'},
  ];

  static const _languages = [
    {
      'key': 'English',
      'emoji': '🇺🇸',
      'imageUrl':
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&w=300&q=80',
    },
    {
      'key': 'Hindi',
      'emoji': '🇮🇳',
      'imageUrl':
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=300&q=80',
    },
    {
      'key': 'Japanese',
      'emoji': '🇯🇵',
      'imageUrl':
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=300&q=80',
    },
    {
      'key': 'Korean',
      'emoji': '🇰🇷',
      'imageUrl':
          'https://images.unsplash.com/photo-1517154421773-0529f29ea451?auto=format&fit=crop&w=300&q=80',
    },
    {
      'key': 'Tamil',
      'emoji': '🏳️',
      'imageUrl':
          'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=300&q=80',
    },
    {
      'key': 'Telugu',
      'emoji': '🏳️',
      'imageUrl':
          'https://images.unsplash.com/photo-1577114995803-d8ce0e2b4aa9?auto=format&fit=crop&w=300&q=80',
    },
    {
      'key': 'Malayalam',
      'emoji': '🏳️',
      'imageUrl':
          'https://images.unsplash.com/photo-1514222134-b57cbb8ce073?auto=format&fit=crop&w=300&q=80',
    },
    {
      'key': 'Marathi',
      'emoji': '🏳️',
      'imageUrl':
          'https://images.unsplash.com/photo-1529528570282-4c0a8c15556c?auto=format&fit=crop&w=300&q=80',
    },
    {
      'key': 'Other',
      'emoji': '🌐',
      'imageUrl':
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=300&q=80',
    },
  ];

  static const _platforms = [
    {'key': 'Netflix', 'abbr': 'N', 'color': Color(0xFFE50914)},
    {'key': 'Prime Video', 'abbr': 'P', 'color': Color(0xFF00A8E1)},
    {'key': 'Disney+', 'abbr': 'D+', 'color': Color(0xFF1F318C)},
    {'key': 'Crunchyroll', 'abbr': 'CR', 'color': Color(0xFFF47521)},
    {'key': 'JioHotstar', 'abbr': 'HS', 'color': Color(0xFF1A3CB5)},
    {'key': 'SonyLIV', 'abbr': 'SL', 'color': Color(0xFF0070C0)},
    {'key': 'ZEE5', 'abbr': 'Z5', 'color': Color(0xFF8B5CF6)},
    {'key': 'Apple TV+', 'abbr': 'A+', 'color': Color(0xFF555555)},
    {'key': 'Mubi', 'abbr': 'M', 'color': Color(0xFF33BBFF)},
  ];

  // static const _actorSuggestions = [
  //   'Leonardo DiCaprio',
  //   'Tom Hanks',
  //   'Priyanka Chopra',
  //   'Shah Rukh Khan',
  //   'Robert Downey Jr.',
  //   'Deepika Padukone',
  // ];

  // static const _directorSuggestions = [
  //   'Christopher Nolan',
  //   'Rajkumar Hirani',
  //   'Quentin Tarantino',
  //   'Sanjay Leela Bhansali',
  //   'Steven Spielberg',
  //   'S. S. Rajamouli',
  // ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // _actorController.addListener(
    //   () => setState(() => _actorQuery = _actorController.text),
    // );
    // _directorController.addListener(
    //   () => setState(() => _directorQuery = _directorController.text),
    // );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _actorController.dispose();
    _directorController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_currentStep == 1) return _selectedGenres.length >= 3;
    return true;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      FocusScope.of(context).unfocus();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      FocusScope.of(context).unfocus();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TasteSetupSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: WColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: WColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: WSizes.xs.h),
              _buildHeader(),
              SizedBox(height: WSizes.xs.h),
              _buildProgressBar(),
              SizedBox(height: WSizes.xs.h),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                    // _buildStep5(),
                    _buildStep5(),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: _prevStep,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: WColors.surfaceRaised,
                  border: Border.all(color: WColors.border),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: WColors.foreground,
                  size: 18.sp,
                ),
              ),
            )
          else
            SizedBox(width: 36.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: WColors.primary,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'My Cinema',
                  style: TextStyle(
                    color: WColors.foreground,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _finish,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                border: Border.all(color: WColors.border),
                color: WColors.card.withValues(alpha: 0.5),
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: WColors.mutedForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
      child: Row(
        children: [
          ...List.generate(_totalSteps, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                height: 3.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99.r),
                  color: i <= _currentStep
                      ? WColors.primary
                      : Colors.white.withAlpha(50),
                ),
              ),
            );
          }),
          SizedBox(width: 6.w),
          Text(
            '${_currentStep + 1}/$_totalSteps',
            style: TextStyle(
              fontSize: 11.sp,
              color: WColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel({
    required String label,
    bool optional = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: WColors.primary,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        if (optional) ...[
          SizedBox(width: WSizes.sm.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
              color: WColors.surfaceRaised,
              border: Border.all(color: WColors.border),
            ),
            child: Text(
              'Optional',
              style: TextStyle(
                color: WColors.mutedForeground,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepHeader({
    required String label,
    required String title,
    required String subtitle,
    bool optional = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        WSizes.md.w,
        WSizes.md.h,
        WSizes.md.w,
        WSizes.sm.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepLabel(label: label, optional: optional),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(
              color: WColors.foreground,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              color: WColors.mutedForeground,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Content Types ───────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          label: 'STEP 1',
          title: 'What do you love\nwatching?',
          subtitle: 'Choose one or more content types.',
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(WSizes.md.w),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: WSizes.sm.w,
              mainAxisSpacing: WSizes.sm.h,
              childAspectRatio: 1.35,
              children: _contentTypes.map((item) {
                final key = item['key'] as String;
                final isSelected = _selectedContentTypes.contains(key);
                return _ContentTypeCard(
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  useEmoji: item['useEmoji'] as bool,
                  imageUrl: item['imageUrl'] as String,
                  icon: _contentTypeIcon(key),
                  isSelected: isSelected,
                  onTap: () => setState(() {
                    isSelected
                        ? _selectedContentTypes.remove(key)
                        : _selectedContentTypes.add(key);
                  }),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _contentTypeIcon(String key) {
    switch (key) {
      case 'Movies':
        return Icon(
          Icons.movie_creation_outlined,
          size: 22.sp,
        );
      case 'Web Series':
        return Icon(Icons.tv_outlined, size: 22.sp);
      case 'Anime':
        return Text('⛩️', style: TextStyle(fontSize: 20.sp));
      case 'Documentaries':
        return Icon(Icons.video_camera_back_outlined, size: 22.sp);
      default:
        return Icon(Icons.movie_outlined, size: 22.sp);
    }
  }

  // ─── Step 2: Genres ──────────────────────────────────────────────────────────

  Widget _buildStep2() {
    final remaining = (3 - _selectedGenres.length).clamp(0, 3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          label: 'STEP 2',
          title: 'Pick your genres',
          subtitle: 'Select at least 3',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
            child: Wrap(
              spacing: WSizes.sm.w,
              runSpacing: WSizes.sm.h,
              children: _genres.map((g) {
                final key = g['key'] as String;
                final isSelected = _selectedGenres.contains(key);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected
                        ? _selectedGenres.remove(key)
                        : _selectedGenres.add(key);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                      color: isSelected
                          ? WColors.primary.withAlpha(25)
                          : WColors.surfaceChip,
                      border: Border.all(
                        color: isSelected
                            ? WColors.primary.withAlpha(180)
                            : WColors.surfaceChipBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          g['emoji'] as String,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          key,
                          style: TextStyle(
                            color: isSelected
                                ? WColors.foreground
                                : WColors.mutedSecondaryVibe,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: remaining > 0
              ? Padding(
                  key: const ValueKey('validation'),
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Center(
                    child: Text(
                      'Select $remaining more ${remaining == 1 ? 'genre' : 'genres'} to continue',
                      style: TextStyle(
                        color: WColors.primary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : SizedBox(key: const ValueKey('none'), height: 6.h),
        ),
      ],
    );
  }

  // ─── Step 3: Languages ───────────────────────────────────────────────────────

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          label: 'STEP 3',
          title: 'Languages you enjoy',
          subtitle: 'Select all that apply.',
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(WSizes.md.w),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: WSizes.sm.w,
              mainAxisSpacing: WSizes.sm.h,
              childAspectRatio: 1.05,
              children: _languages.map((lang) {
                final key = lang['key'] as String;
                final imageUrl = lang['imageUrl'] as String;
                final isSelected = _selectedLanguages.contains(key);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected
                        ? _selectedLanguages.remove(key)
                        : _selectedLanguages.add(key);
                  }),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          color: const Color(0xBB000000),
                          colorBlendMode: BlendMode.multiply,
                          errorBuilder: (_, __, ___) =>
                              ColoredBox(color: WColors.surfaceRaised),
                        ),
                        // Subtle vignette from edges
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.transparent,
                                Color(0x88000000),
                              ],
                              radius: 1.1,
                            ),
                          ),
                        ),
                        // Red tint when selected
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          color: isSelected
                              ? WColors.primary.withAlpha(55)
                              : Colors.transparent,
                        ),
                        // Emoji + label centred
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang['emoji'] as String,
                              style: TextStyle(fontSize: 26.sp),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              key,
                              style: TextStyle(
                                color: Colors.white.withAlpha(
                                  isSelected ? 255 : 200,
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        // Animated border
                        Positioned.fill(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(WSizes.radiusXl.r),
                              border: Border.all(
                                color: isSelected
                                    ? WColors.primary.withAlpha(220)
                                    : Colors.white.withAlpha(20),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 4: Platforms ───────────────────────────────────────────────────────

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          label: 'STEP 4',
          title: 'Where do you stream?',
          subtitle: 'Select your active platforms.',
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
            itemCount: _platforms.length,
            separatorBuilder: (_, __) => Divider(
              color: WColors.border,
              height: 1,
            ),
            itemBuilder: (_, i) {
              final item = _platforms[i];
              final key = item['key'] as String;
              final isSelected = _selectedPlatforms.contains(key);
              final color = item['color'] as Color;
              return InkWell(
                onTap: () => setState(() {
                  isSelected
                      ? _selectedPlatforms.remove(key)
                      : _selectedPlatforms.add(key);
                }),
                splashColor: Colors.transparent,
                highlightColor: WColors.surfaceRaised.withAlpha(80),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(WSizes.radiusMd.r),
                          color: color.withAlpha(35),
                          border: Border.all(color: color.withAlpha(80)),
                        ),
                        child: Center(
                          child: Text(
                            item['abbr'] as String,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: WSizes.md.w),
                      Expanded(
                        child: Text(
                          key,
                          style: TextStyle(
                            color: WColors.foreground,
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected ? WColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? WColors.primary
                                : WColors.surfaceTint,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14.sp,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Step 5: Favourite Creators ──────────────────────────────────────────────

  // Widget _buildStep5() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildStepHeader(
  //           label: 'STEP 5',
  //           title: 'Favourite creators',
  //           subtitle: 'Add actors & directors you love.',
  //           optional: true,
  //         ),
  //         _buildCreatorSection(
  //           icon: Icons.person_outline_rounded,
  //           title: 'Favourite Actors',
  //           controller: _actorController,
  //           hint: 'Search actors...',
  //           suggestions: _actorSuggestions,
  //           selected: _selectedActors,
  //           query: _actorQuery,
  //           onToggle: (name) => setState(() {
  //             _selectedActors.contains(name)
  //                 ? _selectedActors.remove(name)
  //                 : _selectedActors.add(name);
  //           }),
  //         ),
  //         SizedBox(height: WSizes.lg.h),
  //         _buildCreatorSection(
  //           icon: Icons.movie_filter_outlined,
  //           title: 'Favourite Directors',
  //           controller: _directorController,
  //           hint: 'Search directors...',
  //           suggestions: _directorSuggestions,
  //           selected: _selectedDirectors,
  //           query: _directorQuery,
  //           onToggle: (name) => setState(() {
  //             _selectedDirectors.contains(name)
  //                 ? _selectedDirectors.remove(name)
  //                 : _selectedDirectors.add(name);
  //           }),
  //         ),
  //         SizedBox(height: 100.h),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCreatorSection({
  //   required IconData icon,
  //   required String title,
  //   required TextEditingController controller,
  //   required String hint,
  //   required List<String> suggestions,
  //   required List<String> selected,
  //   required String query,
  //   required void Function(String) onToggle,
  // }) {
  //   final filtered = query.isEmpty
  //       ? suggestions
  //       : suggestions
  //           .where((s) => s.toLowerCase().contains(query.toLowerCase()))
  //           .toList();

  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(icon, color: WColors.mutedForeground, size: 16.sp),
  //             SizedBox(width: 6.w),
  //             Text(
  //               title,
  //               style: TextStyle(
  //                 color: WColors.foreground,
  //                 fontWeight: FontWeight.w700,
  //                 fontSize: 14.sp,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: WSizes.sm.h),
  //         Container(
  //           height: 44.h,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(WSizes.radiusLg.r),
  //             color: WColors.surfaceRaised,
  //             border: Border.all(color: WColors.border),
  //           ),
  //           child: TextField(
  //             controller: controller,
  //             style: TextStyle(color: WColors.foreground, fontSize: 13.sp),
  //             decoration: InputDecoration(
  //               hintText: hint,
  //               hintStyle: TextStyle(
  //                 color: WColors.mutedForeground,
  //                 fontSize: 13.sp,
  //               ),
  //               prefixIcon: Icon(
  //                 Icons.search_rounded,
  //                 color: WColors.mutedForeground,
  //                 size: 18.sp,
  //               ),
  //               border: InputBorder.none,
  //               contentPadding: EdgeInsets.symmetric(vertical: 12.h),
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: WSizes.sm.h),
  //         Wrap(
  //           spacing: WSizes.sm.w,
  //           runSpacing: WSizes.sm.h,
  //           children: filtered.map((name) {
  //             final isSelected = selected.contains(name);
  //             return GestureDetector(
  //               onTap: () => onToggle(name),
  //               child: AnimatedContainer(
  //                 duration: const Duration(milliseconds: 160),
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: 12.w,
  //                   vertical: 8.h,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
  //                   color: isSelected
  //                       ? WColors.primary.withAlpha(25)
  //                       : WColors.surfaceChip,
  //                   border: Border.all(
  //                     color: isSelected
  //                         ? WColors.primary.withAlpha(180)
  //                         : WColors.surfaceChipBorder,
  //                   ),
  //                 ),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     if (!isSelected)
  //                       Text(
  //                         '+ ',
  //                         style: TextStyle(
  //                           color: WColors.mutedForeground,
  //                           fontSize: 12.sp,
  //                         ),
  //                       ),
  //                     Text(
  //                       name,
  //                       style: TextStyle(
  //                         color: isSelected
  //                             ? WColors.foreground
  //                             : WColors.mutedSecondaryVibe,
  //                         fontWeight: FontWeight.w500,
  //                         fontSize: 12.sp,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ─── Step 5: Review ──────────────────────────────────────────────────────────

  Widget _buildStep5() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            label: 'STEP 5',
            title: 'Your taste profile',
            subtitle: "Everything looks good? Let's go!",
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
            child: Column(
              children: [
                _buildReviewSection(
                  dotColor: WColors.primary,
                  label: 'CONTENT TYPES',
                  chips: _selectedContentTypes.toList(),
                  emptyText: 'Not selected',
                ),
                SizedBox(height: WSizes.sm.h),
                _buildReviewSection(
                  dotColor: WColors.accentPurple,
                  label: 'GENRES',
                  trailing: _selectedGenres.isNotEmpty
                      ? Text(
                          '${_selectedGenres.length} selected',
                          style: TextStyle(
                            color: WColors.mutedForeground,
                            fontSize: 11.sp,
                          ),
                        )
                      : null,
                  chips: _selectedGenres.toList(),
                  emptyText: 'Not selected',
                ),
                SizedBox(height: WSizes.sm.h),
                _buildReviewSection(
                  dotColor: WColors.chartGreen,
                  label: 'LANGUAGES',
                  chips: _selectedLanguages.toList(),
                  emptyText: 'Not selected',
                ),
                SizedBox(height: WSizes.sm.h),
                _buildReviewSection(
                  dotColor: WColors.tertiary,
                  label: 'PLATFORMS',
                  chips: _selectedPlatforms.toList(),
                  emptyText: 'Not selected',
                ),
                SizedBox(height: WSizes.sm.h),
                // _buildReviewSection(
                //   dotColor: WColors.accentPurple,
                //   label: 'FAVOURITE ACTORS',
                //   chips: _selectedActors,
                //   emptyText: 'None added',
                // ),
                // SizedBox(height: WSizes.sm.h),
                // _buildReviewSection(
                //   dotColor: WColors.tertiary,
                //   label: 'FAVOURITE DIRECTORS',
                //   chips: _selectedDirectors,
                //   emptyText: 'None added',
                // ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required Color dotColor,
    required String label,
    required List<String> chips,
    required String emptyText,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(WSizes.md.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
        color: WColors.surfaceRaised.withValues(alpha: 0.8),
        border: Border.all(color: WColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: WColors.mutedSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: WSizes.sm.h),
          chips.isEmpty
              ? Text(
                  emptyText,
                  style: TextStyle(
                    color: WColors.mutedForeground,
                    fontSize: 13.sp,
                  ),
                )
              : Wrap(
                  spacing: WSizes.xs.w,
                  runSpacing: WSizes.xs.h,
                  children: chips.map((text) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(WSizes.radiusFull.r),
                        color: WColors.surfaceChip,
                        border: Border.all(color: WColors.surfaceChipBorder),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: WColors.foreground,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // ─── Bottom Bar ──────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final isLast = _currentStep == _totalSteps - 1;
    final disabled = !_canContinue;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        WSizes.md.w,
        WSizes.sm.h,
        WSizes.md.w,
        WSizes.md.h,
      ),
      child: GestureDetector(
        onTap: disabled ? null : _nextStep,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
            gradient: disabled
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFE63946), Color(0xFFCF2F3B)],
                  ),
            color: disabled ? WColors.surfaceRaised : null,
            border: disabled ? Border.all(color: WColors.border) : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLast ? 'Confirm & Finish' : 'Continue',
                  style: TextStyle(
                    color: disabled ? WColors.mutedForeground : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  color: disabled ? WColors.mutedForeground : Colors.white,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Content Type Card ────────────────────────────────────────────────────────

class _ContentTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool useEmoji;
  final String imageUrl;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContentTypeCard({
    required this.title,
    required this.subtitle,
    required this.useEmoji,
    required this.imageUrl,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image darkened via multiply blend
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              color: const Color(0xBB000000),
              colorBlendMode: BlendMode.multiply,
              errorBuilder: (_, __, ___) =>
                  ColoredBox(color: WColors.surfaceRaised),
            ),
            // Bottom gradient so text is always legible
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xF0141418)],
                  stops: [0.15, 1.0],
                ),
              ),
            ),
            // Red tint overlay when selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              color: isSelected
                  ? WColors.primary.withAlpha(50)
                  : Colors.transparent,
            ),
            // Card content
            Padding(
              padding: EdgeInsets.all(WSizes.md.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(WSizes.radiusMd.r),
                      color: isSelected
                          ? WColors.primary.withAlpha(60)
                          : Colors.white.withAlpha(18),
                      border: Border.all(
                        color: Colors.white.withAlpha(20),
                      ),
                    ),
                    child: Center(
                      child: IconTheme(
                        data: IconThemeData(
                          color: isSelected
                              ? Colors.white
                              : WColors.mutedSecondaryVibe,
                        ),
                        child: icon,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(160),
                      fontSize: 10.sp,
                      height: 1.3,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            // Animated border on top of everything
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
                  border: Border.all(
                    color: isSelected
                        ? WColors.primary.withAlpha(220)
                        : Colors.white.withAlpha(20),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
