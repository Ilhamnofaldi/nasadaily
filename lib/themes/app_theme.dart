import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Application theme configuration
class AppTheme {
  static final AppTheme _instance = AppTheme._internal();
  factory AppTheme() => _instance;
  AppTheme._internal();
  
  // Theme mode
  static ThemeMode themeMode = ThemeMode.system;
  
  /// Light color scheme
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryBlue,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryPink,
    onSecondary: Colors.white,
    tertiary: AppColors.accentViolet,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    background: AppColors.backgroundLight,
    onBackground: AppColors.textPrimaryLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceVariant: AppColors.neutralMedium,
    onSurfaceVariant: AppColors.textSecondaryLight,
    outline: AppColors.borderLight,
    shadow: AppColors.neutralDark,
   );
   
   /// Dark color scheme
   static const ColorScheme _darkColorScheme = ColorScheme(
     brightness: Brightness.dark,
     primary: AppColors.primaryBlue,
     onPrimary: Colors.white,
     secondary: AppColors.secondaryPink,
     onSecondary: Colors.white,
     tertiary: AppColors.accentViolet,
     onTertiary: Colors.white,
     error: AppColors.error,
     onError: Colors.white,
     background: AppColors.backgroundDark,
     onBackground: AppColors.textPrimaryDark,
     surface: AppColors.surfaceDark,
     onSurface: AppColors.textPrimaryDark,
     surfaceVariant: AppColors.neutralMedium,
     onSurfaceVariant: AppColors.textSecondaryDark,
     outline: AppColors.borderDark,
     shadow: AppColors.neutralDark,
   );
   
   /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.neutralDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: AppTypography.fontSize20,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textPrimaryLight,
          fontFamily: AppTypography.primaryFontFamily,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: AppColors.surfaceLight,
        elevation: 2,
        shadowColor: AppColors.neutralDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.neutralDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: AppTypography.fontSize16,
            fontWeight: AppTypography.semiBold,
            fontFamily: AppTypography.primaryFontFamily,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontSize: AppTypography.fontSize16,
            fontWeight: AppTypography.medium,
            fontFamily: AppTypography.primaryFontFamily,
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: AppTypography.fontSize16,
            fontWeight: AppTypography.medium,
            fontFamily: AppTypography.primaryFontFamily,
          ),
        ),
      ),
      
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: AppTypography.fontSize16,
          fontFamily: AppTypography.secondaryFontFamily,
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: AppTypography.fontSize12,
          fontWeight: AppTypography.medium,
          fontFamily: AppTypography.primaryFontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppTypography.fontSize12,
          fontWeight: AppTypography.regular,
          fontFamily: AppTypography.primaryFontFamily,
        ),
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
        linearTrackColor: AppColors.borderLight,
        circularTrackColor: AppColors.borderLight,
      ),
      
      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: AppTypography.fontSize14,
          fontFamily: AppTypography.secondaryFontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        titleTextStyle: TextStyle(
          fontSize: AppTypography.fontSize20,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textPrimaryLight,
          fontFamily: AppTypography.primaryFontFamily,
        ),
        contentTextStyle: TextStyle(
          fontSize: AppTypography.fontSize16,
          color: AppColors.textPrimaryLight,
          fontFamily: AppTypography.secondaryFontFamily,
        ),
      ),
    );
  }
  
  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.neutralDark,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: AppTypography.fontSize20,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textPrimaryDark,
          fontFamily: AppTypography.primaryFontFamily,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 2,
        shadowColor: AppColors.neutralDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.neutralDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: AppTypography.fontSize16,
            fontWeight: AppTypography.semiBold,
            fontFamily: AppTypography.primaryFontFamily,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontSize: AppTypography.fontSize16,
            fontWeight: AppTypography.medium,
            fontFamily: AppTypography.primaryFontFamily,
          ),
        ),
      ),
      
      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: BorderSide(color: AppColors.borderDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: AppTypography.fontSize16,
            fontWeight: AppTypography.medium,
            fontFamily: AppTypography.primaryFontFamily,
          ),
        ),
      ),
      
      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: AppTypography.fontSize16,
          fontFamily: AppTypography.secondaryFontFamily,
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: AppTypography.fontSize12,
          fontWeight: AppTypography.medium,
          fontFamily: AppTypography.primaryFontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppTypography.fontSize12,
          fontWeight: AppTypography.regular,
          fontFamily: AppTypography.primaryFontFamily,
        ),
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
        linearTrackColor: AppColors.borderDark,
        circularTrackColor: AppColors.borderDark,
      ),
      
      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: AppTypography.fontSize14,
          fontFamily: AppTypography.secondaryFontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        titleTextStyle: TextStyle(
          fontSize: AppTypography.fontSize20,
          fontWeight: AppTypography.semiBold,
          color: AppColors.textPrimaryDark,
          fontFamily: AppTypography.primaryFontFamily,
        ),
        contentTextStyle: TextStyle(
          fontSize: AppTypography.fontSize16,
          color: AppColors.textPrimaryDark,
          fontFamily: AppTypography.secondaryFontFamily,
        ),
      ),
    );
  }
  

  
  // Utility methods
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  static Color getPrimaryColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.primaryBlue : AppColors.neutralLightest;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.backgroundDark : AppColors.backgroundLight;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.surfaceDark : AppColors.surfaceLight;
  }
  
  static Color getTextColor(BuildContext context) {
    return isDarkMode(context) ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }
}