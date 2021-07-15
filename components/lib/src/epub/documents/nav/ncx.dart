// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:r2_shared_dart/publication.dart';
import 'package:r2_shared_dart/xml.dart';

import 'nav.dart';

/// EPUB 2 NCX (Navigation Center eXtended) Document.
/// This was replaced by the HTML Navigation Document in EPUB 3.
/// https://w3c.github.io/publ-epub-revision/epub32/spec/epub-overview.html#sec-nav-nav-doc
///
/// From IDPF a11y-guidelines content/nav/toc.html :
/// "The NCX file is allowed for forwards compatibility purposes only. An EPUB 2
/// reading systems may open an EPUB 3 publication, but it will not be able to
/// use the new navigation document format.
/// You can ignore the NCX file if your book won't render properly as EPUB 2
/// content, or if you aren't targeting cross-compatibility."
class NcxNavDocument extends NavDocument {
  NcxNavDocument(this._document, {@required this.path})
      : assert(_document != null),
        assert(path != null) {
    _document.prefixes.addAll({'ncx': 'http://www.daisy.org/z3986/2005/ncx/'});
  }

  final XmlDocument _document;
  final String path;

  @override
  List<Link> links(NavType type) {
    var key = _keyForType(type);
    if (key == null) {
      return [];
    }

    var nodeTag = (type == NavType.pageList) ? 'pageTarget' : 'navPoint';
    var nav = _document.firstXPath('/ncx:ncx/ncx:$key');
    if (nav == null) {
      return [];
    }

    return _linksIn(nav, nodeTag);
  }

  /// Parses recursively a list of nodes with the tag [nodeTag] as [Link]s.
  List<Link> _linksIn(XmlElement element, String nodeTag) => element
      .xpath('ncx:$nodeTag')
      .map((node) => _linkFrom(node, nodeTag))
      .where((l) => l != null)
      .toList();

  /// Parses recursively a node with tag [nodeTag] as a [Link].
  Link _linkFrom(XmlElement element, String nodeTag) => createLink(
      title: element.firstXPath('ncx:navLabel/ncx:text')?.text,
      href: element.firstXPath('ncx:content')?.getAttribute('src'),
      basePath: path,
      children: _linksIn(element, nodeTag));

  String _keyForType(NavType type) {
    switch (type) {
      case NavType.tableOfContents:
        return 'navMap';
      case NavType.pageList:
        return 'pageList';
      case NavType.landmarks:
      default:
        return null;
    }
  }
}
