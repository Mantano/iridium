// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_shared/streams.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' hide Link;

class BookCoverGenerator {
  final Publication? publication;

  BookCoverGenerator(this.publication);

  String get coverFileExtension =>
      coverLink?.let((link) => p.extension(link.href)) ?? "";

  Link? get coverLink => publication?.linkWithRel("cover");

  Future<File?> generateAndSetFile(String bookFilePath) async {
    if (coverLink == null) {
      return null;
    }
    var coverImage = await publication?.cover();
    Fimber.d("Image: $coverImage");
    if (coverImage != null) {
      var bokFilePathWithoutExtension = bookFilePath.substring(
          0, bookFilePath.lastIndexOf(p.extension(bookFilePath)));
      var coverHref = publication!.coverLink!.href;
      String coverPath =
          "$bokFilePathWithoutExtension-cover$coverFileExtension";
      Fimber.d("coverPath: $coverPath");
      return saveCover(CoverInfo(coverImage, bookFilePath, coverLink!, coverPath));
    } else {
      return null;
    }
  }

  static Future<File> saveCover(CoverInfo coverInfo) async {
    MediaType? mediaType = await MediaType.ofFilePath(coverInfo.coverLink.href);
    List<int> data;
    if (mediaType == MediaType.jpeg) {
      data = encodeJpg(coverInfo.image);
    } else {
      data = encodePng(coverInfo.image);
    }

    var future = File(coverInfo.coverPath).writeAsBytes(data, flush: true);
    Fimber.d(
        "saveCover returning file in ${coverInfo.coverPath}");
    return future;
  }
}

class CoverInfo {
  final Image image;
  final String bookFilePath;
  final Link coverLink;
  final String coverPath;

  CoverInfo(this.image, this.bookFilePath, this.coverLink, this.coverPath);
}
