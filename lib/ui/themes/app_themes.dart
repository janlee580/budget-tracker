
import 'package:flutter/material.dart';
import 'app_colors.dart';

// --- Themes ---
final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF4F6F6),
    primaryColor: primaryGreen,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryBlue,
      error: warningRed,
      onPrimary: white,
      onSecondary: textBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textBlack),
      titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textBlack),
    ),
    cardTheme: CardThemeData(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: white,
      shadowColor: lightGrey.withAlpha(128),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ));

final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: darkPrimary,
  primaryColor: primaryGreen,
  fontFamily: 'Poppins',
  colorScheme: const ColorScheme.dark(
    primary: primaryGreen,
    secondary: secondaryBlue,
    error: warningRed,
    surface: darkSecondary,
    onSurface: darkText,
    onPrimary: textBlack,
    onSecondary: textBlack,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: darkText),
    titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkText),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: darkSecondary,
    shadowColor: Colors.black.withAlpha(128),
    margin: const EdgeInsets.symmetric(vertical: 8),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: primaryGreen,
    unselectedItemColor: Colors.grey,
    backgroundColor: darkSecondary,
    type: BottomNavigationBarType.fixed,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: const OutlineInputBorder(),
    labelStyle: TextStyle(color: darkText.withAlpha(200)),
  ),
  // Add other dark theme properties if needed
);
