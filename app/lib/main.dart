import 'package:app/src/models/notifiers/book_notifier.dart';
import 'package:app/src/models/notifiers/theme_notifier.dart';
import 'package:app/src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/src/theme/theme.dart' as libraryTheme;

void main() {
  runApp(const Iridium());
}

class Iridium extends StatelessWidget {
  const Iridium({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeNotifier();
    final bookNotifier = BookNotifier();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeNotifier),
        ChangeNotifierProvider(create: (_) => bookNotifier),
      ],
      child: MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Iridium',
      darkTheme: libraryTheme.Theme.darkTheme,
      theme: themeNotifier.darkModeEnabled
          ? libraryTheme.Theme.darkTheme
          : libraryTheme.Theme.lightTheme,
      home: HomeScreen(),
    );
  }
}
