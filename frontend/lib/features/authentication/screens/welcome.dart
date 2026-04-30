import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/shadows.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/features/authentication/widgets/index.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<String> _posterImages = const [
    'https://images.unsplash.com/photo-1612036781124-847f8939b154?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1505685296765-3a2736de412f?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1502139214982-d0ad755818d8?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1451187863213-d1bcbaae3fa3?auto=format&fit=crop&w=600&q=80',
  ];

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

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  void _jumpToLast() {
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
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
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            color: WColors.background,
          ),
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomCenter,
                  colors: [
                    WColors.primary.withAlpha(38),
                    WColors.background,
                    WColors.background,
                  ],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + WSizes.sm,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: WSizes.md),
                    child: Row(
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: WColors.primary,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                        const SizedBox(width: WSizes.sm),
                        const Text(
                          'Watchary',
                          style: TextStyle(
                            color: WColors.foreground,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            height: 2.4,
                          ),
                        ),
                        const Spacer(),
                        if (_currentPage < 3)
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  WColors.card.withValues(alpha: 0.5),
                              foregroundColor: WColors.mutedForeground,
                              minimumSize: Size(72.w, 40.h),
                              side: const BorderSide(
                                color: WColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                            ),
                            onPressed: _jumpToLast,
                            child: const Text('Skip'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: WSizes.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: WSizes.md),
                    child: Row(
                      children: List.generate(4, (index) {
                        final isActive = index == _currentPage;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            height: 3.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99.r),
                              color: isActive
                                  ? WColors.primary
                                  : Colors.white.withAlpha(70),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        OnboardingPageLayout(
                          visual: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              MovieCard(
                                image: _posterImages[0],
                                width: 172.w,
                                height: 254.h,
                                title: 'Inception',
                                rating: '8.8',
                              ),
                              Positioned(
                                right: (-70).w,
                                bottom: 90.h,
                                child: Transform.rotate(
                                  angle: 0.09,
                                  child: MovieCard(
                                    image: _posterImages[2],
                                    width: 96.w,
                                    height: 136.h,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: (-70).w,
                                bottom: 60.h,
                                child: Transform.rotate(
                                  angle: -0.11,
                                  child: MovieCard(
                                    image: _posterImages[1],
                                    width: 84.w,
                                    height: 128.h,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -70,
                                bottom: 30,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99.r),
                                    color: WColors.chartGreen.withAlpha(
                                      40,
                                    ),
                                    border: Border.all(
                                      color: WColors.chartGreen.withAlpha(120),
                                    ),
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
                                right: -70,
                                bottom: 60,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99.r),
                                    color: WColors.chartYellow.withAlpha(40),
                                    border: Border.all(
                                      color: WColors.chartYellow.withAlpha(100),
                                    ),
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
                          onPrimaryPressed: _nextPage,
                        ),
                        OnboardingPageLayout(
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
                          onPrimaryPressed: _nextPage,
                        ),
                        OnboardingPageLayout(
                          visual: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: WSizes.sm,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(WSizes.md),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(WSizes.radiusLg),
                                    color: WColors.card.withAlpha(230),
                                    border: Border.all(
                                      color: WColors.border,
                                    ),
                                    boxShadow: WShadow.cardGlow,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                                const Color(0xFFC758B6),
                                            child: Icon(
                                              Icons.auto_awesome,
                                              size: 15.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: WSizes.sm),
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                  color:
                                                      WColors.mutedForeground,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: WSizes.md),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MovieCard(
                                            image: _posterImages[2],
                                            width: 74,
                                            height: 106,
                                            radius: 14,
                                          ),
                                          const SizedBox(width: WSizes.sm),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Dune: Part Two',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4.h,
                                                ),
                                                Text.rich(
                                                  const TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '★ 8.7   ',
                                                        style: TextStyle(
                                                          color: WColors
                                                              .chartYellow,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: 'Sci-Fi',
                                                        style: TextStyle(
                                                          color: WColors
                                                              .mutedForeground,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                TagChip(
                                                  text:
                                                      'Because you liked Inception',
                                                  background:
                                                      const Color(0x25972FFF),
                                                  border:
                                                      const Color(0x3AB752FF),
                                                  textColor:
                                                      const Color(0xDFE6C1FF),
                                                  icon: Icons.auto_awesome,
                                                ),
                                                SizedBox(height: 6),
                                                TagChip(
                                                  text:
                                                      'Matches your Sci-Fi taste',
                                                  background:
                                                      const Color(0x1A2E8CFF),
                                                  border:
                                                      const Color(0x663C96FF),
                                                  textColor:
                                                      const Color(0xFFA4C9FF),
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
                                    MoodChip(
                                      text: '🔥 Hyped',
                                      highlighted: true,
                                    ),
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
                          onPrimaryPressed: _nextPage,
                        ),
                        OnboardingPageLayout(
                          visual: Column(
                            children: [
                              Flexible(
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _posterImages.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: WSizes.sm,
                                    mainAxisSpacing: WSizes.sm,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemBuilder: (context, index) {
                                    return MovieCard(
                                      image: _posterImages[index],
                                      width: 90.w,
                                      height: 130.h,
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
                                  borderRadius: BorderRadius.circular(999.r),
                                  color: WColors.primary.withAlpha(35),
                                  border: Border.all(
                                    color: WColors.primary.withAlpha(60),
                                  ),
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
                          onPrimaryPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => const LoginScreen(),
                            //   ),
                            // );
                          },
                          onSecondaryPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => const SignupScreenStep1(),
                            //   ),
                            // );
                          },
                        ),
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
  }
}
