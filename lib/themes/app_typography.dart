import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../utils/color_utils.dart';

/// Application typography and text styles
class AppTypography {
  // Font families
  static const String primaryFontFamily = 'SF Pro Display'; // iOS default
  static const String secondaryFontFamily = 'Roboto';       // Android default
  static const String monospaceFontFamily = 'SF Mono';      // Monospace
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  
  // Font sizes
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  static const double fontSize36 = 36.0;
  static const double fontSize48 = 48.0;
  
  // Line heights
  static const double lineHeight1_2 = 1.2;
  static const double lineHeight1_4 = 1.4;
  static const double lineHeight1_5 = 1.5;
  static const double lineHeight1_6 = 1.6;
  
  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;
  
  // Headline styles
  static TextStyle headline1(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize48,
      fontWeight: extraBold,
      height: lineHeight1_2,
      letterSpacing: letterSpacingTight,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle headline2(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize36,
      fontWeight: bold,
      height: lineHeight1_2,
      letterSpacing: letterSpacingTight,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle headline3(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize32,
      fontWeight: bold,
      height: lineHeight1_2,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle headline4(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize28,
      fontWeight: semiBold,
      height: lineHeight1_4,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle headline5(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize24,
      fontWeight: semiBold,
      height: lineHeight1_4,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle headline6(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize20,
      fontWeight: medium,
      height: lineHeight1_4,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  // Body text styles
  static TextStyle bodyLarge(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize18,
      fontWeight: regular,
      height: lineHeight1_6,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: secondaryFontFamily,
    );
  }
  
  static TextStyle bodyMedium(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize16,
      fontWeight: regular,
      height: lineHeight1_5,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: secondaryFontFamily,
    );
  }
  
  static TextStyle bodySmall(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize14,
      fontWeight: regular,
      height: lineHeight1_5,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getSecondaryTextColor(isDark),
      fontFamily: secondaryFontFamily,
    );
  }
  
  // Label styles
  static TextStyle labelLarge(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize16,
      fontWeight: medium,
      height: lineHeight1_4,
      letterSpacing: letterSpacingWide,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle labelMedium(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize14,
      fontWeight: medium,
      height: lineHeight1_4,
      letterSpacing: letterSpacingWide,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle labelSmall(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize12,
      fontWeight: medium,
      height: lineHeight1_4,
      letterSpacing: letterSpacingWider,
      color: color ?? AppColors.getSecondaryTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  // Special styles
  static TextStyle caption(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize12,
      fontWeight: regular,
      height: lineHeight1_4,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getSecondaryTextColor(isDark),
      fontFamily: secondaryFontFamily,
    );
  }
  
  static TextStyle overline(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize12,
      fontWeight: medium,
      height: lineHeight1_4,
      letterSpacing: letterSpacingWider,
      color: color ?? AppColors.getSecondaryTextColor(isDark),
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle button(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: fontSize16,
      fontWeight: semiBold,
      height: lineHeight1_4,
      letterSpacing: letterSpacingWide,
      color: color ?? Colors.white,
      fontFamily: primaryFontFamily,
    );
  }
  
  static TextStyle monospace(BuildContext context, {Color? color, double? fontSize}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: fontSize ?? fontSize14,
      fontWeight: regular,
      height: lineHeight1_4,
      letterSpacing: letterSpacingNormal,
      color: color ?? AppColors.getTextColor(isDark),
      fontFamily: monospaceFontFamily,
    );
  }
  
  // Utility methods
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withAlpha(ColorUtils.safeAlpha(opacity)));
  }
  
  // Theme data
  static TextTheme getTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: headline1(context),
      displayMedium: headline2(context),
      displaySmall: headline3(context),
      headlineLarge: headline4(context),
      headlineMedium: headline5(context),
      headlineSmall: headline6(context),
      bodyLarge: bodyLarge(context),
      bodyMedium: bodyMedium(context),
      bodySmall: bodySmall(context),
      labelLarge: labelLarge(context),
      labelMedium: labelMedium(context),
      labelSmall: labelSmall(context),
    );
  }
}