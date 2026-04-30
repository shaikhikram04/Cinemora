import 'package:flutter/material.dart';
import 'package:watchary/core/constants/colors.dart';

class WTextTheme {
  const WTextTheme._();

  static TextStyle h1 = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: WColors.foreground,
  );

  static TextStyle h2 = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: WColors.foreground,
  );

  static TextStyle h3 = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: WColors.foreground,
  );

  static TextStyle body = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: WColors.mutedForeground,
  );

  static TextStyle label = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: WColors.primary,
  );

  static TextStyle button = const TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: WColors.primaryForeground,
  );
}
