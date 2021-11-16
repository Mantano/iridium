import 'dart:io';

import 'io/idb_io.dart' if (dart.library.html) 'web/idb_web.dart';
import 'package:path_provider/path_provider.dart';

class FavoriteDB {
  static const storeName = 'favorites';
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
  add(key, value) async {
    var db = await database;
    var txn = db.transaction(storeName, idbModeReadWrite);
    var store = txn.objectStore(storeName);
    await store.put(value, key);
  }

  Future<int> remove(String key) async {
    var db = await database;
    var txn = db.transaction(storeName, idbModeReadWrite);
    var store = txn.objectStore(storeName);
    var val = await store.getObject(key);
    await store.delete(key);
    return Future.value(1);
  }

  Future<List> listAll() async {
    var db = await database;
    var txn = db.transaction(storeName, idbModeReadWrite);
    var store = txn.objectStore(storeName);
    return await store.getAll();
  }

  Future<List> check(String key) async {
    var db = await database;
    var txn = db.transaction(storeName, idbModeReadWrite);
    var store = txn.objectStore(storeName);
    return await store.getAll(key);
  }
}
