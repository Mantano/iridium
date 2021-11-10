// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:fimber/fimber.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:model/model.dart';
import 'package:universal_io/io.dart';
import 'package:utils/io/folder_settings.dart';

class ThumbnailRequestHandler extends RequestHandler {
  final Book book;
  ThumbnailRequestHandler(this.book);

  @override
  Future<bool> handle(int requestId, HttpRequest request, String href) async {
    if (request.uri.path == "/xpub/thumbnail.png") {
      int page = getParamAsInt(request, "page");
      try {
        String cachePath = FolderSettings.instance.cachePath;
        String path = '$cachePath/${book.id}/page$page.png';
        File file = File(path);
        bool exists = await file.exists();
        if (exists) {
          await sendData(
            request,
            data: file.readAsBytesSync(),
            mediaType: await MediaType.ofFilePath(href),
          );
          return true;
        }
      } on Error catch (ex, stacktrace) {
        // For debugging
        Fimber.d("Error loading: $href", ex: ex, stacktrace: stacktrace);
        return false;
      }
    }
    return false;
  }
}
