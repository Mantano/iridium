import 'package:fimber/fimber.dart';
import 'package:flutter/services.dart';
import 'package:mno_server/mno_server.dart';

class SimpleAssetProvider extends AssetProvider {
  @override
  Future<ByteData> load(String path) {
    return rootBundle.load(path).catchError((ex, st) {
      Fimber.d("ERROR", ex: ex, stacktrace: st);
      throw ex;
    });
  }
}
