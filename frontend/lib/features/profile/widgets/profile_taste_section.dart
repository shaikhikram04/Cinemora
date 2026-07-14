import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/models/user_model.dart';
import 'package:cinemora/core/utils/era_insight.dart';
import 'package:cinemora/core/utils/genre_insight.dart';
import 'package:cinemora/core/utils/language_insight.dart';

/// Genre tags, derived viewing personality and era/language tiles.
class ProfileTasteSection extends StatelessWidget {
  final UserModel? user;

  /// Derived from the library, not hand-picked. Null while the user has too
  /// few dated titles to call it.
  final EraInsight? era;

  /// Also derived from the library — deliberately not the languages picked
  /// during onboarding, which record what a user says they want rather than
  /// what they actually watch. Those still drive the recommender.
  final LanguageInsight? language;

  /// Likewise derived from the library. The chips above it are still the
  /// onboarding picks — those are the user's own claim about their taste, and
  /// they're editable, so they stay as stated. The personality is a claim the
  /// app makes, so it has to be earned from what they actually watched.
  final GenreInsight? personality;

  const ProfileTasteSection({
    super.key,
    required this.user,
    required this.era,
    required this.language,
    required this.personality,
  });

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

  /// Deliberately counts titles rather than reusing `sharePercent` the way the
  /// era and language tiles do. Their share is a share of watches; this one is a
  /// share of genre *tags*, and an entry carries up to three of them — so "42% of
  /// your watches" would be a different, wrong claim.
  String _evidence(GenreInsight insight) {
    final titles = insight.titleCount == 1 ? 'title' : 'titles';
    return 'Read from ${insight.titleCount} ${insight.genre} $titles in your library.';
  }

  @override
  Widget build(BuildContext context) {
    final genres = user?.preferences.genres ?? [];

    final tiles = <Widget>[
      if (era != null)
        _InfoTile(
          title: 'FAVORITE ERA',
          value: era!.label,
          subtitle: '${era!.sharePercent.round()}% of your watches',
        ),
      if (language != null)
        _InfoTile(
          title: 'LANGUAGE',
          value: language!.label,
          subtitle: '${language!.sharePercent.round()}% of your watches',
        ),
    ];

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
        // Hidden outright until the library can support it, on the same reasoning
        // as the tiles below: a personality is the one thing on this page the app
        // asserts about the user, so a guess it can't back would undercut every
        // number around it.
        if (personality != null) ...[
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
                        personality!.archetype,
                        style: TextStyle(
                          color: context.colors.accentRedAlt,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        personality!.description,
                        style: TextStyle(
                          color: context.colors.mutedSecondarySoft,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Shows its working. The old label was a horoscope off a
                      // signup checkbox; naming the titles it was read from is
                      // what separates this from that.
                      Text(
                        _evidence(personality!),
                        style: TextStyle(
                          color: context.colors.mutedSecondaryDeep,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        // An insight the library can't support yet shows nothing at all, rather
        // than a placeholder tile — a shelf of "Building…" reads as a broken
        // profile. Whichever tiles are ready take the full width between them.
        if (tiles.isNotEmpty) ...[
          SizedBox(height: 16.h),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) SizedBox(width: 10.w),
                  Expanded(child: tiles[i]),
                ],
              ],
            ),
          ),
        ],
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
