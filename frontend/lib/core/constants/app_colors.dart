import 'package:flutter/material.dart';

class AppColors {
  // --- Core Surfaces ---
  final Color background;
  final Color backgroundAlt;
  final Color foreground;
  final Color card;

  // --- Brand ---
  final Color primary;
  final Color primaryForeground;

  // --- Semantic ---
  final Color secondary;
  final Color muted;
  final Color mutedForeground;
  final Color border;
  final Color borderStrong;
  final Color input;
  final Color ring;

  // --- Surface Scale ---
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color surfaceRaised2;
  final Color surfaceOverlay;
  final Color surfaceTint;
  final Color surfaceBorder;
  final Color surfaceBorderAlt;
  final Color surfaceChip;
  final Color surfaceChipBorder;

  // --- Chart (identical across themes) ---
  final Color chartBlue;
  final Color chartYellow;
  final Color chartGreen;
  final Color chartPurple;

  // --- Status ---
  final Color tertiary;
  final Color warning;
  final Color success;
  final Color successSoft;

  // --- Accent Reds ---
  final Color accentRed;
  final Color accentRedAlt;
  final Color accentRedSoft;

  // --- Accents ---
  final Color accentPurple;
  final Color accentPink;
  final Color accentBlueMuted;

  // --- Muted Text Scale ---
  final Color mutedSecondary;
  final Color mutedSecondaryAlt;
  final Color mutedSecondarySoft;
  final Color mutedSecondaryDeep;
  final Color mutedSecondaryHeader;
  final Color mutedSecondaryVibe;
  final Color mutedSecondaryHighlight;

  // --- Shadows ---
  final Color shadowMedium;
  final Color shadowStrong;
  final Color shadowSoft;

  const AppColors({
    required this.background,
    required this.backgroundAlt,
    required this.foreground,
    required this.card,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.muted,
    required this.mutedForeground,
    required this.border,
    required this.borderStrong,
    required this.input,
    required this.ring,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.surfaceRaised2,
    required this.surfaceOverlay,
    required this.surfaceTint,
    required this.surfaceBorder,
    required this.surfaceBorderAlt,
    required this.surfaceChip,
    required this.surfaceChipBorder,
    required this.chartBlue,
    required this.chartYellow,
    required this.chartGreen,
    required this.chartPurple,
    required this.tertiary,
    required this.warning,
    required this.success,
    required this.successSoft,
    required this.accentRed,
    required this.accentRedAlt,
    required this.accentRedSoft,
    required this.accentPurple,
    required this.accentPink,
    required this.accentBlueMuted,
    required this.mutedSecondary,
    required this.mutedSecondaryAlt,
    required this.mutedSecondarySoft,
    required this.mutedSecondaryDeep,
    required this.mutedSecondaryHeader,
    required this.mutedSecondaryVibe,
    required this.mutedSecondaryHighlight,
    required this.shadowMedium,
    required this.shadowStrong,
    required this.shadowSoft,
  });

