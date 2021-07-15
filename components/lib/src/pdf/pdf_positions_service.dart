// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:r2_shared_dart/mediatype.dart';
import 'package:r2_shared_dart/publication.dart';

/// Creates the [positions] for a PDF [Publication].
///
/// @param link The [Link] to the PDF document in the [Publication].
/// @param pageCount Total page count in the PDF document.
/// @param tableOfContents Table of contents used to compute the position titles.
class PdfPositionsService extends PositionsService {
  final Link link;
  final int pageCount;
  List<List<Locator>> _positions;

  PdfPositionsService._({this.link, this.pageCount});

  static PdfPositionsService create(PublicationServiceContext context) {
    Link link = context.manifest.readingOrder.firstOrNull;
    if (link == null) {
      return null;
    }
    return PdfPositionsService._(
      link: link,
      pageCount: context.manifest.metadata.numberOfPages ?? 0,
    );
  }

  @override
  Future<List<List<Locator>>> positionsByReadingOrder() async =>
      _positions ??= _computePositions();

  List<List<Locator>> _computePositions() {
    if (pageCount <= 0) {
      Fimber.e("Invalid page count for a PDF document: $pageCount");
      return [];
    }

    return [
      IntRange(1, pageCount).map((position) {
        double progression = (position - 1) / pageCount.toDouble();
        return Locator(
            href: link.href,
            type: link.type ?? MediaType.pdf.toString(),
            locations: Locations(
                fragments: ["page=$position"],
                progression: progression,
                totalProgression: progression,
                position: position));
      }).toList()
    ];
  }
}
