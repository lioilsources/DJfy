import 'package:flutter/material.dart';

const kNeonCyan = Color(0xFF00E5FF);
const kNeonPurple = Color(0xFFBB00FF);
const kDeckBg = Color(0xFF0D0D0D);
const kCardBg = Color(0xFF1A1A2E);
const kSurface = Color(0xFF16213E);

final djTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kDeckBg,
  colorScheme: const ColorScheme.dark(
    primary: kNeonCyan,
    secondary: kNeonPurple,
    surface: kSurface,
    onPrimary: Colors.black,
    onSecondary: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kCardBg,
    foregroundColor: kNeonCyan,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: kNeonCyan,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  ),
  cardTheme: const CardThemeData(
    color: kCardBg,
    elevation: 4,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kNeonCyan, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kNeonCyan.withAlpha(80), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kNeonCyan, width: 2),
    ),
    hintStyle: const TextStyle(color: Colors.white38),
    labelStyle: const TextStyle(color: kNeonCyan),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: kNeonCyan,
    inactiveTrackColor: Colors.white24,
    thumbColor: kNeonCyan,
    overlayColor: Color(0x2900E5FF),
  ),
  iconTheme: const IconThemeData(color: kNeonCyan),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white54),
    labelSmall: TextStyle(color: kNeonCyan, letterSpacing: 1),
  ),
  useMaterial3: true,
);
