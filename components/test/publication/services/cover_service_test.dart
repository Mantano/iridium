// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:dfunc/dfunc.dart';
import 'package:diff_image/diff_image.dart';
import 'package:image/image.dart';
import 'package:mno_shared_dart/fetcher.dart';
import 'package:mno_shared_dart/publication.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

class MockCoverService extends CoverService {
  @override
  Future<Image> cover() => null;
}

void main() async {
  File cover = File("test_resources/publication/services/cover.jpg");
  assert(cover != null);
  Uint8List coverBytes = (await cover.readAsBytes());
  Image coverBitmap = readJpg(coverBytes);
  String coverPath = cover.path;

  Publication publication = Publication(
      manifest: Manifest(
          metadata:
              Metadata(localizedTitle: LocalizedString.fromString("title")),
          resources: [
            Link(href: coverPath, rels: {"cover"})
          ]),
      fetcher: FileFetcher.single(href: coverPath, file: cover));

  test("get works fine", () async {
    var service = InMemoryCoverService(coverBitmap);
    var res = service.get(Link(href: "/~readium/cover", rels: {"cover"}));
    expect(res, isNotNull);
    expect(
        Link(
            href: "/~readium/cover",
            type: "image/png",
            width: 598,
            height: 800,
            rels: {"cover"}),
        await res.link());

    var bytes = (await res.read()).getOrNull();
    expect(bytes, isNotNull);

    var diffImgResult = DiffImage.compareFromMemory(
        decodeImage(bytes.buffer.asUint8List()), coverBitmap);
    expect(diffImgResult.diffValue, 0.0);
  });

  test("helper for ServicesBuilder works fine", () {
    factory(PublicationServiceContext context) => MockCoverService();
    expect(
        factory,
        ServicesBuilder.create()
            .also((it) => it.coverServiceFactory = factory)
            .coverServiceFactory);
  });

  test("cover helper for Publication works fine", () async {
    var diffImgResult =
        DiffImage.compareFromMemory(coverBitmap, await publication.cover());
    expect(diffImgResult.diffValue, 0.0);
  });

  test("coverFitting helper for Publication works fine", () async {
    var scaled = await publication.coverFitting(CoverSize(300, 400));
    expect(scaled, isNotNull);
    expect(400, scaled.height);
    expect(300, scaled.width);
  });
}
