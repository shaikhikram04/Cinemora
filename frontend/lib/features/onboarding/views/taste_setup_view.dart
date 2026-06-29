import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/progress_bars/page_view_progress_bar.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/onboarding/viewmodels/onboarding_cubit.dart';
import 'package:cinemora/features/onboarding/viewmodels/onboarding_state.dart';
import 'package:cinemora/core/constants/assets_path.dart';
import 'package:cinemora/features/onboarding/widgets/content_type_card.dart';

// ── Static configuration data (not business state) ────────────────────────────

const _kContentTypes = [
  {
    'key': 'movies',
    'title': 'Movies',
    'subtitle': 'Feature films from\naround the world',
    'imageUrl':
        'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=450&q=80',
  },
  {
    'key': 'series',
    'title': 'Web Series',
    'subtitle': 'Binge-worthy episodic\nstorytelling',
    'imageUrl':
        'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?auto=format&fit=crop&w=450&q=80',
  },
  {
    'key': 'anime',
    'title': 'Anime',
    'subtitle': 'Japanese animation &\nmanga adaptations',
    'imageUrl':
        'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=450&q=80',
  },
  {
    'key': 'documentaries',
    'title': 'Documentaries',
    'subtitle': 'Real stories from\nthe real world',
    'imageUrl':
        'https://images.unsplash.com/photo-1470115636492-6d2b56f9146d?auto=format&fit=crop&w=450&q=80',
  },
];

const _kGenres = [
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

const _kLanguages = [
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

const _kPlatforms = [
  {'key': 'Netflix', 'image': AppImages.netflix, 'color': Color(0xFFE50914)},
  {'key': 'Prime Video', 'image': AppImages.amazonPrimeVideo, 'color': Color(0xFF00A8E1)},
  {'key': 'Disney+', 'image': AppImages.disneyPlus, 'color': Color(0xFF1F318C)},
  {'key': 'Crunchyroll', 'image': AppImages.crunchyroll, 'color': Color(0xFFF47521)},
  {'key': 'JioHotstar', 'image': AppImages.jioHotstar, 'color': Color(0xFF1A3CB5)},
  {'key': 'SonyLIV', 'image': AppImages.sonyLiv, 'color': Color(0xFF0070C0)},
  {'key': 'ZEE5', 'image': AppImages.zee5, 'color': Color(0xFF8B5CF6)},
  {'key': 'Apple TV+', 'image': AppImages.appleTv, 'color': Color(0xFF555555)},
  {'key': 'Mubi', 'image': AppImages.mubi, 'color': Color(0xFF33BBFF)},
];

// ── Entry point — provides OnboardingCubit ─────────────────────────────────────

class TasteSetupView extends StatelessWidget {
  const TasteSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(context.read<UserRepository>()),
      child: const _TasteSetupContent(),
    );
  }
}

// ── Holds PageController (UI-only) and reacts to OnboardingState ───────────────

class _TasteSetupContent extends StatefulWidget {
  const _TasteSetupContent();

  @override
  State<_TasteSetupContent> createState() => _TasteSetupContentState();
}

