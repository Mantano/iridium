// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:mno_shared_dart/publication.dart';
import 'package:mno_shared_dart/xml.dart';

import 'nav.dart';

/// EPUB Navigation Document.
/// http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def
/// https://idpf.github.io/a11y-guidelines/
class HtmlNavDocument extends NavDocument {
  HtmlNavDocument(XmlDocument document, {@required this.path})
      : assert(document != null),
        assert(path != null) {
    document.prefixes.addAll({
      'html': 'http://www.w3.org/1999/xhtml',
      'epub': 'http://www.idpf.org/2007/ops'
    });
    _navs = document.xpath('//html:nav');
  }

  List<XmlElement> _navs;
  final String path;

  @override
  List<Link> links(NavType type) {
    var key = _keyForType(type);
    var nav = _navs.firstWhere(
        (nav) => nav.getAttribute('type', namespace: 'epub') == key,
        orElse: () => null);
    if (nav == null) {
      return [];
    }
    return _linksIn(nav);
  }

  /// Parses recursively the first <ol> child found into a list of [Link].
  List<Link> _linksIn(XmlElement element) {
    var ol = element.firstXPath('html:ol');
    if (ol == null) {
      return [];
    }
    return ol.xpath('html:li').map(_linkFrom).where((l) => l != null).toList();
  }

  /// Parses recursively a <li> element and its children to build a [Link].
  Link _linkFrom(XmlElement li) {
    var label = li.firstXPath('html:a|html:span');
    if (label == null) {
      return null;
    }
    return createLink(
        title: label.text,
        href: label['href'],
        basePath: path,
        children: _linksIn(li));
  }

  /// http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def-types
  String _keyForType(NavType type) {
    switch (type) {
      case NavType.tableOfContents:
        return 'toc';
      case NavType.pageList:
        return 'page-list';
      case NavType.landmarks:
      default:
        return 'landmarks';
    }
  }
}
