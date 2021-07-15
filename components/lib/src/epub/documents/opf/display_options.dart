// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:r2_shared_dart/container.dart';
import 'package:r2_shared_dart/xml.dart';

/// iBooks Display Options XML document to use as a fallback for some metadata.
/// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#epub-2x-9
class DisplayOptionsDocument {
  /// Parses the [DisplayOptionsDocument] from a given EPUB [Container].
  static Future<DisplayOptionsDocument> parse(Container container) async {
    var iBooksPath = 'META-INF/com.apple.ibooks.display-options.xml';
    var koboPath = 'META-INF/com.kobobooks.display-options.xml';

    Future<DisplayOptionsDocument> parseAt(String path) async {
      if (!await container.existsAt(path)) {
        return null;
      }
      try {
        var stream = await container.streamAt(path);
        return DisplayOptionsDocument(await stream.readXml());
      } on Exception catch (e) {
        Fimber.d("Can't parse display options at: $path", ex: e);
        return null;
      }
    }

    return (await parseAt(iBooksPath)) ?? (await parseAt(koboPath));
  }

  DisplayOptionsDocument._(this._platform) : assert(_platform != null);

  factory DisplayOptionsDocument(XmlDocument document) {
    if (document == null) {
      return null;
    }
    var platforms = document.xpath('display_options/platform');

    XmlElement getPlatform([String name]) {
      if (name == null) {
        return platforms.isNotEmpty ? platforms.first : null;
      }
      return platforms.firstWhere((e) => e['name'] == name, orElse: () => null);
    }

    var platform = getPlatform('*') ??
        getPlatform('ipad') ??
        getPlatform('iphone') ??
        getPlatform();

    return (platform != null) ? DisplayOptionsDocument._(platform) : null;
  }

  // Display options's <platform> element to be used to retrieve properties.
  // https://readium.org/architecture/streamer/parser/metadata#epub-2x-10
  final XmlElement _platform;

  // Gets a display options's property's value.
  String get(String name) => _platform
      .xpath('option')
      ?.firstWhere((option) => option['name'] == name, orElse: () => null)
      ?.text
      ?.trim();
}
