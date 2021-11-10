// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:typed_data';

import 'package:navigator/src/epub/callbacks/model/pagination_info.dart';

class ThumbnailSavingInfo {
  final Uint8List data;
  final Page page;
  final int sectionFirstPage;
  final int spineItemIndex;
  final String thumbnailsPath;

  const ThumbnailSavingInfo(this.data, this.page, this.sectionFirstPage,
      this.spineItemIndex, this.thumbnailsPath);
}
