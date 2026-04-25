import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF25AFF4),
      primary: const Color(0xFF006590),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF25AFF4),
      onPrimaryContainer: const Color(0xFF003F5C),
      secondary: const Color(0xFF3C627D),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFB8DFFE),
      onSecondaryContainer: const Color(0xFF3D637E),
      tertiary: const Color(0xFF845400),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFE3940A),
      onTertiaryContainer: const Color(0xFF543400),
      surface: const Color(0xFFF6FAFF),
      onSurface: const Color(0xFF171C20),
      outline: const Color(0xFF6E7881),
      outlineVariant: const Color(0xFFBDC8D2),
    ),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    chipTheme: const ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.95),
      indicatorColor: const Color(0xFFE0F2FE),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF075985)),
      ),
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
  );
}

ThemeData appDarkTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF25AFF4),
      brightness: Brightness.dark,
      surface: const Color(0xFF101C22),
    ),
    useMaterial3: true,
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
  );
}
