import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:iridium_app/util/dialogs.dart';
import 'package:iridium_app/views/downloads/downloads.dart';
import 'package:iridium_app/views/explore/explore.dart';
import 'package:iridium_app/views/home/home.dart';
import 'package:iridium_app/views/settings/settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _page = 0;

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async =>
            (await Dialogs().showExitDialog(context)) ?? false,
        child: Scaffold(
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: onPageChanged,
            children: const <Widget>[
              Home(),
              Downloads(),
              Explore(),
              Profile(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Theme.of(context).bottomAppBarTheme.color,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            unselectedItemColor: Colors.grey[500],
            elevation: 20,
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Feather.home,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Feather.download,
                ),
                label: 'Downloads',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Feather.compass,
                ),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Feather.settings,
                ),
                label: 'Settings',
              ),
            ],
            onTap: navigationTapped,
            currentIndex: _page,
          ),
        ),
      );

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }
}
