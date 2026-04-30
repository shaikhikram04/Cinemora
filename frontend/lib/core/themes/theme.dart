import 'package:flutter/material.dart';
import 'package:watchary/core/constants/colors.dart';
import 'package:watchary/core/constants/sizes.dart';
import 'package:watchary/core/themes/custom_theme/text_theme.dart';

export 'package:watchary/core/themes/onboarding_theme.dart';

class WTheme {
  const WTheme._();

  static final ThemeData lightTheme = _buildAppTheme();

  static final ThemeData darkTheme = _buildAppTheme();

  static ThemeData _buildAppTheme() => ThemeData(
        fontFamily: 'Inter',
        fontFamilyFallback: const ['SF Pro Display', 'Segoe UI', 'sans-serif'],
        brightness: Brightness.dark,
        scaffoldBackgroundColor: WColors.background,
        colorScheme: const ColorScheme.dark(
          primary: WColors.primary,
          onPrimary: WColors.primaryForeground,
          secondary: WColors.chartBlue,
          surface: WColors.card,
          onSurface: WColors.foreground,
          outline: WColors.border,
        ),
        cardColor: WColors.card,
        dividerColor: WColors.border,
        textTheme: TextTheme(
          headlineLarge: WTextTheme.h1,
          headlineMedium: WTextTheme.h2,
          headlineSmall: WTextTheme.h3,
          bodyLarge: WTextTheme.body,
          bodyMedium: WTextTheme.body,
          labelLarge: WTextTheme.label,
          titleMedium: WTextTheme.button,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: WColors.foreground,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: WColors.input,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(WSizes.radiusLg),
            borderSide: const BorderSide(color: WColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(WSizes.radiusLg),
            borderSide: const BorderSide(color: WColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(WSizes.radiusLg),
            borderSide: const BorderSide(color: WColors.primary, width: 1.2),
          ),
          hintStyle: WTextTheme.body,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: WColors.primary,
            foregroundColor: WColors.primaryForeground,
            textStyle: WTextTheme.button,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WSizes.radiusXl),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: WColors.foreground,
            side: const BorderSide(color: WColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WSizes.radiusXl),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: WColors.mutedForeground,
          ),
        ),
      );
}
