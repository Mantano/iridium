// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dfunc/dfunc.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_shared/fetcher.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:mno_streamer/pdf.dart';

class LcpdfPositionsService extends PositionsService {
  final PdfDocumentFactory pdfFactory;
  final List<Link> readingOrder;
  final Fetcher fetcher;
  List<List<Locator>>? _positions;

  LcpdfPositionsService._(
      {required this.pdfFactory,
      required this.readingOrder,
      required this.fetcher});

  static ServiceFactory create(PdfDocumentFactory pdfFactory) =>
      (PublicationServiceContext context) => LcpdfPositionsService._(
            pdfFactory: pdfFactory,
            readingOrder: context.manifest.readingOrder,
            fetcher: context.fetcher,
          );

  @override
  Future<List<List<Locator>>> positionsByReadingOrder() async =>
      _positions ??= await computePositions();

  Future<List<List<Locator>>> computePositions() async {
    // Calculates the page count of each resource from the reading order.
    List<Product2<int, Link>> resources =
        await Future.wait(readingOrder.map((link) async {
      int pageCount = (await openPdfAt(link))?.pageCount ?? 0;
      return Product2(pageCount, link);
    }));

    int totalPageCount = resources.fold(0, (prev, it) => prev + it.item1);
    if (totalPageCount <= 0) {
      return [];
    }

    int lastPositionOfPreviousResource = 0;
    return resources.map((it) {
      int? pageCount = it.item1;
      Link link = it.item2;
      List<Locator> positions = createPositionsOf(link,
          pageCount: pageCount,
          totalPageCount: totalPageCount,
          startPosition: lastPositionOfPreviousResource);
      lastPositionOfPreviousResource += pageCount;
      return positions;
    }).toList();
  }

  List<Locator> createPositionsOf(Link link,
      {required int pageCount,
      required int totalPageCount,
      required int startPosition}) {
    if (pageCount <= 0 || totalPageCount <= 0) {
      return [];
    }
    // FIXME: Use the [tableOfContents] to generate the titles
    return [
      for (int position = 1; position <= pageCount; position++)
        _createLocator(position, pageCount, startPosition, totalPageCount, link)
    ];
  }

  Locator _createLocator(int position, int pageCount, int startPosition,
      int totalPageCount, Link link) {
    double progression = (position - 1) / pageCount.toDouble();
    double totalProgression =
        (startPosition + position - 1) / totalPageCount.toDouble();
    return Locator(
        href: link.href,
        type: link.type ?? MediaType.pdf.toString(),
        locations: Locations(
            fragments: ["page=$position"],
            progression: progression,
            totalProgression: totalProgression,
            position: startPosition + position));
  }

  Future<PdfDocument?> openPdfAt(Link link) async {
    try {
      return pdfFactory.openResource(fetcher.get(link), password: null);
    } on Exception catch (e) {
      Fimber.e("openPdfAt failed", ex: e);
      return null;
    }
  }
}
