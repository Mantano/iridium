import 'package:flutter/material.dart';
import 'package:iridium_app/theme/theme_config.dart';
import 'package:iridium_app/util/router.dart';
import 'package:iridium_app/view_models/app_provider.dart';
import 'package:iridium_app/views/downloads/downloads.dart';
import 'package:iridium_app/views/favorites/favorites.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late List items;

  @override
  void initState() {
    super.initState();
    items = [
      {
        'icon': Feather.heart,
        'title': 'Favorites',
        'function': () => _pushPage(const Favorites()),
      },
      {
        'icon': Feather.download,
        'title': 'Downloads',
        'function': () => _pushPage(const Downloads()),
      },
      {
        'icon': Feather.moon,
        'title': 'Dark Mode',
        'function': () => _pushPage(const Downloads()),
      },
      {
        'icon': Feather.info,
        'title': 'About',
        'function': () => showAbout(),
      },
      {
        'icon': Feather.file_text,
        'title': 'Licenses',
        'function': () => _pushPageDialog(const LicensePage()),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Remove Dark Switch if Device has Dark mode enabled
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      items.removeWhere((item) => item['title'] == 'Dark Mode');
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Settings',
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          if (items[index]['title'] == 'Dark Mode') {
            return _buildThemeSwitch(items[index]);
          }

          return ListTile(
            onTap: items[index]['function'],
            leading: Icon(
              items[index]['icon'],
            ),
            title: Text(
              items[index]['title'],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }

  Widget _buildThemeSwitch(Map item) {
    return SwitchListTile(
      secondary: Icon(
        item['icon'],
      ),
      title: Text(
        item['title'],
      ),
      value: Provider.of<AppProvider>(context).theme == ThemeConfig.lightTheme
          ? false
          : true,
      onChanged: (v) {
        if (v) {
          Provider.of<AppProvider>(context, listen: false)
              .setTheme(ThemeConfig.darkTheme, 'dark');
        } else {
          Provider.of<AppProvider>(context, listen: false)
              .setTheme(ThemeConfig.lightTheme, 'light');
        }
      },
    );
  }

  _pushPage(Widget page) {
    MyRouter.pushPage(context, page);
  }

  _pushPageDialog(Widget page) {
    MyRouter.pushPageDialog(context, page);
  }

  showAbout() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'About',
          ),
          content: const Text(
            'Iridium Demo App by Mantano, adapted from JideGuru\'s Flutter eBook App',
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                    TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }
}
