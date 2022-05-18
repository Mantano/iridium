import 'dart:io';

import 'package:objectdb/objectdb.dart';
// ignore: implementation_imports
import 'package:objectdb/src/objectdb_storage_filesystem.dart';
import 'package:path_provider/path_provider.dart';

class LocatorDB {
  Future<String> getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentDirectory.path}/locator.db';
    return path;
  }

  //Insertion
  Future add(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    db.insert(item);
    await db.close();
  }

  Future update(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    int update = await db.update({'bookId': item['bookId']}, item);
    if (update == 0) {
      db.insert(item);
    }
    await db.close();
  }

  Future<int> remove(Map item) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    int val = await db.remove(item);
    await db.close();
    return val;
  }

  Future<List> listAll() async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    List val = await db.find({});
    await db.close();
    return val;
  }

  Future<List> getLocator(String id) async {
    final db = ObjectDB(FileSystemStorage(await getPath()));
    List val = await db.find({'bookId': id});
    await db.close();
    return val;
  }
}
