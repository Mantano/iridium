// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared/fetcher.dart';
import 'package:mno_streamer/pdf.dart';

mixin PdfDocumentFactory {
  Future<PdfDocument> openFile(String filePath, {String? password});

  Future<PdfDocument> openResource(Resource resource, {String? password});
}
