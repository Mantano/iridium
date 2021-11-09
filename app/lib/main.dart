import 'package:app/src/models/notifiers/book_notifier.dart';
import 'package:app/src/models/notifiers/theme_notifier.dart';
import 'package:app/src/screens/home_screen.dart';
import 'package:app/src/utils/utils.dart';
import 'package:fimber/fimber.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/repositories/bloc_factory.dart';
import 'package:provider/provider.dart';
import 'package:app/src/theme/theme.dart' as libraryTheme;
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:app/src/persistence/repository_factory.dart';
import 'package:utils/io/folder_settings.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter/foundation.dart';

import 'src/screens/splashscreen.dart';

void main() async {
  if (kReleaseMode) {
    Fimber.plantTree(FimberTree());
  } else {
    Fimber.plantTree(DebugBufferTree());
  }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Iridium());
}

class Iridium extends StatefulWidget {
  const Iridium({Key key}) : super(key: key);

  @override
  State<Iridium> createState() => _IridiumState();
}

class _IridiumState extends State<Iridium> {
  ThemeBloc themeBloc;

  Future<List> get futures => Future.wait([
        Firebase.initializeApp(),
        // DeviceInformation.init(),
        FolderSettings.init(),
        copySampleBooks(),
        // LcpNative.initLcpNative(),
        // Lcp.initLcp(),
        // //BugsnagSettings.initBugsnagCrashlytics(),
      ]).onError((error, stackTrace) {
        Fimber.i("ERROR when initializing services",
            ex: error, stacktrace: stackTrace);
        return null;
      });

  @override
  void initState() {
    super.initState();
    themeBloc = ThemeBloc();
    themeBloc.stream.listen((state) => themeBloc.updateSystemUiOverlayStyle());
  }

  @override
  Widget build(BuildContext context) {
    // TODO remove and use ThemeBloc instead
    final themeNotifier = ThemeNotifier();
    final bookNotifier = BookNotifier();

    themeBloc.updateSystemUiOverlayStyle();
    return FutureBuilder(
        future: futures,
        builder: (context, snapshot) => BlocBuilder(
            bloc: themeBloc,
            builder: (BuildContext context, ThemeState state) =>
                BlocProvider.value(
                  value: themeBloc,
                  child: MultiProvider(
                    providers: [
                      ChangeNotifierProvider(create: (_) => themeNotifier),
                      ChangeNotifierProvider(create: (_) => bookNotifier),
                    ],
                    child: MaterialApp(
                      title: 'Iridium',
                      debugShowCheckedModeBanner: false,
                      darkTheme: libraryTheme.Theme.darkTheme,
                      // BKRI theme: state.bookariTheme.toThemeData(),
                      theme: themeNotifier.darkModeEnabled
                          ? libraryTheme.Theme.darkTheme
                          : libraryTheme.Theme.lightTheme,
                      home: snapshot.hasData
                          ? const HomeScreen()
                          : const Splashscreen(),
                      //   BookariLocalizations.delegate,
                      //   ReaderSharedLocalizations.delegate.asDelegate(),
                      //   LcpLocalizations.delegate,
                      //   GlobalMaterialLocalizations.delegate,
                      //   GlobalWidgetsLocalizations.delegate,
                      // ],
                      // supportedLocales: supportedLocales,
                    ),
                  ),
                )));
  }

  Future<void> copySampleBooks() async {
    copyFileFromAssets('The_Art_of_War.epub');
    copyFileFromAssets('accessible_epub_3.epub');
  }

  Future<void> copyFileFromAssets(String fileName) async {
    var dirPath = (await Utils.getFileFromAsset("assets/books/$fileName"));
    var filesPath = await FolderSettings.localPathPub;
    print("Copying from ${dirPath.path} to $filesPath");
    await dirPath.copy("$filesPath/The_Art_of_War.epub");
    print("Copied from ${dirPath.path} to $filesPath");
  }
}
