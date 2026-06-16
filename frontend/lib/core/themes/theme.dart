import 'package:flutter/material.dart';
import 'package:cinemora/core/constants/app_colors.dart';
import 'package:cinemora/core/constants/sizes.dart';
import 'package:cinemora/core/themes/custom_theme/text_theme.dart';

class WTheme {
  const WTheme._();

  static final ThemeData lightTheme = _build(AppColors.light, Brightness.light);
  static final ThemeData darkTheme = _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final ts = WTextTheme(c);
    return ThemeData(
      fontFamily: 'Inter',
      fontFamilyFallback: const ['SF Pro Display', 'Segoe UI', 'sans-serif'],
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary,
        onPrimary: c.primaryForeground,
        secondary: c.chartBlue,
        onSecondary: c.foreground,
        surface: c.card,
        onSurface: c.foreground,
        error: c.accentRed,
        onError: c.primaryForeground,
        outline: c.border,
      ),
      cardColor: c.card,
      dividerColor: c.border,
      textTheme: TextTheme(
        headlineLarge: ts.h1,
        headlineMedium: ts.h2,
        headlineSmall: ts.h3,
        bodyLarge: ts.body,
        bodyMedium: ts.body,
        labelLarge: ts.label,
        titleMedium: ts.button,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: c.foreground,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.input,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WSizes.radiusLg),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WSizes.radiusLg),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WSizes.radiusLg),
          borderSide: BorderSide(color: c.primary.withValues(alpha: 0.6)),
        ),
        hintStyle: ts.body,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.primaryForeground,
          textStyle: ts.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WSizes.radiusXl),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.foreground,
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WSizes.radiusXl),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.mutedForeground,
        ),
      ),
    );
  }
}
