import 'package:flutter/material.dart';

class WShadow {
  const WShadow._();

  static List<BoxShadow> get cardGlow => const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 24,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get redGlow => const [
        BoxShadow(
          color: Color(0x59E63946),
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ];
}
