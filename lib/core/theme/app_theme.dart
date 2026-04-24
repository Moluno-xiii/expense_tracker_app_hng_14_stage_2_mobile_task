import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

const Color _seed = Color(0xFF0051D5);
const Color _pageBg = Color(0xFFF8FAFC);
const Color _pageBgDark = Color(0xFF0B1120);

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
  );
  final tokens = MyColors.light();
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: _pageBg,
    textTheme: GoogleFonts.manropeTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ),
    extensions: <ThemeExtension<Object?>>[tokens],
    appBarTheme: _appBarTheme(tokens),
    cardTheme: _cardTheme(tokens),
    inputDecorationTheme: _inputTheme(tokens),
    elevatedButtonTheme: _buttonTheme(),
    dividerTheme: DividerThemeData(color: tokens.dividerSoft, thickness: 1),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  );
  final tokens = MyColors.dark();
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: _pageBgDark,
    textTheme: GoogleFonts.manropeTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    extensions: <ThemeExtension<Object?>>[tokens],
    appBarTheme: _appBarTheme(tokens),
    cardTheme: _cardTheme(tokens),
    inputDecorationTheme: _inputTheme(tokens),
    elevatedButtonTheme: _buttonTheme(),
    dividerTheme: DividerThemeData(color: tokens.dividerSoft, thickness: 1),
  );
}

AppBarTheme _appBarTheme(MyColors tokens) => AppBarTheme(
  backgroundColor: tokens.cardSurface,
  foregroundColor: tokens.headingText,
  elevation: 0,
  centerTitle: false,
  titleTextStyle: GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: tokens.brandDeep,
  ),
);

CardThemeData _cardTheme(MyColors tokens) => CardThemeData(
  color: tokens.cardSurface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: tokens.bentoBorder),
  ),
);

InputDecorationTheme _inputTheme(MyColors tokens) => InputDecorationTheme(
  filled: true,
  fillColor: tokens.inputFill,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
  border: _border(tokens.inputBorder),
  enabledBorder: _border(tokens.inputBorder),
  focusedBorder: _border(_seed, width: 1.5),
);

OutlineInputBorder _border(Color c, {double width = 1}) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: BorderSide(color: c, width: width),
);

ElevatedButtonThemeData _buttonTheme() => ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: _seed,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.7,
    ),
  ),
);
