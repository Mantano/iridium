import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iridium_app/components/download_alert.dart';
import 'package:iridium_app/database/download_helper.dart';
import 'package:iridium_app/database/favorite_helper.dart';
import 'package:iridium_app/util/api.dart';
import 'package:mno_shared/opds.dart';
import 'package:mno_shared/publication.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailsProvider extends ChangeNotifier {
  ParseData related;
  bool loading = true;
  Publication entry;
  var favDB = FavoriteDB();
  var dlDB = DownloadsDB();

  bool faved = false;
  bool downloaded = false;
  Api api = Api();

  getFeed(String url) async {
    setLoading(true);
    checkFav();
    checkDownload();
    try {
      ParseData feed = await api.getCategory(url);
      setRelated(feed);
      setLoading(false);
    } catch (e) {
      throw (e);
    }
  }

  // check if book is favorited
  checkFav() async {
    List c = await favDB.check(entry.metadata.identifier);
    if (c.isNotEmpty) {
      setFaved(true);
    } else {
      setFaved(false);
    }
  }

  addFav() async {
    await favDB.add(entry.metadata.identifier, jsonEncode(entry));
    checkFav();
  }

  removeFav() async {
    favDB.remove(entry.metadata.identifier).then((v) {
      print(v);
      checkFav();
    });
  }

  // check if book has been downloaded before
  checkDownload() async {
    List downloads = await dlDB.check(entry.metadata.identifier);
    if (downloads.isNotEmpty) {
      // check if book has been deleted
      String path = downloads[0]['path'];
      print(path);
      if (await File(path).exists()) {
        setDownloaded(true);
      } else {
        setDownloaded(false);
      }
    } else {
      setDownloaded(false);
    }
  }

  Future<List> getDownload() async {
    List c = await dlDB.check(entry.metadata.identifier);
    return c;
  }

  addDownload(String key, Map value) async {
    await dlDB.removeAllWithId(entry.metadata.identifier);
    await dlDB.add(key, value);
    checkDownload();
  }

  removeDownload() async {
    dlDB.remove(entry.metadata.identifier).then((v) {
      print(v);
      checkDownload();
    });
  }

  Future downloadFile(BuildContext context, String url, String filename) async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      startDownload(context, url, filename);
    } else {
      startDownload(context, url, filename);
    }
  }

  startDownload(BuildContext context, String url, String filename) async {
    Directory appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      // Directory(appDocDir.path.split('Android')[0] + '${Constants.appName}')
      //     .createSync();
      Directory(appDocDir.path).createSync();
    }

    // String path = Platform.isIOS
    //     ? appDocDir.path + '/$filename.epub'
    //     : appDocDir.path.split('Android')[0] +
    //         '${Constants.appName}/$filename.epub';
    String path = Platform.isIOS
        ? appDocDir.path + '/$filename.epub'
        : appDocDir.path + '/$filename.epub';
    print(path);
    File file = File(path);
    if (!await file.exists()) {
      await file.create();
    } else {
      await file.delete();
      await file.create();
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DownloadAlert(
        url: url,
        path: path,
      ),
    ).then((v) {
      // When the download finishes, we then add the book
      // to our local database
      if (v != null) {
        addDownload(
          entry.metadata.identifier,
          {
            'id': entry.metadata.identifier,
            'path': path,
            'image': '${entry.links[1].href}',
            'size': v,
            'name': entry.metadata.title,
          },
        );
      }
    });
  }

  void setLoading(value) {
    loading = value;
    notifyListeners();
  }

  void setRelated(value) {
    related = value;
    notifyListeners();
  }

  ParseData getRelated() {
    return related;
  }

  void setEntry(value) {
    entry = value;
    notifyListeners();
  }

  void setFaved(value) {
    faved = value;
    notifyListeners();
  }

  void setDownloaded(value) {
    downloaded = value;
    notifyListeners();
  }
}
