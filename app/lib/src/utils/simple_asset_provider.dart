import 'package:flutter/services.dart';
import 'package:mno_server/mno_server.dart';

class SimpleAssetProvider extends AssetProvider {
  @override
  Future<ByteData> load(String path) => rootBundle.load(path);
}
