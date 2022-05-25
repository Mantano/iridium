import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:mno_navigator/publication.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ReaderAnnotationsTable {
  static const String name = "ReaderAnnotations";
  static const String id = "id";
  static const String bookId = "bookId";
  static const String location = "location";
  static const String annotation = "annotation";
  static const String style = "style";
  static const String tint = "tint";
  static const String annotationType = "annotationType";

  static const List<String> all = [
    ReaderAnnotationsTable.id,
    ReaderAnnotationsTable.bookId,
    ReaderAnnotationsTable.location,
    ReaderAnnotationsTable.annotation,
    ReaderAnnotationsTable.style,
    ReaderAnnotationsTable.tint,
    ReaderAnnotationsTable.annotationType
  ];
}

class LocatorDB {
  final Database database;

  LocatorDB._(this.database);

  static Future<LocatorDB> createLocatorDB() async {
    Database database = await openDatabase(
      'locator.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
create table if not exists ${ReaderAnnotationsTable.name} ( 
  ${ReaderAnnotationsTable.id} text primary key, 
  ${ReaderAnnotationsTable.bookId} text not null,
  ${ReaderAnnotationsTable.location} text not null,
  ${ReaderAnnotationsTable.annotation} text,
  ${ReaderAnnotationsTable.style} integer,
  ${ReaderAnnotationsTable.tint} integer,
  ${ReaderAnnotationsTable.annotationType} integer not null)
''');
      },
    );
    return LocatorDB._(database);
  }

  Future<String> getPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentDirectory.path}/locator.db';
    return path;
  }

  Future add(Map<String, dynamic> item) async {
    await database.insert(ReaderAnnotationsTable.name, item,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future update(Map<String, dynamic> item) async {
    await database.update(
      ReaderAnnotationsTable.name,
      item,
      where: '${ReaderAnnotationsTable.id} = ?',
      whereArgs: [item['id']],
    );
  }

  Future<int> remove(Map item) => database.delete(
        ReaderAnnotationsTable.name,
        where: '${ReaderAnnotationsTable.id} = ?',
        whereArgs: [item['id']],
      );

  Future<List<Map<String, dynamic>>> listAll() => database.query(
        ReaderAnnotationsTable.name,
        columns: ReaderAnnotationsTable.all,
      );

  Future<List<Map<String, dynamic>>> getLocator(String id) => database.query(
        ReaderAnnotationsTable.name,
        columns: ReaderAnnotationsTable.all,
        where: '${ReaderAnnotationsTable.bookId} = ?',
        whereArgs: [id],
      );

  Future<Map<String, dynamic>?> findById(String id) async =>
      (await database.query(
        ReaderAnnotationsTable.name,
        columns: ReaderAnnotationsTable.all,
        where: '${ReaderAnnotationsTable.id} = ?',
        whereArgs: [id],
      ))
          .firstOrNull;

  Future<Map<String, dynamic>?> findByBookAndType(
          String bookId, AnnotationType annotationType) async =>
      (await database.query(
        ReaderAnnotationsTable.name,
        columns: ReaderAnnotationsTable.all,
        where:
            '${ReaderAnnotationsTable.bookId} = ? AND ${ReaderAnnotationsTable.annotationType} = ?',
        whereArgs: [bookId, annotationType.id],
      ))
          .firstOrNull;
}
