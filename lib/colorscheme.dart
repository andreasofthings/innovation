import 'package:flutter/material.dart';


ColorScheme schema() {
  return ColorScheme.fromSeed(
    seedColor: const Color(0xFF25AFF4),
    surface: const Color(0xFFF5F7F8),
  );
}

ColorScheme darkSchema() {
  return ColorScheme.fromSeed(
    seedColor: const Color(0xFF25AFF4),
    brightness: Brightness.dark,
    surface: const Color(0xFF101C22),
  );
}
