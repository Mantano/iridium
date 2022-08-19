import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:iridium_app/theme/theme_config.dart';
import 'package:iridium_app/util/consts.dart';
import 'package:iridium_app/view_models/app_provider.dart';
import 'package:iridium_app/view_models/details_provider.dart';
import 'package:iridium_app/view_models/favorites_provider.dart';
import 'package:iridium_app/view_models/genre_provider.dart';
import 'package:iridium_app/view_models/home_provider.dart';
import 'package:iridium_app/views/splash/splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:json_theme/json_theme.dart';
import 'package:mno_webview/webview.dart';
import 'package:universal_io/io.dart' hide Link;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    Fimber.plantTree(FimberTree());
  } else {
    Fimber.plantTree(DebugBufferTree());
  }

  if (kDebugMode && Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // Theme was generated with https://zeshuaro.github.io/appainter/#/
  ThemeConfig.lightTheme = await loadTheme('assets/appainter_light_theme.json');
  ThemeConfig.darkTheme = await loadTheme('assets/appainter_dark_theme.json');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DetailsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<ThemeData> loadTheme(String themeAssetPath) async {
  final themeStr = await rootBundle.loadString(themeAssetPath);
  final themeJson = jsonDecode(themeStr);
  final lightTheme = ThemeDecoder.decodeThemeData(themeJson)!;
  return lightTheme;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<AppProvider>(
        builder:
            (BuildContext context, AppProvider appProvider, Widget? child) =>
                MaterialApp(
          key: appProvider.key,
          debugShowCheckedModeBanner: false,
          navigatorKey: appProvider.navigatorKey,
          title: Constants.appName,
          theme: themeData(appProvider.theme),
          darkTheme: themeData(ThemeConfig.darkTheme!),
          home: const Splash(),
        ),
      );

  // Apply font to our app's theme
  ThemeData themeData(ThemeData theme) => theme.copyWith(
        textTheme: GoogleFonts.sourceSansProTextTheme(
          theme.textTheme,
        ),
      );
}
