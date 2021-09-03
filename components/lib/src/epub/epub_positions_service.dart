// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';
import 'package:dfunc/dfunc.dart';
import 'package:mno_shared_dart/epub.dart';
import 'package:mno_shared_dart/fetcher.dart';
import 'package:mno_shared_dart/publication.dart';

/// Positions Service for an EPUB from its [readingOrder] and [fetcher].
///
/// The [presentation] is used to apply different calculation strategy if the resource has a
/// reflowable or fixed layout.
///
/// https://github.com/readium/architecture/blob/master/models/locators/best-practices/format.md#epub
/// https://github.com/readium/architecture/issues/101
///
/// @param reflowablePositionLength Length in bytes of a position in a reflowable resource. This is
///        used to split a single reflowable resource into several positions.
class EpubPositionsService extends PositionsService {
  final List<Link> readingOrder;
  final Presentation presentation;
  final Fetcher fetcher;
  final int reflowablePositionLength;
  List<List<Locator>> _positions;

  EpubPositionsService._(
      {this.readingOrder,
      this.presentation,
      this.fetcher,
      this.reflowablePositionLength});

  static EpubPositionsService create(PublicationServiceContext context) =>
      EpubPositionsService._(
          readingOrder: context.manifest.readingOrder,
          presentation: context.manifest.metadata.presentation,
          fetcher: context.fetcher,
          reflowablePositionLength: 1024);

  @override
  Future<List<List<Locator>>> positionsByReadingOrder() async =>
      _positions ??= await computePositions();

  Future<List<List<Locator>>> computePositions() async {
    int lastPositionOfPreviousResource = 0;
    List<List<Locator>> positions =
        await Future.wait(readingOrder.map((link) async {
      List<Locator> positions;
      if (presentation.layoutOf(link) == EpubLayout.fixed) {
        positions = createFixed(link, lastPositionOfPreviousResource);
      } else {
        positions = await createReflowable(
            link, lastPositionOfPreviousResource, fetcher);
      }
      positions.lastOrNull?.locations?.position
          ?.let((it) => lastPositionOfPreviousResource = it);
      return positions;
    }));

    // Calculates [totalProgression].
    int totalPageCount = positions.map((it) => it.length).sum();
    positions = positions.map((item) => item.map((locator) {
          int position = locator.locations.position;
          if (position == null) {
            return locator;
          } else {
            return locator.copyWithLocations(
                totalProgression: (position - 1) / totalPageCount.toDouble());
          }
        }));

    return positions;
  }

  List<Locator> createFixed(Link link, int startPosition) =>
      [createLocator(link, progression: 0.0, position: startPosition + 1)];

  Future<List<Locator>> createReflowable(
      Link link, int startPosition, Fetcher fetcher) async {
    // If the resource is encrypted, we use the `originalLength` declared in `encryption.xml`
    // instead of the ZIP entry length.
    int length = link.properties.encryption?.originalLength ??
        await fetcher
            .get(link)
            .use((it) async => (await it.length()).getOrNull());
    if (length == null) {
      return [];
    }
    int pageCount =
        (length ~/ reflowablePositionLength.toDouble()).coerceAtLeast(1);
    return [
      for (int position = 1; position <= pageCount; position++)
        createLocator(link,
            progression: (position - 1) / pageCount.toDouble(),
            position: startPosition + position)
    ];
  }

  Locator createLocator(Link link, {double progression, int position}) =>
      Locator(
          href: link.href,
          type: link.type ?? "text/html",
          title: link.title,
          locations: Locations(progression: progression, position: position));
}
