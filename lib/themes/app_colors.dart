import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

/// Application color schemes and palettes
class AppColors {
  // Primary colors - Space theme
  static const Color primary = Color(0xFF6366F1);          // Main primary color
  static const Color onPrimary = Color(0xFFFFFFFF);        // Text/icons on primary
  static const Color primaryBlue = Color(0xFF1E3A8A);      // Deep space blue
  static const Color primaryPurple = Color(0xFF6366F1);    // Cosmic purple
  static const Color primaryIndigo = Color(0xFF4F46E5);    // Nebula indigo
  
  // Secondary colors - Cosmic theme
  static const Color secondaryPink = Color(0xFFEC4899);     // Cosmic pink
  static const Color secondaryTeal = Color(0xFF06B6D4);    // Stellar teal
  static const Color secondaryAmber = Color(0xFFF59E0B);   // Solar amber
  
  // Accent colors - Galaxy theme
  static const Color accentViolet = Color(0xFFA855F7);     // Galaxy violet
  static const Color accentRose = Color(0xFFF43F5E);       // Stellar rose
  static const Color accentEmerald = Color(0xFF10B981);    // Cosmic emerald
  
  // Neutral colors - Space grays
  static const Color neutralDark = Color(0xFF0F172A);      // Deep space
  static const Color neutralMedium = Color(0xFF334155);    // Space gray
  static const Color neutralLight = Color(0xFF64748B);     // Light space gray
  static const Color neutralLighter = Color(0xFF94A3B8);  // Lighter space gray
  static const Color neutralLightest = Color(0xFFF1F5F9);  // Almost white
  
  // Semantic colors
  static const Color success = Color(0xFF22C55E);          // Success green
  static const Color warning = Color(0xFFF59E0B);          // Warning amber
  static const Color error = Color(0xFFEF4444);            // Error red
  static const Color info = Color(0xFF3B82F6);             // Info blue
  
  // Background colors
  static const Color backgroundDark = Color(0xFF0F172A);   // Dark background
  static const Color backgroundLight = Color(0xFFFFFFFF);  // Light background
  static const Color surfaceDark = Color(0xFF1E293B);      // Dark surface
  static const Color surfaceLight = Color(0xFFF8FAFC);     // Light surface
  
  // Text colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);  // Primary text on dark
  static const Color textPrimaryLight = Color(0xFF0F172A); // Primary text on light
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Secondary text on dark
  static const Color textSecondaryLight = Color(0xFF64748B); // Secondary text on light
  
  // Gradient colors
  static const List<Color> spaceGradient = [
    Color(0xFF0F172A), // Deep space
    Color(0xFF1E293B), // Space gray
    Color(0xFF334155), // Medium space
  ];
  
  static const List<Color> cosmicGradient = [
    Color(0xFF6366F1), // Cosmic purple
    Color(0xFFA855F7), // Galaxy violet
    Color(0xFFEC4899), // Cosmic pink
  ];
  
  static const List<Color> nebulaGradient = [
    Color(0xFF4F46E5), // Nebula indigo
    Color(0xFF06B6D4), // Stellar teal
    Color(0xFF10B981), // Cosmic emerald
  ];
  
  static const List<Color> sunsetGradient = [
    Color(0xFFF59E0B), // Solar amber
    Color(0xFFEC4899), // Cosmic pink
    Color(0xFFF43F5E), // Stellar rose
  ];
  
  // Shimmer colors
  static const List<Color> shimmerLightColors = [
    Color(0xFFE2E8F0),
    Color(0xFFF1F5F9),
    Color(0xFFE2E8F0),
  ];
  
  static const List<Color> shimmerDarkColors = [
    Color(0xFF1E293B),
    Color(0xFF334155),
    Color(0xFF1E293B),
  ];
  
  // Overlay colors
  static Color overlayLight = Colors.black.withAlpha(ColorUtils.safeAlpha(0.3));
  static Color overlayMedium = Colors.black.withAlpha(ColorUtils.safeAlpha(0.5));
  static Color overlayDark = Colors.black.withAlpha(ColorUtils.safeAlpha(0.7));
  
  // Border colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  
  // Shadow colors
  static Color shadowLight = Colors.black.withAlpha(ColorUtils.safeAlpha(0.1));
  static Color shadowMedium = Colors.black.withAlpha(ColorUtils.safeAlpha(0.2));
  static Color shadowDark = Colors.black.withAlpha(ColorUtils.safeAlpha(0.3));
  
  // Helper methods
  static Color getTextColor(bool isDark) {
    return isDark ? textPrimaryDark : textPrimaryLight;
  }
  
  static Color getSecondaryTextColor(bool isDark) {
    return isDark ? textSecondaryDark : textSecondaryLight;
  }
  
  static Color getBackgroundColor(bool isDark) {
    return isDark ? backgroundDark : backgroundLight;
  }
  
  static Color getSurfaceColor(bool isDark) {
    return isDark ? surfaceDark : surfaceLight;
  }
  
  static Color getBorderColor(bool isDark) {
    return isDark ? borderDark : borderLight;
  }
  
  static List<Color> getShimmerColors(bool isDark) {
    return isDark ? shimmerDarkColors : shimmerLightColors;
  }
  
  static LinearGradient getSpaceGradient({AlignmentGeometry? begin, AlignmentGeometry? end}) {
    return LinearGradient(
      begin: begin ?? Alignment.topLeft,
      end: end ?? Alignment.bottomRight,
      colors: spaceGradient,
    );
  }
  
  static LinearGradient getCosmicGradient({AlignmentGeometry? begin, AlignmentGeometry? end}) {
    return LinearGradient(
      begin: begin ?? Alignment.topLeft,
      end: end ?? Alignment.bottomRight,
      colors: cosmicGradient,
    );
  }
  
  static LinearGradient getNebulaGradient({AlignmentGeometry? begin, AlignmentGeometry? end}) {
    return LinearGradient(
      begin: begin ?? Alignment.topLeft,
      end: end ?? Alignment.bottomRight,
      colors: nebulaGradient,
    );
  }
  
  static LinearGradient getSunsetGradient({AlignmentGeometry? begin, AlignmentGeometry? end}) {
    return LinearGradient(
      begin: begin ?? Alignment.topLeft,
      end: end ?? Alignment.bottomRight,
      colors: sunsetGradient,
    );
  }
}