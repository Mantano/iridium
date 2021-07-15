// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:r2_server_dart/server.dart';
import 'package:r2_shared_dart/mediatype.dart';
import 'package:universal_io/io.dart';

class AssetsRequestHandler extends RequestHandler {
  /// Folder containing the assets, relative to the root bundle.
  final String path;
  final Uint8List Function(String, Uint8List) transformData;

  AssetsRequestHandler(
    this.path, {
    this.transformData,
  });

  @override
  Future<bool> handle(int requestId, HttpRequest request, String href) async {
    try {
      Uint8List uint8List =
          (await rootBundle.load(p.join(path, href))).buffer.asUint8List();
      if (transformData != null) {
        uint8List = transformData(href, uint8List);
      }

      await sendData(
        request,
        data: uint8List,
        mediaType:
            await MediaType.ofSingleHint(fileExtension: href.extension()),
      );
      return true;
    } on FlutterError catch (ex, _) {
      // For debugging
//      Fimber.d("Error loading: $href", ex: ex, stacktrace: stacktrace);
      return false;
    }
  }
}
