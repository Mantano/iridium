import 'package:app/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Theme {
  static final ThemeData baseLight = ThemeData.light();
  static final ThemeData baseDark = ThemeData.dark();

  static ThemeData get lightTheme {
    return baseLight.copyWith(
      textTheme: _lightTextTheme,
      primaryColor: kPrimaryColor,
      scaffoldBackgroundColor: kPrimaryColor,
      appBarTheme: _appBarTheme,
      floatingActionButtonTheme: _fabTheme,
      errorColor: kErrorColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: kAccentColor),
    );
  }

  static TextTheme get _lightTextTheme {
    return TextTheme(
      headline6: TextStyle(
        fontFamily: GoogleFonts.nunito().fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: kTextTitleColor,
      ),
      caption: const TextStyle(
        fontFamily: 'GoogleFonts.nunito().fontFamily',
        fontSize: 17.0,
        color: kGreyColor,
        fontWeight: FontWeight.w500,
      ),
      subtitle2: const TextStyle(
        fontFamily: 'GoogleFonts.nunito().fontFamily',
        fontSize: 17.0,
        color: kAccentColor,
      ),
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      elevation: 0,
      color: kPrimaryColor,
      iconTheme: const IconThemeData(
        color: kTextTitleColor,
      ),
      toolbarTextStyle: _lightTextTheme
          .copyWith(
            headline6: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: kTextTitleColor,
            ),
          )
          .bodyText2,
      titleTextStyle: _lightTextTheme
          .copyWith(
            headline6: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: kTextTitleColor,
            ),
          )
          .headline6,
    );
  }

  static FloatingActionButtonThemeData get _fabTheme =>
      const FloatingActionButtonThemeData(backgroundColor: kAccentColor);

  static ThemeData get darkTheme {
    return baseDark.copyWith(
      textTheme: _darkTextTheme,
      primaryColor: kPrimaryColorDark,
      scaffoldBackgroundColor: kPrimaryColorDark,
      appBarTheme: _appBarThemeDark,
      floatingActionButtonTheme: _fabThemeDark,
      errorColor: kErrorColorDark,
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: kAccentColorDark),
    );
  }

  static TextTheme get _darkTextTheme {
    return const TextTheme(
      headline6: TextStyle(
        fontFamily: 'GoogleFonts.nunito().fontFamily',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      caption: TextStyle(
        fontFamily: 'GoogleFonts.nunito().fontFamily',
        fontSize: 17.0,
        color: kGreyColorDark,
        fontWeight: FontWeight.w500,
      ),
      subtitle2: TextStyle(
        fontFamily: 'GoogleFonts.nunito().fontFamily',
        fontSize: 17.0,
        color: kAccentColorDark,
      ),
    );
  }

  static FloatingActionButtonThemeData get _fabThemeDark =>
      const FloatingActionButtonThemeData(
          backgroundColor: kAccentColorDark, foregroundColor: Colors.white);

  static AppBarTheme get _appBarThemeDark {
    return AppBarTheme(
      elevation: 0,
      color: kPrimaryColorDark,
      iconTheme: const IconThemeData(
        color: kTextTitleColorDark,
      ),
      toolbarTextStyle: _darkTextTheme
          .copyWith(
            headline6: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: kTextTitleColorDark,
            ),
          )
          .bodyText2,
      titleTextStyle: _darkTextTheme
          .copyWith(
            headline6: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: kTextTitleColorDark,
            ),
          )
          .headline6,
    );
  }
}
