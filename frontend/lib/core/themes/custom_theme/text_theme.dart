import 'package:flutter/material.dart';
import 'package:cinemora/core/constants/app_colors.dart';

class WTextTheme {
  final AppColors _c;
  const WTextTheme(this._c);

  static WTextTheme of(BuildContext context) => WTextTheme(AppColors.of(context));

  TextStyle get h1 => TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: _c.foreground,
      );

  TextStyle get h2 => TextStyle(
        fontFamily: 'Inter',
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: _c.foreground,
      );

  TextStyle get h3 => TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: _c.foreground,
      );

  TextStyle get body => TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: _c.mutedForeground,
      );

  TextStyle get label => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: _c.primary,
      );

  TextStyle get button => TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: _c.primaryForeground,
      );
}
