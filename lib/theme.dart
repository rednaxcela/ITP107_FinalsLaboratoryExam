import 'package:flutter/material.dart';

/// Black and white palette used across all screens.
class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF7F7F7);
  static const Color border = Color(0xFFE0E0E0);
  static const Color noteBackground = Color(0xFFEFEFEF);
  static const Color noteText = Color(0xFF212121);
  static const Color success = Color(0xFF212121);
  static const Color danger = Color(0xFF000000);

  /// Shades of grey used for the numbered avatars on post cards.
  static const List<Color> avatars = [
    Color(0xFF000000),
    Color(0xFF212121),
    Color(0xFF424242),
    Color(0xFF616161),
    Color(0xFF303030),
    Color(0xFF525252),
  ];
}

/// One shared theme so every screen looks the same.
ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: Colors.black,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFEDEDED),
    onPrimaryContainer: Colors.black,
    secondary: Color(0xFF212121),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE6E6E6),
    onSecondaryContainer: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    outline: Color(0xFF757575),
    error: Colors.black,
    onError: Colors.white,
    inverseSurface: Colors.black,
    onInverseSurface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF424242)),
      bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF212121)),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: const BorderSide(color: Colors.black, width: 1.4),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black,
      contentTextStyle: const TextStyle(color: Colors.white),
      actionTextColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
