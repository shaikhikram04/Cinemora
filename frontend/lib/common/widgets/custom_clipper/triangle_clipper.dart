import 'package:flutter/material.dart';

class TopRightTriangleClipper extends CustomClipper<Path> {
  const TopRightTriangleClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant TopRightTriangleClipper oldClipper) => false;
}
