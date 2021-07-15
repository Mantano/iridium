// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:r2_shared_dart/container.dart';
import 'package:r2_shared_dart/xml.dart';

/// EPUB Open Container Format Document (located in META-INF/container.xml).
class OcfDocument {
  /// Parses an [OcfDocument] from an EPUB [Container].
  static Future<OcfDocument> parse(Container container) async {
    try {
      var stream = await container.streamAt('META-INF/container.xml');
      return OcfDocument(await stream.readXml());
    } on Exception catch (e) {
      Fimber.d("Can't parse the OCF document", ex: e);
      return null;
    }
  }

  OcfDocument(this._document) : assert(_document != null) {
    _document.prefixes['cn'] =
        'urn:oasis:names:tc:opendocument:xmlns:container';
  }

  final XmlDocument _document;

  Iterable<String> rootfilesWithMIMEType(String mimetype) => _document
      .xpath('cn:container/cn:rootfiles/cn:rootfile')
      .where((rootfile) => rootfile['media-type'] == mimetype)
      .map((rootfile) => rootfile['full-path'])
      .where((path) => (path != null && path.isNotEmpty));

  /// Returns the path to the first declared OPF document, or `null`.
  String get opfPath {
    var paths = rootfilesWithMIMEType('application/oebps-package+xml');
    return paths.isNotEmpty ? paths.first : null;
  }
}
