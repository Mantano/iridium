// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/widgets.dart';
import 'package:model/model.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:navigator/playable.dart';

class PlayableDocumentOpener extends DocumentOpener {
  @override
  bool get opaque => false;

  @override
  Widget buildDocumentScreen(
    FileDocument document, {
    bool simplifiedMode = false,
    OnCloseDocument onCloseDocument,
  }) =>
      PlayerScreen(
        playableDocument: document,
        simplifiedMode: simplifiedMode,
        onCloseDocument:
            onCloseDocument ?? DocumentOpener.defaultOnCloseDocument,
      );
}
