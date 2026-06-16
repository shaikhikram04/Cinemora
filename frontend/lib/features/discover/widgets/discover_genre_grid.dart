import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';

class DiscoverGenreGrid extends StatelessWidget {
  const DiscoverGenreGrid({super.key});

  static const List<_GenreData> _genres = [
    _GenreData(
      label: 'Action',
      gradient: [Color(0xFFB71C1C), Color(0xFFE53935)],
      imagePath:
          "https://plus.unsplash.com/premium_photo-1750699176491-e48fe2739384?q=80&w=2077&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    ),
    _GenreData(
      label: 'Drama',
      gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      imagePath:
          "https://images.unsplash.com/photo-1777612914411-0151f5fca99f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDF8aG1lbnZRaFVteE18fGVufDB8fHx8fA%3D%3D",
    ),
    _GenreData(
      label: 'Thriller',
      gradient: [Color(0xFF4A148C), Color(0xFF9C27B0)],
      imagePath:
          "https://plus.unsplash.com/premium_photo-1777373545350-0ccddbd76fc5?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDJ8aG1lbnZRaFVteE18fGVufDB8fHx8fA%3D%3D",
    ),
    _GenreData(
      label: 'Sci-Fi',
      gradient: [Color(0xFF827717), Color(0xFFFBC02D)],
      imagePath:
          "https://images.unsplash.com/photo-1778599726901-22698cf83040?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDh8aG1lbnZRaFVteE18fGVufDB8fHx8fA%3D%3D",
    ),
    _GenreData(
      label: 'Horror',
      gradient: [Color(0xFF1B5E20), Color(0xFF388E3C)],
      imagePath:
          "https://images.unsplash.com/photo-1777465492791-189ae33b8c73?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDR8aG1lbnZRaFVteE18fGVufDB8fHx8fA%3D%3D",
    ),
    _GenreData(
      label: 'Romance',
      gradient: [Color(0xFF880E4F), Color(0xFFEC407A)],
      imagePath:
          "https://images.unsplash.com/photo-1777784679152-08bc40c70834?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDExfGhtZW52UWhVbXhNfHxlbnwwfHx8fHw%3D",
    ),
    _GenreData(
      label: 'Comedy',
      gradient: [Color(0xFF006064), Color(0xFF26C6DA)],
      imagePath:
          "https://images.unsplash.com/photo-1777915519441-abdffe1849df?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDE0fGhtZW52UWhVbXhNfHxlbnwwfHx8fHw%3D",
    ),
    _GenreData(
      label: 'Mystery',
      gradient: [Color(0xFF6D4C41), Color(0xFFD4A050)],
      imagePath:
          "https://images.unsplash.com/photo-1778655726656-299707575200?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDEwfGhtZW52UWhVbXhNfHxlbnwwfHx8fHw%3D",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: WSizes.screenPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Genre',
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 14.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _genres.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 2.05,
            ),
            itemBuilder: (context, index) {
              return _GenreCard(data: _genres[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _GenreCard extends StatefulWidget {
  final _GenreData data;

  const _GenreCard({required this.data});

  @override
  State<_GenreCard> createState() => _GenreCardState();
}

class _GenreCardState extends State<_GenreCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {},
      child: ScaleTransition(
        scale: _scaleAnim,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(WSizes.radius3xl.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Gradient background ─────────────────────────────
              _GenreBackground(
                gradient: widget.data.gradient,
                imagePath: widget.data.imagePath,
              ),

              // ── Dark overlay for text legibility ────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),

              // ── Label ───────────────────────────────────────────
              Positioned(
                left: 14.w,
                bottom: 12.h,
                child: Text(
                  widget.data.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreBackground extends StatelessWidget {
  final List<Color> gradient;
  final String? imagePath;

  const _GenreBackground({required this.gradient, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. Base gradient ───────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
        ),

        // ── 2. Photo overlay (semi-transparent) ────────────────
        if (imagePath != null)
          Opacity(
            opacity: 0.25,
            child: Image.network(
              imagePath!,
              fit: BoxFit.cover,
              // Show nothing while loading / on error — gradient shows through
              frameBuilder: (context, child, frame, _) {
                if (frame == null) return const SizedBox.shrink();
                return child;
              },
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}

class _GenreData {
  final String label;
  final List<Color> gradient;
  final String? imagePath;

  const _GenreData({
    required this.label,
    required this.gradient,
    this.imagePath,
  });
}
