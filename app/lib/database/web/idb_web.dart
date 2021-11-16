import 'dart:io';

import 'package:idb_shim/idb_shim.dart';
import 'package:idb_sqflite/idb_client_sqflite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

export 'package:idb_shim/idb_shim.dart';

IdbFactory get idbFactory {
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  return getIdbFactorySqflite(databaseFactory);
}
