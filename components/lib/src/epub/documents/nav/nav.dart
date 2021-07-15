// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:r2_shared_dart/container.dart';
import 'package:r2_shared_dart/publication.dart';

import '../opf/opf.dart';
import 'html.dart';
import 'ncx.dart';

/// Available navigation tables to be parsed.
enum NavType { tableOfContents, pageList, landmarks }

/// Base class to extract Nav links from a document (eg. Navigation, or NCX).
abstract class NavDocument {
  /// Reads the [NavDocument] referenced by an [OpfDocument] from the given [Container].
  static Future<NavDocument> parse(Container container, OpfDocument opf) async {
    // Parses the EPUB 3 Navigation Document.
    var htmlLink =
        opf.links.linkWhere((link) => link.rels.contains('contents'));
    if (htmlLink != null) {
      var href = htmlLink.href;
      try {
        var stream = await container.streamAt(href);
        return HtmlNavDocument(await stream.readXml(), path: href);
      } on Exception {
        Fimber.d("Can't parse HTML Navigation Document at: $href");
      }
    }

    // Fallback on the EPUB 2 NCX Document.
    var ncxLink =
        opf.links.linkWhere((link) => link.type == 'application/x-dtbncx+xml');
    if (ncxLink != null) {
      var href = ncxLink.href;
      try {
        var stream = await container.streamAt(href);
        return NcxNavDocument(await stream.readXml(), path: href);
      } on Exception {
        Fimber.d("Can't parse NCX Document at: $href");
      }
    }

    return null;
  }

  /// List of [Link] for the navigation table of given [type].
  List<Link> links(NavType type);

  /// Creates a [Link] from a [title], [href] and its [children], after
  /// validating the data. The [basePath] is the path to the nav document file
  /// which is used to resolve the [href].
  Link createLink(
      {String title,
      String href,
      @required String basePath,
      List<Link> children = const []}) {
    assert(basePath != null);
    assert(children != null);

    // Cleans up the title label.
    // http://www.idpf.org/epub/301/spec/epub-contentdocs.html#confreq-nav-a-cnt
    title = (title ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();

    // A zero-length text label must be ignored
    // http://www.idpf.org/epub/301/spec/epub-contentdocs.html#confreq-nav-a-cnt
    if (title.isEmpty) {
      return null;
    }

    // Resolves [href] relative to the [basePath].
    if (href != null) {
      if (href.startsWith('#')) {
        // Fragment inside the Navigation Document itself.
        href = basePath + href;
      } else {
        href = p.normalize(p.join(p.dirname(basePath), href));
      }
    }

    // An unlinked item (`span`) without children must be ignored
    // http://www.idpf.org/epub/301/spec/epub-contentdocs.html#confreq-nav-a-nest
    if (href == null && children.isEmpty) {
      return null;
    }

    return Link(href: href ?? '#', title: title, children: children);
  }
}
