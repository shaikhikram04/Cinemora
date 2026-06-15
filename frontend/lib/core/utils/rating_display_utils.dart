import 'package:flutter/material.dart';
import 'package:cinemora/core/constants/colors.dart';

String ratingLabelFor(double value) {
  if (value == 5.0) return 'Masterpiece';
  if (value >= 4.5) return 'Excellent';
  if (value >= 4.0) return 'Great';
  if (value >= 3.5) return 'Good';
  if (value >= 3.0) return 'Decent';
  if (value >= 2.5) return 'Below Average';
  if (value >= 2.0) return 'Bad';
  if (value >= 1.5) return 'Very Bad';
  if (value >= 1.0) return 'Terrible';

  return 'Avoid it';
}

Color ratingColorFor(double value) {
  if (value == 5.0) return Colors.tealAccent;
  if (value >= 4.5) return Colors.greenAccent;
  if (value >= 4.0) return Colors.green;
  if (value >= 3.5) return Colors.lightGreen;
  if (value >= 3.0) return Colors.amberAccent;
  if (value >= 2.5) return Colors.amberAccent;
  if (value >= 2.0) return Colors.orangeAccent;
  if (value >= 1.5) return Colors.deepOrangeAccent;
  if (value >= 1.0) return WColors.accentRed;

  return WColors.accentRed;
}

String ratingEmojiFor(double value) {
  if (value == 5.0) return '🏆';
  if (value >= 4.5) return '🤩';
  if (value >= 4.0) return '😊';
  if (value >= 3.5) return '👍';
  if (value >= 3.0) return '😑';
  if (value >= 2.5) return '🤔';
  if (value >= 2.0) return '😐';
  if (value >= 1.5) return '😞';
  if (value >= 1.0) return '😤';

  return '💀';
}

const List<Color> kRatingGradientColors = [
  WColors.accentRed, // 0.5
  Colors.deepOrangeAccent, // 1.0
  Colors.orangeAccent, // 1.5
  Colors.amber, // 2.0
  Colors.amberAccent, // 2.5 – 3.0
  Colors.lightGreen, // 3.5
  Colors.green, // 4.0
  Colors.greenAccent, // 4.5
  Colors.tealAccent, // 5.0
];
