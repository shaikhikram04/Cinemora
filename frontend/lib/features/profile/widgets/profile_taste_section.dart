import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/utils/era_insight.dart';

/// Genre tags, derived viewing personality and era/language tiles.
class ProfileTasteSection extends StatelessWidget {
  final UserModel? user;

  /// Derived from the library, not hand-picked. Null while the user has too
  /// few dated titles to call it.
  final EraInsight? era;

  const ProfileTasteSection({super.key, required this.user, required this.era});

  static final _genreColors = {
    'Drama': const Color(0xFFE74D5B), // accentRedAlt
    'Thriller': const Color(0xFFE0A838), // warning
    'Psychological': const Color(0xFFFBBF24), // chartYellow
    'Crime': const Color(0xFF60A5FA), // chartBlue
    'Sci-Fi': const Color(0xFFA78BFA), // chartPurple
    'Mystery': const Color.fromARGB(255, 188, 113, 225),
    'Action': const Color(0xFFE84B57), // accentRed
    'Horror': const Color(0xFFE74D5B), // accentRedAlt
    'Romance': const Color(0xFFFF6B8A),
    'Fantasy': const Color(0xFFA78BFA), // chartPurple
    'Documentary': const Color(0xFF10B981), // chartGreen
    'Animation': const Color(0xFFFBBF24), // chartYellow
  };

  static final Color _defaultColor = const Color(0xFF8F96A3); // mutedSecondary

  String _computePersonality(List<String> genres) {
    if (genres.contains('Psychological') || genres.contains('Drama')) {
      return 'The Story Seeker';
    }
    if (genres.contains('Sci-Fi') || genres.contains('Fantasy')) {
      return 'The World Builder';
    }
    if (genres.contains('Action') || genres.contains('Thriller')) {
      return 'The Thrill Seeker';
    }
    if (genres.contains('Crime') || genres.contains('Mystery')) {
      return 'The Detective';
    }
    if (genres.contains('Horror')) return 'The Brave Soul';
    if (genres.contains('Romance')) return 'The Romantic';
    return 'The Explorer';
  }

  String _personalityDesc(String personality) {
    switch (personality) {
      case 'The Story Seeker':
        return 'You enjoy emotionally driven stories, psychological mysteries and character-focused narratives.';
      case 'The World Builder':
        return 'You love expansive universes, speculative fiction and stories that challenge imagination.';
      case 'The Thrill Seeker':
        return 'You crave high-stakes action, suspense and edge-of-your-seat storytelling.';
      case 'The Detective':
        return 'You\'re drawn to puzzles, moral ambiguity and stories where secrets slowly unravel.';
      case 'The Brave Soul':
        return 'You embrace tension, atmosphere and the art of facing the unknown.';
      case 'The Romantic':
        return 'You appreciate human connection, heartfelt stories and emotional depth.';
      default:
        return 'Your taste spans genres and styles — you watch everything.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final genres = user?.preferences.genres ?? [];
    final language = user?.preferences.languages.isNotEmpty == true
        ? user!.preferences.languages.first
        : 'English';
    final personality = _computePersonality(genres);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        genres.isEmpty
            ? Text(
                'No genres set yet — edit your profile to add taste.',
                style: TextStyle(
                    color: context.colors.mutedSecondary, fontSize: 13.sp),
              )
            : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: genres
                    .map((g) => _TagChip(
                          label: g,
                          color: _genreColors[g] ?? _defaultColor,
                        ))
                    .toList(growable: false),
              ),
        SizedBox(height: 16.h),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: context.colors.surfaceRaised.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: context.colors.borderStrong),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -40,
                left: -10,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            context.colors.accentPurple.withValues(alpha: 0.3),
                        blurRadius: 80,
                        offset: const Offset(0, 10),
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.accentRed.withValues(alpha: 0.3),
                        blurRadius: 150,
                        offset: const Offset(0, 10),
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIEWING PERSONALITY',
                      style: TextStyle(
                        color: context.colors.mutedSecondaryDeep,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      personality,
                      style: TextStyle(
                        color: context.colors.accentRedAlt,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _personalityDesc(personality),
                      style: TextStyle(
                        color: context.colors.mutedSecondarySoft,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _InfoTile(
                  title: 'FAVORITE ERA',
                  value: era?.label ?? 'Building…',
                  subtitle: era != null
                      ? '${era!.sharePercent.round()}% of your watches'
                      : 'Track 8+ titles to unlock',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _InfoTile(
                  title: 'LANGUAGE',
                  value: language,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const _InfoTile({required this.title, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surfaceRaised.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: context.colors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.colors.mutedSecondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: context.colors.foreground,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: TextStyle(
                color: context.colors.mutedSecondaryDeep,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
