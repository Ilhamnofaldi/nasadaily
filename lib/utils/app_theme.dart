import 'package:flutter/material.dart';

class AppTheme {
  // Space-themed color palette
  static const Color _primaryLight = Color(0xFF4A90E2); // Stellar blue
  static const Color _primaryDark = Color(0xFF6366F1); // Cosmic indigo
  
  static const Color _secondaryLight = Color(0xFF8B5CF6); // Nebula purple
  static const Color _secondaryDark = Color(0xFFA855F7); // Cosmic purple
  
  static const Color _backgroundLight = Color(0xFFF8FAFC); // Light cosmic mist
  static const Color _backgroundDark = Color(0xFF0F0F23); // Deep space
  
  static const Color _surfaceLight = Colors.white;
  static const Color _surfaceDark = Color(0xFF1A1B3A); // Dark nebula
  
  static const Color _errorLight = Color(0xFFEF4444);
  static const Color _errorDark = Color(0xFFF87171);
  
  // Additional space colors
  static const Color _accentGold = Color(0xFFFBBF24); // Stellar gold
  static const Color _deepSpace = Color(0xFF0C0C1E); // Deeper space
  static const Color _starlight = Color(0xFFE2E8F0); // Starlight silver

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        secondary: _secondaryLight,
        surface: _surfaceLight,
        error: _errorLight,
      ),
      scaffoldBackgroundColor: _backgroundLight,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _surfaceLight,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primaryDark,
        secondary: _secondaryDark,
        surface: _surfaceDark,
        error: _errorDark,
        background: _backgroundDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _starlight,
        onBackground: _starlight,
        tertiary: _accentGold,
        surfaceVariant: _deepSpace,
        outline: _primaryDark.withOpacity(0.3),
      ),
      scaffoldBackgroundColor: _backgroundDark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _surfaceDark.withOpacity(0.95),
        foregroundColor: _starlight,
        titleTextStyle: const TextStyle(
          color: _starlight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: _starlight,
          size: 24,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: _primaryDark.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _primaryDark.withOpacity(0.2),
            width: 1,
          ),
        ),
        color: _surfaceDark,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: _primaryDark.withOpacity(0.4),
          backgroundColor: _primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _deepSpace.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _primaryDark.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _primaryDark.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _primaryDark,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color: _starlight.withOpacity(0.6),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _starlight,
        size: 24,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _starlight,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _starlight,
          letterSpacing: 0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _starlight,
          letterSpacing: 0.2,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: _starlight,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _starlight,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: _starlight,
          height: 1.3,
          letterSpacing: 0.1,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surfaceDark,
        selectedItemColor: _primaryDark,
        unselectedItemColor: _starlight.withOpacity(0.6),
        elevation: 8,
      ),
    );
  }
}
