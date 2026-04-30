import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/shadows.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/core/themes/custom_theme/text_theme.dart';

/// Using flutter_screenutil - CLEANEST responsive syntax!
///
/// Example:
/// width: 172.w         // Responsive width
/// height: 254.h        // Responsive height
/// fontSize: 18.sp      // Responsive font size
/// padding: 16.w        // Responsive padding

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

  Widget _movieCard({
    required String image,
    required double width,
    required double height,
    String? title,
    String? rating,
    double radius = 22,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: WColors.border),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              WColors.background.withAlpha(120),
              WColors.background.withAlpha(220),
            ],
          ),
        ),
        padding: const EdgeInsets.all(WSizes.sm),
        alignment: Alignment.bottomLeft,
        child: title == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '★ $rating',
                    style: const TextStyle(
                      color: WColors.tertiary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
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
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 18,
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
                              minimumSize: const Size(72, 40),
                              side: const BorderSide(
                                color: WColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
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
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
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
                        _OnboardingPageLayout(
                          visual: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              _movieCard(
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
                                  child: _movieCard(
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
                                  child: _movieCard(
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99),
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
                        _OnboardingPageLayout(
                          visual: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 62.h),
                              const _FeatureTile(
                                icon: Icons.bookmark_border_rounded,
                                iconColor: Color(0xFF5EA2FF),
                                title: 'Instant Save',
                                subtitle: 'Add any movie in one tap',
                                trailingColor: Color(0xFF5EA2FF),
                              ),
                              SizedBox(height: WSizes.sm),
                              _FeatureTile(
                                icon: Icons.star_border_rounded,
                                iconColor: WColors.tertiary,
                                title: 'Rate & Review',
                                subtitle: 'Build your taste profile',
                                trailingColor: WColors.tertiary,
                              ),
                              SizedBox(height: WSizes.sm),
                              _FeatureTile(
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
                        _OnboardingPageLayout(
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
                                      const Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Color(0xFFC758B6),
                                            child: Icon(
                                              Icons.auto_awesome,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: WSizes.sm),
                                          Column(
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
                                          _movieCard(
                                            image: _posterImages[2],
                                            width: 74,
                                            height: 106,
                                            radius: 14,
                                          ),
                                          const SizedBox(width: WSizes.sm),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Dune: Part Two',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text.rich(
                                                  TextSpan(
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
                                                _TagChip(
                                                  text:
                                                      'Because you liked Inception',
                                                  background: Color(0x25972FFF),
                                                  border: Color(0x3AB752FF),
                                                  textColor: Color(0xDFE6C1FF),
                                                  icon: Icons.auto_awesome,
                                                ),
                                                SizedBox(height: 6),
                                                _TagChip(
                                                  text:
                                                      'Matches your Sci-Fi taste',
                                                  background: Color(0x1A2E8CFF),
                                                  border: Color(0x663C96FF),
                                                  textColor: Color(0xFFA4C9FF),
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
                                    _MoodChip(text: '😌 Emotional'),
                                    _MoodChip(text: '🤯 Mind-Blown'),
                                    _MoodChip(
                                      text: '🔥 Hyped',
                                      highlighted: true,
                                    ),
                                    _MoodChip(text: '😱 Scared'),
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
                        _OnboardingPageLayout(
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
                                    return _movieCard(
                                      image: _posterImages[index],
                                      width: 90,
                                      height: 130,
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
                                  borderRadius: BorderRadius.circular(999),
                                  color: WColors.primary.withAlpha(35),
                                  border: Border.all(
                                    color: WColors.primary.withAlpha(60),
                                  ),
                                ),
                                child: const Text(
                                  '● 2.4M+ movies tracked',
                                  style: TextStyle(
                                    color: Color(0xFFFF7A7A),
                                    fontSize: 12,
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

class _OnboardingPageLayout extends StatelessWidget {
  final Widget visual;
  final String label;
  final String title;
  final String subtitle;
  final String primaryButton;
  final String? secondaryButton;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  const _OnboardingPageLayout({
    required this.visual,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.primaryButton,
    required this.onPrimaryPressed,
    this.secondaryButton,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 360, child: Center(child: visual)),
          Spacer(),
          const SizedBox(height: WSizes.defaultSpace),
          Text(
            label,
            style: WTextTheme.label,
          ),
          const SizedBox(height: WSizes.sm),
          Text(
            title,
            style: WTextTheme.h1,
          ),
          const SizedBox(height: WSizes.md),
          Text(
            subtitle,
            style: WTextTheme.body.copyWith(fontSize: 14),
          ),
          const SizedBox(height: WSizes.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: WColors.primary,
                foregroundColor: WColors.primaryForeground,
                textStyle: WTextTheme.button.copyWith(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: WColors.primary.withAlpha(120),
                elevation: 2,
              ),
              onPressed: onPrimaryPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(primaryButton),
                  const SizedBox(width: WSizes.sm),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
          if (secondaryButton != null) ...[
            const SizedBox(height: WSizes.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  side: const BorderSide(
                      color: Color.fromARGB(28, 255, 255, 255)),
                  foregroundColor: WColors.foreground,
                  textStyle: WTextTheme.button.copyWith(fontSize: 16),
                  backgroundColor:
                      const Color.fromARGB(255, 58, 58, 61).withAlpha(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onSecondaryPressed,
                child: Text(secondaryButton!),
              ),
            ),
          ],
          const SizedBox(height: WSizes.lg),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color trailingColor;

  const _FeatureTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WSizes.radiusLg),
        color: WColors.card.withAlpha(150),
        border: Border.all(color: WColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: iconColor.withAlpha(30),
              border: Border.all(color: iconColor.withAlpha(100)),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: WSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WTextTheme.h3.copyWith(fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: WTextTheme.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 12,
            backgroundColor: trailingColor.withAlpha(45),
            child: Icon(Icons.check, size: 14, color: trailingColor),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  final Color background;
  final Color border;
  final Color textColor;
  final IconData icon;

  const _TagChip({
    required this.text,
    required this.background,
    required this.border,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: WSizes.sm, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String text;
  final bool highlighted;

  const _MoodChip({required this.text, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        highlighted ? WColors.primary : const Color.fromARGB(18, 108, 108, 108);
    final textColor = highlighted ? WColors.primary : WColors.mutedForeground;
    final backgroundColor = highlighted
        ? WColors.primary.withAlpha(30)
        : const Color.fromARGB(255, 54, 54, 54).withAlpha(130);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: WSizes.sm, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: backgroundColor,
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
