// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_streamer_dart/pdf.dart';

mixin PdfDocumentFactory {
  Future<PdfDocument> loadDocument(String filePath, {String password});
}
