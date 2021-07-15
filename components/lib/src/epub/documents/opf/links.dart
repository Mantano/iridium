// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as p;
import 'package:r2_shared_dart/publication.dart';
import 'package:r2_shared_dart/xml.dart';

import 'meta.dart';

/// A set of [Link] declared in the reading order and manifest of the OPF document.
class OpfLinkList {
  OpfLinkList(this._package, this._metas, this._basePath, this.encryptionData)
      : assert(_package != null),
        assert(_metas != null),
        assert(encryptionData != null);

  final XmlElement _package;
  final OpfMetaList _metas;

  /// Base path from which the [Link.href] are relative to. Used to resolve the
  /// absolute [href] relative to the [Container].
  final String _basePath;
  final Map<String, Encryption> encryptionData;

  /// Links to the linear resources to be read in order.
  List<Link> get readingOrder {
    _parseLinks();
    return _readingOrder;
  }

  List<Link> _readingOrder;

  /// Links to the other resources used to render the publication.
  List<Link> get resources {
    _parseLinks();
    return _resources;
  }

  List<Link> _resources;

  /// Parses the [readingOrder] and [resources] [Link]s from the manifest and
  /// spine items.
  void _parseLinks() {
    if (_readingOrder != null) {
      return;
    }
    _readingOrder = [];
    _resources = [];

    // Get the link ID for the cover, if there's any.
    var coverID = _metas.first('cover')?.content;

    var manifestItems = _package.xpath('opf:manifest/opf:item');
    var readingOrderItems =
        _package.xpath('opf:readingOrder/opf:itemref|opf:spine/opf:itemref');

    // Parses [readingOrder].
    for (XmlElement item in readingOrderItems) {
      // Only linear items are added to the readingOrder.
      if (item['linear'] == 'no') {
        continue;
      }

      var id = item['idref'];
      // Finds the matching manifest item.
      var manifestItemIndex =
          manifestItems.indexWhere((item) => item['id'] == id);
      if (id == null || manifestItemIndex == -1) {
        continue;
      }
      var manifestItem = manifestItems[manifestItemIndex];
      manifestItems.removeAt(manifestItemIndex);

      String properties =
          '${(manifestItem['properties'] ?? '')} ${(item['properties'] ?? '')}';
      if (id == coverID) {
        properties += ' cover-image';
      }

      var link = _linkFrom(manifestItem, properties);
      if (link != null) {
        _readingOrder.add(link);
      }
    }

    // Parses the remaining manifest items into [resources].
    for (XmlElement item in manifestItems) {
      if (item['id'] == null) {
        continue;
      }

      String properties = item['properties'] ?? '';
      if (coverID != null && item['id'] == coverID) {
        properties += ' cover-image';
      }
      var link = _linkFrom(item, properties);
      if (link != null) {
        _resources.add(link);
      }
    }
  }

  /// Creates a [Link] from a string of whitespace-separated properties and a [manifestItem] [XmlElement].
  Link _linkFrom(XmlElement manifestItem, String propertiesString) {
    assert(manifestItem != null);
    assert(propertiesString != null);

    var href = manifestItem['href'];
    if (href == null) {
      return null;
    }
    href = p.normalize(p.join(_basePath, href));

    List<String> properties = propertiesString.trim().split(RegExp(r'\s+'));

    Set<String> rels = {};
    if (properties.contains('nav')) {
      rels.add('contents');
    }
    if (properties.contains('cover-image')) {
      rels.add('cover');
    }
    Encryption encryption = encryptionData[manifestItem['href']];
    return Link(
        id: manifestItem['id'],
        href: href,
        type: manifestItem['media-type'],
        rels: rels,
        properties: _linkPropertiesFrom(properties, encryption));
  }

  /// Creates a [Properties] from a list of raw EPUB link properties.
  Properties _linkPropertiesFrom(
      List<String> properties, Encryption encryption) {
    PresentationPage page;
    List<String> contains = [];
    PresentationOrientation orientation;
    EpubLayout layout;
    PresentationOverflow overflow;
    PresentationSpread spread;

    for (var property in properties) {
      switch (property) {

        /// Contains
        case 'scripted':
          contains.add('js');
          break;
        case 'mathml':
          contains.add('mathml');
          break;
        case 'onix-record':
          contains.add('onix');
          break;
        case 'svg':
          contains.add('svg');
          break;
        case 'xmp-record':
          contains.add('xmp');
          break;
        case 'remote-resources':
          contains.add('remote-resources');
          break;

        /// Page
        case 'page-spread-left':
          page = PresentationPage.left;
          break;
        case 'page-spread-right':
          page = PresentationPage.right;
          break;
        case 'page-spread-center':
        case 'rendition:page-spread-center':
          page = PresentationPage.center;
          break;

        /// Spread
        case 'rendition:spread-none':
        case 'rendition:spread-auto':
          spread = PresentationSpread.none;
          break;
        case 'rendition:spread-landscape':
          spread = PresentationSpread.landscape;
          break;
        case 'rendition:spread-portrait':
          // `portrait` is deprecated and should fallback to `both`.
          // See. https://readium.org/architecture/streamer/parser/metadata#epub-3x-11
          spread = PresentationSpread.both;
          break;
        case 'rendition:spread-both':
          spread = PresentationSpread.both;
          break;

        /// Layout
        case 'rendition:layout-reflowable':
          layout = EpubLayout.reflowable;
          break;
        case 'rendition:layout-pre-paginated':
          layout = EpubLayout.fixed;
          break;

        /// Orientation
        case 'rendition:orientation-auto':
          orientation = PresentationOrientation.auto;
          break;
        case 'rendition:orientation-landscape':
          orientation = PresentationOrientation.landscape;
          break;
        case 'rendition:orientation-portrait':
          orientation = PresentationOrientation.portrait;
          break;

        /// Rendition
        case 'rendition:flow-auto':
          overflow = PresentationOverflow.auto;
          break;
        case 'rendition:flow-paginated':
          overflow = PresentationOverflow.paginated;
          break;
        case 'rendition:flow-scrolled-continuous':
        case 'rendition:flow-scrolled-doc':
          overflow = PresentationOverflow.scrolled;
          break;
        default:
          break;
      }
    }

    return Properties(
        page: page,
        contains: contains,
        orientation: orientation,
        layout: layout,
        overflow: overflow,
        spread: spread,
        encryption: encryption);
  }

  /// Finds the first [Link] matching the given [test] condition.
  Link linkWhere(bool Function(Link link) test) =>
      resources.firstWhere(test, orElse: () => null) ??
      readingOrder.firstWhere(test, orElse: () => null);
}
