// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/widgets.dart';
import 'package:model/model.dart';
import 'package:navigator/src/pdf/ui/pdf_book_screen.dart';
import 'package:ui_commons/document_opener/document_opener.dart';

class PdfDocumentOpener extends DocumentOpener {
  @override
  Widget buildDocumentScreen(
    FileDocument document, {
    bool simplifiedMode = false,
    OnCloseDocument onCloseDocument,
  }) =>
      PdfBookScreen(
        book: document as Book,
        simplifiedMode: simplifiedMode,
        onCloseDocument:
            onCloseDocument ?? DocumentOpener.defaultOnCloseDocument,
      );
}
