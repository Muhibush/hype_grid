import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D0D0D); // Very dark almost black
  static const Color surface = Color(0xFF141414); // Slightly lighter for cards
  static const Color surfaceHighlight = Color(0xFF1E1E1E);

  static const Color primary = Color(
    0xFFE94560,
  ); // Vibrant red/pink for active states
  static const Color primaryDim = Color(
    0x33E94560,
  ); // Dimmed primary for unfocused pills

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0B0);
  static const Color textTertiary = Color(0xFF666666);

  // Specific styling from mockups
  static const Color hypeBadgeBackground = primary;
  static const Color normalBadgeBackground = surfaceHighlight;
  static const Color surfaceCard = Color(0xFF1A1A2E);
  static const Color surfaceCardHype = Color(0xFF2A1A3E);
  static const Color navBarColor = Color(0xFF111111);
  static const Color divider = Color(0xFF222222);
}