class _TasteSetupContentState extends State<_TasteSetupContent> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (prev, curr) =>
          prev.currentStep != curr.currentStep ||
          prev.submitSuccess != curr.submitSuccess ||
          prev.submitError != curr.submitError,
      listener: (context, state) {
        if (_pageController.page?.round() != state.currentStep) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        if (state.submitSuccess) {
          context.read<AppAuthCubit>().markOnboarded();
          context.go(AppRoutes.onboardingSuccess);
        }
        if (state.submitError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError!, style: TextStyle(fontSize: 14.sp)),
              backgroundColor: context.colors.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: context.colors.background,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: context.colors.background,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: WSizes.sm.h),
                  PageViewProgressBar(
                    totalPages: OnboardingCubit.totalSteps,
                    currentPage: state.currentStep,
                    showBackButton: true,
                    onBack: () {
                      FocusScope.of(context).unfocus();
                      cubit.prevStep();
                    },
                  ),
                  SizedBox(height: WSizes.sm.h),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: cubit.stepChanged,
                      children: [
                        _buildStep1(state, cubit),
                        _buildStep2(state, cubit),
                        _buildStep3(state, cubit),
                        _buildStep4(state, cubit),
                        _buildStep5(state),
                      ],
                    ),
                  ),
                  _buildBottomBar(context, state, cubit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Shared step header ────────────────────────────────────────────────────────

  Widget _buildStepHeader({
    required String label,
    required String title,
    required String subtitle,
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
          Text(
            label,
            style: TextStyle(
              color: context.colors.primary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(color: context.colors.mutedForeground, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  // ── Shared validation hint ────────────────────────────────────────────────────

  Widget _buildValidationHint({required bool show, required String message}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: show
          ? Padding(
              key: const ValueKey('hint'),
              padding: EdgeInsets.only(bottom: 6.h),
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(
                    color: context.colors.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : SizedBox(key: const ValueKey('none'), height: 6.h),
    );
  }

  // ── Step 1: Content Types ─────────────────────────────────────────────────────

  Widget _buildStep1(OnboardingState state, OnboardingCubit cubit) {
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
              children: _kContentTypes.map((item) {
                final key = item['key'] as String;
                return ContentTypeCard(
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  imageUrl: item['imageUrl'] as String,
                  icon: _contentTypeIcon(key),
                  isSelected: state.isContentTypeSelected(key),
                  onTap: () => cubit.toggleContentType(key),
                );
              }).toList(),
            ),
          ),
        ),
        _buildValidationHint(
          show: state.selectedContentTypes.isEmpty,
          message: 'Select at least 1 content type to continue',
        ),
      ],
    );
  }

  Widget _contentTypeIcon(String key) {
    switch (key) {
      case 'movies':
        return Icon(Icons.movie_creation_outlined, size: 22.sp);
      case 'series':
        return Icon(Icons.tv_outlined, size: 22.sp);
      case 'anime':
        return Text('⛩️', style: TextStyle(fontSize: 20.sp));
      case 'documentaries':
        return Icon(Icons.video_camera_back_outlined, size: 22.sp);
      default:
        return Icon(Icons.movie_outlined, size: 22.sp);
    }
  }

  // ── Step 2: Genres ────────────────────────────────────────────────────────────

  Widget _buildStep2(OnboardingState state, OnboardingCubit cubit) {
    final remaining = (3 - state.selectedGenres.length).clamp(0, 3);
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
              children: _kGenres.map((g) {
                final key = g['key'] as String;
                final isSelected = state.isGenreSelected(key);
                return GestureDetector(
                  onTap: () => cubit.toggleGenre(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                      color: isSelected
                          ? context.colors.primary.withAlpha(25)
                          : context.colors.surfaceChip,
                      border: Border.all(
                        color: isSelected
                            ? context.colors.primary.withAlpha(180)
                            : context.colors.surfaceChipBorder,
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
                                ? context.colors.foreground
                                : context.colors.mutedSecondaryVibe,
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
        _buildValidationHint(
          show: remaining > 0,
          message:
              'Select $remaining more ${remaining == 1 ? 'genre' : 'genres'} to continue',
        ),
      ],
    );
  }

  // ── Step 3: Languages ─────────────────────────────────────────────────────────

  Widget _buildStep3(OnboardingState state, OnboardingCubit cubit) {
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
              children: _kLanguages.map((lang) {
                final key = lang['key'] as String;
                final isSelected = state.isLanguageSelected(key);
                return GestureDetector(
                  onTap: () => cubit.toggleLanguage(key),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(WSizes.radiusXl.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          lang['imageUrl'] as String,
                          fit: BoxFit.cover,
                          color: const Color(0xBB000000),
                          colorBlendMode: BlendMode.multiply,
                          errorBuilder: (_, __, ___) =>
                              ColoredBox(color: context.colors.surfaceRaised),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Colors.transparent, Color(0x88000000)],
                              radius: 1.1,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          color: isSelected
                              ? context.colors.primary.withAlpha(55)
                              : Colors.transparent,
                        ),
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
                                color: Colors.white
                                    .withAlpha(isSelected ? 255 : 200),
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Positioned.fill(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(WSizes.radiusXl.r),
                              border: Border.all(
                                color: isSelected
                                    ? context.colors.primary.withAlpha(220)
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
        _buildValidationHint(
          show: state.selectedLanguages.isEmpty,
          message: 'Select at least 1 language to continue',
        ),
      ],
    );
  }

  // ── Step 4: Platforms ─────────────────────────────────────────────────────────

  Widget _buildStep4(OnboardingState state, OnboardingCubit cubit) {
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
            itemCount: _kPlatforms.length,
            separatorBuilder: (_, __) =>
                Divider(color: context.colors.border, height: 1),
            itemBuilder: (_, i) {
              final item = _kPlatforms[i];
              final key = item['key'] as String;
              final isSelected = state.isPlatformSelected(key);
              final color = item['color'] as Color;
              return InkWell(
                onTap: () => cubit.togglePlatform(key),
                splashColor: Colors.transparent,
                highlightColor: context.colors.surfaceRaised.withAlpha(80),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(WSizes.radiusMd.r),
                          color: context.colors.surfaceRaised,
                          border: Border.all(
                            color: isSelected
                                ? color.withAlpha(180)
                                : context.colors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(WSizes.radiusMd.r - 1),
                          child: Image.asset(
                            item['image'] as String,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: WSizes.md.w),
                      Expanded(
                        child: Text(
                          key,
                          style: TextStyle(
                            color: context.colors.foreground,
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
                              isSelected ? context.colors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.surfaceTint,
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
        _buildValidationHint(
          show: state.selectedPlatforms.isEmpty,
          message: 'Select at least 1 platform to continue',
        ),
      ],
    );
  }

  // ── Step 5: Review ────────────────────────────────────────────────────────────

  Widget _buildStep5(OnboardingState state) {
    final divider = Divider(color: context.colors.border, height: 1, thickness: 1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            label: 'STEP 5',
            title: 'Your taste profile',
            subtitle: "Everything looks good? Let's go!",
          ),
          SizedBox(height: WSizes.xs.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewSection(
                  dotColor: context.colors.primary,
                  label: 'CONTENT TYPES',
                  chips: state.selectedContentTypes,
                ),
                divider,
                _buildReviewSection(
                  dotColor: context.colors.accentPurple,
                  label: 'GENRES',
                  chips: state.selectedGenres,
                  count: state.selectedGenres.isNotEmpty
                      ? state.selectedGenres.length
                      : null,
                ),
                divider,
                _buildReviewSection(
                  dotColor: context.colors.chartGreen,
                  label: 'LANGUAGES',
                  chips: state.selectedLanguages,
                ),
                divider,
                _buildReviewSection(
                  dotColor: context.colors.tertiary,
                  label: 'PLATFORMS',
                  chips: state.selectedPlatforms,
                ),
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
    int? count,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: WSizes.md.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: context.colors.mutedSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              if (count != null) ...[
                const Spacer(),
                Text(
                  '$count selected',
                  style: TextStyle(
                    color: context.colors.mutedForeground,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          chips.isEmpty
              ? Text(
                  'Skipped',
                  style: TextStyle(
                    color: context.colors.mutedForeground.withAlpha(120),
                    fontSize: 13.sp,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Wrap(
                  spacing: WSizes.xs.w,
                  runSpacing: WSizes.xs.h,
                  children: chips.map((text) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
                        color: dotColor.withAlpha(18),
                        border: Border.all(color: dotColor.withAlpha(55)),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: context.colors.foreground,
                          fontSize: 12.sp,
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

  // ── Bottom bar ────────────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final isLast = state.currentStep == OnboardingCubit.totalSteps - 1;
    final disabled = !state.canContinue || state.isSubmitting;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        WSizes.md.w,
        WSizes.sm.h,
        WSizes.md.w,
        WSizes.md.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: disabled
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    if (isLast) {
                      cubit.submitPreferences();
                    } else {
                      cubit.nextStep();
                    }
                  },
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
                color: disabled ? context.colors.surfaceRaised : null,
                border: disabled ? Border.all(color: context.colors.border) : null,
              ),
              child: Center(
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? 'Confirm & Finish' : 'Continue',
                            style: TextStyle(
                              color: disabled
                                  ? context.colors.mutedForeground
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            isLast
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: disabled
                                ? context.colors.mutedForeground
                                : Colors.white,
                            size: 18.sp,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (!isLast) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                cubit.skipCurrentStep();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Text(
                  'Skip this step',
                  style: TextStyle(
                    color: context.colors.mutedForeground.withValues(alpha: 0.6),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
