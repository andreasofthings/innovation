import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF25AFF4),
      primary: const Color(0xFF006590),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF25AFF4),
      secondary: const Color(0xFF3C627D),
      tertiary: const Color(0xFF845400),
      surface: const Color(0xFFF6FAFF),
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
