import 'dart:io';

import 'io/idb_io.dart' if (dart.library.html) 'web/idb_web.dart';
import 'package:path_provider/path_provider.dart';

class DownloadsDB {
  static const storeName = 'downloads';
  var valueKey = 'value';

  Future<Database> database = () async {
    var db = await idbFactory.open('$storeName.db', version: 1,
        onUpgradeNeeded: (e) {
      var db = e.database;
      db.createObjectStore(storeName);
    });
    return db;
  }();

  //Insertion
  add(String key, Map value) async {
    var db = await database;
    var txn = db.transaction(storeName, idbModeReadWrite);
    var store = txn.objectStore(storeName);
    await store.put(value, key);
  }

  remove(String? key) async {
    if (key != null) {
      var db = await database;
      var txn = db.transaction(storeName, idbModeReadWrite);
      var store = txn.objectStore(storeName);
      var val = await store.getObject(key);
      await store.delete(key);
    }
  }

  removeAllWithId(String? key) async {
    if (key != null) remove(key);
  }

  Future<List> listAll() async {
    var db = await database;
    var txn = db.transaction(storeName, idbModeReadWrite);
    var store = txn.objectStore(storeName);
    return await store.getAll();
  }

  Future<List> check(String? key) async {
    if (key == null) return Future.value([]);
    var db = await database;
    var txn = db.transaction(storeName, idbModeReadWrite);
    var store = txn.objectStore(storeName);
    return await store.getAll(key);
  }

  clear() async {
    var db = await database;
    var txn = db.transaction(storeName, idbModeReadWrite);
    var store = txn.objectStore(storeName);
    return await store.clear();
  }
}
