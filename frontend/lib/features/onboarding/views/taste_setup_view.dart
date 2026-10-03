import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemora/common/widgets/progress_bars/page_view_progress_bar.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/network_images_path.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/constants/taste_options.dart';
import 'package:cinemora/core/repositories/user_repository.dart';
import 'package:cinemora/core/router/app_routes.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/onboarding/viewmodels/onboarding_cubit.dart';
import 'package:cinemora/features/onboarding/viewmodels/onboarding_state.dart';
import 'package:cinemora/features/tour/viewmodels/tour_cubit.dart';
import 'package:cinemora/core/utils/image_preloader.dart';

// ── Static configuration data (not business state) ────────────────────────────

// Genres come from TasteOptions so this screen and Edit Profile can never
// offer different sets — see the note in taste_options.dart.
const _kGenres = TasteOptions.genres;

// Each language is marked by a letter from its own script, not by a flag.
//
// Flags were wrong twice over: a language isn't a country — 🇺🇸 for English
// tells a British or Indian user this app wasn't built with them in mind — and
// the four Indian regional languages had no flag to fall back on, so they all
// got the plain white 🏳️. A white flag reads as surrender, and it landed on
// exactly the audience least well served by the rest of this list. A glyph
// works for every language on earth, needs no fallback, and inherits the
// tile's text colour instead of fighting it with an emoji palette.
const _kLanguages = [
  {
    'key': 'English',
    'glyph': 'Aa',
    'imageUrl': NetworkImagesPath.inceptionPoster,
  },
  {
    'key': 'Hindi',
    'glyph': 'हि',
    'imageUrl': NetworkImagesPath.theFamiliManPoster,
  },
  {
    'key': 'Japanese',
    'glyph': 'あ',
    'imageUrl': NetworkImagesPath.myHeroAcedemiaPoster,
  },
  {
    'key': 'Korean',
    'glyph': '한',
    'imageUrl': NetworkImagesPath.oldboyPoster,
  },
  {
    'key': 'Tamil',
    'glyph': 'த',
    'imageUrl': NetworkImagesPath.jailerPoster,
  },
  {
    'key': 'Telugu',
    'glyph': 'తె',
    'imageUrl': NetworkImagesPath.bahubaliPoster,
  },
  {
    'key': 'Malayalam',
    'glyph': 'മ',
    'imageUrl': NetworkImagesPath.bramayugamPoster,
  },
  {
    'key': 'Marathi',
    'glyph': 'म',
    'imageUrl': NetworkImagesPath.sairatPoster,
  },
  {
    'key': 'Other',
    'glyph': '⋯',
    'imageUrl': NetworkImagesPath.globePoster,
  },
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
  bool _hasPreloaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasPreloaded) return;
    _hasPreloaded = true;
    _preloadLaterSteps();
  }

  /// Warms the artwork for the steps ahead while the user works through step 1.
  ///
  /// Step 3's language grid is the reason this exists: nine posters mount at
  /// once, and without a warm cache they arrive as a visible cascade. Step 1's
  /// own three content-type posters are excluded — they're already loading as
  /// this runs.
  ///
  /// These render through a plain `Image.network` with no resize, so bare
  /// providers are the matching cache keys here. Posters drawn by PosterImage
  /// are not — those need `PosterImage.providerFor`.
  void _preloadLaterSteps() {
    precacheImages(context, [
      for (final language in _kLanguages)
        NetworkImage(language['imageUrl'] as String),
    ]);
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
          // Prefer the saved user over flipping the flag by hand: the same
          // request that set isOnboarded also stored the selections, and this
          // is the only copy carrying them. markOnboarded() alone would leave
          // the session on the sign-in payload, whose preferences are empty —
          // which is what made Edit Profile fall back to its placeholder
          // genres and languages right after onboarding.
          //
          // isOnboarded is forced rather than trusted from the response: the
          // server does set it on this same request, but reaching this line is
          // itself proof onboarding is done, and a false flag sneaking through
          // would both bounce the router back here and get written to the
          // offline cache by updateUser.
          final saved = state.submittedUser;
          final authCubit = context.read<AppAuthCubit>();
          if (saved != null) {
            authCubit.updateUser(saved.copyWith(isOnboarded: true));
          } else {
            authCubit.markOnboarded();
          }
          // Only a freshly created account reaches this line, which is what
          // makes it the right place to unlock the first-run tour — a returning
          // user signing in on a new phone skips onboarding entirely. Arming
          // is not starting: the tour waits for the user to settle on the home
          // feed rather than opening on top of it.
          context.read<TourCubit>().arm();
          // Straight to the feed. The interstitial that used to sit here threw
          // confetti at someone for completing a form, then asked for one more
          // tap to reach the thing they'd actually come for — a second
          // ceremony stacked on the tour that follows. The feed built from
          // these answers is the reward.
          context.go(AppRoutes.home);
        }
        if (state.submitError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(state.submitError!, style: TextStyle(fontSize: 14.sp)),
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
            style: TextStyle(
                color: context.colors.mutedForeground, fontSize: 13.sp),
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

  // ── Step 1: Genres ────────────────────────────────────────────────────────────

  Widget _buildStep1(OnboardingState state, OnboardingCubit cubit) {
    final remaining = (3 - state.selectedGenres.length).clamp(0, 3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          label: 'STEP 1',
          title: 'Pick your genres',
          subtitle: 'Select at least 3',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: WSizes.md.w),
            child: Wrap(
              spacing: WSizes.sm.w,
              runSpacing: WSizes.sm.h,
              children: _kGenres.map((key) {
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
                          TasteOptions.genreEmoji[key] ?? '',
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

  // ── Step 2: Languages ─────────────────────────────────────────────────────────

  Widget _buildStep2(OnboardingState state, OnboardingCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          label: 'STEP 2',
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
                              lang['glyph'] as String,
                              style: TextStyle(
                                fontSize: 26.sp,
                                height: 1.1,
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                                    .withAlpha(isSelected ? 255 : 225),
                              ),
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
                border:
                    disabled ? Border.all(color: context.colors.border) : null,
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
                            isLast ? 'Finish' : 'Continue',
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
          // Shown on the last step too. With only two steps left, hiding it
          // there would have made the final answer the one thing in the flow
          // nobody can decline — and languages are a preference, not a
          // requirement. Skipping the last step clears it and submits.
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: state.isSubmitting
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    cubit.skipCurrentStep();
                    if (isLast) cubit.submitPreferences();
                  },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Text(
                isLast ? 'Skip for now' : 'Skip this step',
                style: TextStyle(
                  color: context.colors.mutedForeground.withValues(alpha: 0.6),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
