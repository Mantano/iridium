import 'package:flutter/material.dart';

class ThemeConfig {
  static Color lightPrimary = Colors.white;
  static Color darkPrimary = const Color(0xff1f1f1f);
  static Color lightAccent = const Color(0xff2ca8e2);
  static Color darkAccent = const Color(0xff2ca8e2);
  static Color lightBG = Colors.white;
  static Color darkBG = const Color(0xff121212);

  static ThemeData? lightTheme;
  static ThemeData? darkTheme;

  static ThemeData lightTheme0 = ThemeData(
    brightness: Brightness.light,
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: const AppBarTheme(
      elevation: 0.0,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: lightAccent,
      brightness: Brightness.light,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: lightAccent),
  );

  static ThemeData darkTheme0 = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBG,
    appBarTheme: const AppBarTheme(
      elevation: 0.0,
    ),
    colorScheme: ColorScheme.fromSwatch()
        .copyWith(secondary: darkAccent, brightness: Brightness.dark),
    textSelectionTheme: TextSelectionThemeData(cursorColor: darkAccent),
  );
}