  static const AppColors dark = AppColors(
    background: Color(0xFF1C1C21),
    backgroundAlt: Color(0xFF141418),
    foreground: Color(0xFFF5F5F7),
    card: Color(0xFF141418),
    primary: Color(0xFFE63946),
    primaryForeground: Colors.white,
    secondary: Color(0x0FFFFFFF),
    muted: Color(0x0FFFFFFF),
    mutedForeground: Color(0xFF6E6E80),
    border: Color(0x12FFFFFF),
    borderStrong: Color(0x22FFFFFF),
    input: Color(0x0FFFFFFF),
    ring: Color(0x66E63946),
    surface: Color(0xFF1C1B21),
    surfaceMuted: Color(0xFF27272C),
    surfaceRaised: Color(0xFF2B2C32),
    surfaceRaised2: Color(0xFF2C2D34),
    surfaceOverlay: Color(0xFF7E7E7E),
    surfaceTint: Color(0xFF48484E),
    surfaceBorder: Color(0xFF26262B),
    surfaceBorderAlt: Color(0xFF2A2B31),
    surfaceChip: Color(0xFF292A30),
    surfaceChipBorder: Color(0xFF43444B),
    chartBlue: Color(0xFF60A5FA),
    chartYellow: Color(0xFFFBBF24),
    chartGreen: Color(0xFF10B981),
    chartPurple: Color(0xFFA78BFA),
    tertiary: Color(0xFFFFBB00),
    warning: Color(0xFFE0A838),
    success: Color(0xFF00D9A3),
    successSoft: Color(0x1A00D9A3),
    accentRed: Color(0xFFE84B57),
    accentRedAlt: Color(0xFFE74D5B),
    accentRedSoft: Color(0xFFED5A61),
    accentPurple: Color(0xFFA94EF2),
    accentPink: Color(0xFFEB4B6B),
    accentBlueMuted: Color(0xFF718096),
    mutedSecondary: Color(0xFF8F96A3),
    mutedSecondaryAlt: Color(0xFF8C8C97),
    mutedSecondarySoft: Color(0xFFB6B6C0),
    mutedSecondaryDeep: Color(0xFF6E6E7D),
    mutedSecondaryHeader: Color(0xFF5D5D69),
    mutedSecondaryVibe: Color(0xFFB8B8C4),
    mutedSecondaryHighlight: Color(0xFF8F83FF),
    shadowMedium: Color(0x73000000),
    shadowStrong: Color(0x8A000000),
    shadowSoft: Color(0x4D000000),
  );

  // Light mode: warm editorial off-whites, deep charcoal text, same red brand.
  // Surfaces step from #F5F5F8 → white cards, giving clear hierarchy without
  // cold sterile whites. Shadows are lighter since light surfaces already
  // carry natural depth contrast.
  static const AppColors light = AppColors(
    background: Color(0xFFF5F5F8),
    backgroundAlt: Color(0xFFEEEFF3),
    foreground: Color(0xFF111118),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFFE63946),
    primaryForeground: Colors.white,
    secondary: Color(0x0A000000),
    muted: Color(0x08000000),
    mutedForeground: Color(0xFF57576B),
    border: Color(0x12000000),
    borderStrong: Color(0x22000000),
    input: Color(0x08000000),
    ring: Color(0x66E63946),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF2F2F6),
    surfaceRaised: Color(0xFFEBEBEF),
    surfaceRaised2: Color(0xFFE5E5EA),
    surfaceOverlay: Color(0xFF9898A8),
    surfaceTint: Color(0xFFBDBDC8),
    surfaceBorder: Color(0xFFDCDCE2),
    surfaceBorderAlt: Color(0xFFE0E0E6),
    surfaceChip: Color(0xFFEAEAEF),
    surfaceChipBorder: Color(0xFFD0D0D8),
    chartBlue: Color(0xFF60A5FA),
    chartYellow: Color(0xFFFBBF24),
    chartGreen: Color(0xFF10B981),
    chartPurple: Color(0xFFA78BFA),
    tertiary: Color(0xFFFFB800),
    warning: Color(0xFFE0A838),
    success: Color(0xFF00C896),
    successSoft: Color(0x1900C896),
    accentRed: Color(0xFFE84B57),
    accentRedAlt: Color(0xFFE74D5B),
    accentRedSoft: Color(0xFFED5A61),
    accentPurple: Color(0xFF9B3EE8),
    accentPink: Color(0xFFE03A5E),
    accentBlueMuted: Color(0xFF5A6478),
    mutedSecondary: Color(0xFF68697A),
    mutedSecondaryAlt: Color(0xFF6C6C7A),
    mutedSecondarySoft: Color(0xFF8888A0),
    mutedSecondaryDeep: Color(0xFF505060),
    mutedSecondaryHeader: Color(0xFF828290),
    mutedSecondaryVibe: Color(0xFF78788C),
    mutedSecondaryHighlight: Color(0xFF6050E8),
    shadowMedium: Color(0x1F000000),
    shadowStrong: Color(0x2E000000),
    shadowSoft: Color(0x12000000),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

extension AppColorsX on BuildContext {
  AppColors get colors => AppColors.of(this);
}
