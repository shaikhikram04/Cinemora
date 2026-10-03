import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/common/widgets/containers/top_gradient_background_container.dart';
import 'package:cinemora/common/widgets/cards/poster_image.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/network_images_path.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/utils/device_utils.dart';
import 'package:cinemora/core/utils/image_preloader.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/app_auth_state.dart';
import 'package:cinemora/features/authentication/viewmodels/welcome_cubit.dart';
import 'package:cinemora/features/authentication/viewmodels/welcome_state.dart';
import 'package:cinemora/features/authentication/widgets/index.dart';
import 'package:cinemora/common/widgets/progress_bars/page_view_progress_bar.dart';

// Poster images are static visual content — not business state.
const _kPosterImages = [
  NetworkImagesPath.harryPotterPoster,
  NetworkImagesPath.inceptionPoster,
  NetworkImagesPath.bahubaliPoster,
  NetworkImagesPath.theGodFatherPoster,
  NetworkImagesPath.theFamiliManPoster,
  NetworkImagesPath.myHeroAcedemiaPoster,
];

/// Entry point — provides [WelcomeCubit] and delegates to [_WelcomeContent].
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WelcomeCubit(),
      child: const _WelcomeContent(),
    );
  }
}

/// Holds the [PageController] (UI-only lifecycle) and reacts to [WelcomeState].
class _WelcomeContent extends StatefulWidget {
  const _WelcomeContent();

  @override
  State<_WelcomeContent> createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<_WelcomeContent> {
  late final PageController _pageController;
  bool _hasPreloaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<AppAuthCubit>().markWelcomeSeen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasPreloaded) return;
    _hasPreloaded = true;
    _preloadLaterPages();
  }

  /// Warms the artwork on the pages the user hasn't swiped to yet, while they
  /// read page 0. Without this each page's posters visibly fade in a beat
  /// after the swipe lands — worst on the sign-in page, which shows all six at
  /// once.
  ///
  /// Page 0's own posters are left out on purpose: they're already mounting as
  /// this runs, so warming them would only duplicate a request in flight.
  /// Sizes here mirror the render sites exactly — the cache is keyed on the
  /// resized provider, so a mismatch would fetch twice rather than once.
  void _preloadLaterPages() {
    precacheImages(context, [
      // Page 1 — the sign-in grid, every poster at one uniform size.
      for (final image in _kPosterImages)
        PosterImage.providerFor(
          context,
          image: image,
          width: 90.w,
          height: 158.h,
        ),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppAuthCubit, AppAuthState>(
      listener: (context, authState) {
        if (authState is AppAuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(authState.message, style: TextStyle(fontSize: 14.sp)),
              backgroundColor: context.colors.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          );
        }
        // Navigation on success is handled automatically by the router's
        // refreshListenable — no explicit context.go needed here.
      },
      child: BlocConsumer<WelcomeCubit, WelcomeState>(
        listenWhen: (prev, curr) => prev.currentPage != curr.currentPage,
        listener: (context, state) {
          if (_pageController.page?.round() != state.currentPage) {
            _pageController.animateToPage(
              state.currentPage,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<WelcomeCubit>();
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: context.colors.background,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              body: Container(
                decoration: BoxDecoration(color: context.colors.background),
                child: SafeArea(
                  top: false,
                  child: TopGradientBackgroundContainer(
                    child: Column(
                      children: [
                        SizedBox(
                          height: DeviceUtils.getStatusBarHeight(context) +
                              AppSizes.space8,
                        ),
                        PageViewProgressBar(
                          totalPages: WelcomeCubit.totalPages,
                          currentPage: state.currentPage,
                          onSkip: cubit.jumpToLast,
                        ),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: cubit.pageChanged,
                            children: [
                              _buildIntroPage(cubit),
                              _buildSignInPage(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Page 0 — What this is ──────────────────────────────────────────────────

  Widget _buildIntroPage(WelcomeCubit cubit) {
    return WelcomePageLayout(
      visual: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 52.h,
            child: PosterImage(
              image: _kPosterImages[0],
              width: 172.w,
              height: 272.h,
              title: 'Inception',
              rating: '8.8',
              titleOnImage: true,
            ),
          ),
          Positioned(
            right: 24.w,
            top: 84.h,
            child: Transform.rotate(
              angle: 0.09,
              child: PosterImage(
                image: _kPosterImages[2],
                width: 96.w,
                height: 142.h,
              ),
            ),
          ),
          Positioned(
            left: 24.w,
            top: 108.h,
            child: Transform.rotate(
              angle: -0.11,
              child: PosterImage(
                image: _kPosterImages[1],
                width: 84.w,
                height: 138.h,
              ),
            ),
          ),
          Positioned(
            left: 24.w,
            top: 248.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99.r),
                color: context.colors.chartGreen.withAlpha(40),
                border:
                    Border.all(color: context.colors.chartGreen.withAlpha(120)),
              ),
              child: const Text(
                '✓ Added',
                style: TextStyle(
                  color: Color(0xFF00D59D),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            right: 24.w,
            top: 224.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99.r),
                color: context.colors.chartYellow.withAlpha(40),
                border: Border.all(
                    color: context.colors.chartYellow.withAlpha(100)),
              ),
              child: Text(
                '★ 9.0',
                style: TextStyle(
                  color: context.colors.chartYellow,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      label: 'WELCOME',
      title: 'Track what\nyou love.',
      subtitle:
          'Your personal cinema diary. Rate, organize, and\nrediscover films that matter.',
      primaryButton: 'Get Started',
      onPrimaryPressed: cubit.nextPage,
    );
  }

  // ── Page 1 — Sign In ───────────────────────────────────────────────────────

  Widget _buildSignInPage(BuildContext context) {
    final isLoading = context.select<AppAuthCubit, bool>(
      (c) => c.state is AppAuthLoading,
    );
    return WelcomePageLayout(
      isLoading: isLoading,
      visual: Column(
        children: [
          Flexible(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _kPosterImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSizes.space8,
                mainAxisSpacing: AppSizes.space8,
                childAspectRatio: 0.74,
              ),
              itemBuilder: (context, index) {
                return PosterImage(
                  image: _kPosterImages[index],
                  width: 90.w,
                  height: 158.h,
                  radius: 18,
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.space16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.space16,
              vertical: AppSizes.space8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull.r),
              color: context.colors.primary.withAlpha(35),
              border: Border.all(color: context.colors.primary.withAlpha(60)),
            ),
            child: Text(
              '● 2.4M+ movies tracked',
              style: TextStyle(
                color: const Color(0xFFFF7A7A),
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      label: 'READY',
      title: 'Start your\ncinema journey.',
      subtitle:
          'Join millions of film lovers tracking, sharing and\ndiscovering together.',
      primaryButton: 'Sign In with Google',
      secondaryButton: 'Sign In with Apple',
      onPrimaryPressed: () => context.read<AppAuthCubit>().signInWithGoogle(),
      onSecondaryPressed: () => context.read<AppAuthCubit>().signInWithApple(),
    );
  }
}
