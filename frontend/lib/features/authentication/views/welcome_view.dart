import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/common/widgets/containers/top_gradient_background_container.dart';
import 'package:watchary/common/widgets/cards/poster_image.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/shadows.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/core/utils/device_utils.dart';
import 'package:watchary/features/authentication/viewmodels/app_auth_cubit.dart';
import 'package:watchary/features/authentication/viewmodels/app_auth_state.dart';
import 'package:watchary/features/authentication/viewmodels/welcome_cubit.dart';
import 'package:watchary/features/authentication/viewmodels/welcome_state.dart';
import 'package:watchary/features/authentication/widgets/index.dart';
import 'package:watchary/common/widgets/progress_bars/page_view_progress_bar.dart';

// Poster images are static visual content — not business state.
const _kPosterImages = [
  'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=600&q=80',
  'https://images.unsplash.com/photo-1505685296765-3a2736de412f?auto=format&fit=crop&w=600&q=80',
  'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80',
  'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80',
  'https://images.unsplash.com/photo-1502139214982-d0ad755818d8?auto=format&fit=crop&w=600&q=80',
  'https://images.unsplash.com/photo-1451187863213-d1bcbaae3fa3?auto=format&fit=crop&w=600&q=80',
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<AppAuthCubit>().markWelcomeSeen();
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
              content: Text(authState.message),
              backgroundColor: Colors.red.shade800,
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
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: WColors.background,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              extendBody: true,
              extendBodyBehindAppBar: true,
              body: Container(
                decoration: const BoxDecoration(color: WColors.background),
                child: SafeArea(
                  top: false,
                  child: TopGradientBackgroundContainer(
                    child: Column(
                      children: [
                        SizedBox(
                          height: DeviceUtils.getStatusBarHeight(context) +
                              WSizes.sm,
                        ),
                        PageViewProgressBar(
                          totalPages: 4,
                          currentPage: state.currentPage,
                          onSkip: cubit.jumpToLast,
                        ),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: cubit.pageChanged,
                            children: [
                              _buildPage0(cubit),
                              _buildPage1(cubit),
                              _buildPage2(cubit),
                              _buildPage3(context),
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

  // ── Page 0 — Track ─────────────────────────────────────────────────────────

  Widget _buildPage0(WelcomeCubit cubit) {
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
                color: WColors.chartGreen.withAlpha(40),
                border: Border.all(color: WColors.chartGreen.withAlpha(120)),
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
                color: WColors.chartYellow.withAlpha(40),
                border: Border.all(color: WColors.chartYellow.withAlpha(100)),
              ),
              child: const Text(
                '★ 9.0',
                style: TextStyle(
                  color: WColors.chartYellow,
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

  // ── Page 1 — Organize ──────────────────────────────────────────────────────

  Widget _buildPage1(WelcomeCubit cubit) {
    return WelcomePageLayout(
      visual: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 62.h),
          const FeatureTile(
            icon: Icons.bookmark_border_rounded,
            iconColor: Color(0xFF5EA2FF),
            title: 'Instant Save',
            subtitle: 'Add any movie in one tap',
            trailingColor: Color(0xFF5EA2FF),
          ),
          SizedBox(height: WSizes.sm),
          FeatureTile(
            icon: Icons.star_border_rounded,
            iconColor: WColors.tertiary,
            title: 'Rate & Review',
            subtitle: 'Build your taste profile',
            trailingColor: WColors.tertiary,
          ),
          SizedBox(height: WSizes.sm),
          const FeatureTile(
            icon: Icons.auto_awesome_outlined,
            iconColor: Color(0xFFA678FF),
            title: 'AI Discovery',
            subtitle: 'Finds your next obsession',
            trailingColor: Color(0xFFA678FF),
          ),
        ],
      ),
      label: 'ORGANIZE',
      title: 'Never forget\nwhat to watch.',
      subtitle:
          'Build the perfect watchlist and never lose track\nof a recommendation again.',
      primaryButton: 'Continue',
      onPrimaryPressed: cubit.nextPage,
    );
  }

  // ── Page 2 — Discover ──────────────────────────────────────────────────────

  Widget _buildPage2(WelcomeCubit cubit) {
    return WelcomePageLayout(
      visual: Padding(
        padding: const EdgeInsets.symmetric(horizontal: WSizes.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(WSizes.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(WSizes.radiusLg),
                color: WColors.card.withAlpha(230),
                border: Border.all(color: WColors.border),
                boxShadow: WShadow.cardGlow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFC758B6),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 15.sp,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: WSizes.sm),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Recommendation',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Based on your profile',
                            style: TextStyle(
                              color: WColors.mutedForeground,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: WSizes.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterImage(
                        image: _kPosterImages[2],
                        width: 74.w,
                        height: 116.h,
                        radius: 14.r,
                      ),
                      const SizedBox(width: WSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dune: Part Two',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text.rich(
                              const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '★ 8.7   ',
                                    style: TextStyle(
                                      color: WColors.chartYellow,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sci-Fi',
                                    style: TextStyle(
                                      color: WColors.mutedForeground,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TagChip(
                              text: 'Because you liked Inception',
                              background: const Color(0x25972FFF),
                              border: const Color(0x3AB752FF),
                              textColor: const Color(0xDFE6C1FF),
                              icon: Icons.auto_awesome,
                            ),
                            SizedBox(height: 6.h),
                            TagChip(
                              text: 'Matches your Sci-Fi taste',
                              background: const Color(0x1A2E8CFF),
                              border: const Color(0x663C96FF),
                              textColor: const Color(0xFFA4C9FF),
                              icon: Icons.star_border,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: WSizes.md),
            const Wrap(
              spacing: WSizes.sm,
              runSpacing: WSizes.sm,
              children: [
                MoodChip(text: '😌 Emotional'),
                MoodChip(text: '🤯 Mind-Blown'),
                MoodChip(text: '🔥 Hyped', highlighted: true),
                MoodChip(text: '😱 Scared'),
              ],
            ),
          ],
        ),
      ),
      label: 'DISCOVER',
      title: 'AI that knows\nyour taste.',
      subtitle:
          'Tell us your mood, get a perfect pick — with\ncontext on why it fits you.',
      primaryButton: 'Continue',
      onPrimaryPressed: cubit.nextPage,
    );
  }

  // ── Page 3 — Sign In ───────────────────────────────────────────────────────

  Widget _buildPage3(BuildContext context) {
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
                crossAxisSpacing: WSizes.sm,
                mainAxisSpacing: WSizes.sm,
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
          const SizedBox(height: WSizes.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: WSizes.md,
              vertical: WSizes.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(WSizes.radiusFull.r),
              color: WColors.primary.withAlpha(35),
              border: Border.all(color: WColors.primary.withAlpha(60)),
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
