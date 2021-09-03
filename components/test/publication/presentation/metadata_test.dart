// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared_dart/epub.dart';
import 'package:mno_shared_dart/publication.dart';
import 'package:test/test.dart';

void main() {
  test("get Metadata {presentation} when available", () {
    expect(
        Presentation(
            continuous: false, orientation: PresentationOrientation.landscape),
        Metadata(
            localizedTitle: LocalizedString.fromString("Title"),
            otherMetadata: {
              "presentation": {"continuous": false, "orientation": "landscape"}
            }).presentation);
  });

  test("get Metadata {presentation} when missing", () {
    expect(
        Presentation(),
        Metadata(localizedTitle: LocalizedString.fromString("Title"))
            .presentation);
  });
}
