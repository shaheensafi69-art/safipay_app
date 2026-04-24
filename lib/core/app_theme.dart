import 'package:flutter/material.dart';

class SafiTheme {
  static const Color gold = Color(0xFFFFD700);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF1A1A1A);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    primaryColor: gold,
    appBarTheme: const AppBarTheme(backgroundColor: black, elevation: 0),
    colorScheme: const ColorScheme.dark(
      primary: gold,
      surface: darkGrey,
    ),
  );
}