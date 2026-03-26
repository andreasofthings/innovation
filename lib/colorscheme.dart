import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF25AFF4),
      surface: const Color(0xFFF5F7F8),
    ),
    useMaterial3: true,
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
  );

  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
  );
}
