// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:r2_shared_dart/xml.dart';

/// A `meta` tag in an OPF document.
class OpfMeta {
  OpfMeta(this.element, this.property,
      {this.content = '', this.id, this.refines})
      : assert(property != null),
        assert(content != null);

  final OpfProperty property;
  final String content;

  /// (Nullable) Identifier for this metadata.
  final String id;

  /// (Nullable) Identifier of the metadata that is refined by this one, if any.
  final String refines;

  /// [XmlElement] for this `meta`.
  final XmlElement element;
}

/// A set of `meta` tags declared in an OPF document.
class OpfMetaList {
  OpfMetaList._(this._metas) : assert(_metas != null);

  factory OpfMetaList(XmlElement package) {
    assert(package != null);
    package.prefixes['opf'] = 'http://www.idpf.org/2007/opf';
    package.prefixes['dc'] = 'http://purl.org/dc/elements/1.1/';

    /// Custom declared prefix vocabularies, in opf:package[@prefix].
    var vocabularies = OpfVocabulary.fromPrefixes(package['prefix'] ?? '');

    // Parses `<meta>` and `<dc:x>` tags in order of appearance.
    var metas =
        package.xpath("opf:metadata/opf:meta|opf:metadata/dc:*").map((element) {
      // <opf:meta>
      if (element.name == 'meta') {
        // EPUB 3
        if (element['property'] != null) {
          String refinedID = element['refines'];
          if (refinedID != null) {
            // Get rid of the # before the ID.
            refinedID = refinedID.substring(1);
          }
          return OpfMeta(element,
              OpfProperty.fromPrefixed(element['property'], vocabularies),
              content: element.text.trim(),
              id: element['id'],
              refines: refinedID);

          // EPUB 2
        } else if (element['name'] != null) {
          return OpfMeta(
              element, OpfProperty.fromPrefixed(element['name'], vocabularies),
              content: element['content']?.trim() ?? '');
        } else {
          return null;
        }

        // <dc:*>
      } else {
        return OpfMeta(element, OpfProperty(element.name, OpfVocabulary.dc),
            content: element.text.trim(), id: element['id']);
      }
    }).toList();

    return OpfMetaList._(metas);
  }

  final List<OpfMeta> _metas;

  /// Finds the first meta with the given property and vocabulary, or `null`.
  /// If a [id] is provided, only returns the meta with the given ID.
  /// If a [refining] ID is provided, only returns the meta that are refining
  /// the meta with the given ID.
  OpfMeta first(String property,
      {OpfVocabulary vocabulary, String id, String refining}) {
    vocabulary = vocabulary ?? OpfVocabulary.defaultMetadata;
    return _metas.firstWhere(
        (meta) =>
            meta.property.name == property &&
            meta.property.vocabulary.uri == vocabulary.uri &&
            (id == null || meta.id == id) &&
            (refining == null || meta.refines == refining),
        orElse: () => null);
  }

  /// Finds all the metas with the given property and vocabulary.
  /// If a [id] is provided, only returns the metas with the given ID.
  /// If a [refining] ID is provided, only returns the metas that are refining
  /// the meta with the given ID.
  List<OpfMeta> get(String property,
      {OpfVocabulary vocabulary, String id, String refining}) {
    vocabulary = vocabulary ?? OpfVocabulary.defaultMetadata;
    return _metas
        .where((meta) =>
            meta.property.name == property &&
            meta.property.vocabulary.uri == vocabulary.uri &&
            (id == null || meta.id == id) &&
            (refining == null || meta.refines == refining))
        .toList();
  }
}

/// A meta property name and its vocabulary.
class OpfProperty {
  OpfProperty(this.name, this.vocabulary)
      : assert(name != null),
        assert(vocabulary != null);

  /// Creates from an optionally prefixed property (eg. rendition:spread).
  /// Custom prefixes declared in the package can be provided with [vocabularies].
  factory OpfProperty.fromPrefixed(String property,
      [List<OpfVocabulary> vocabularies]) {
    var regex = RegExp(r'^(?:\s*(\S+?):)?\s*(.+?)\s*$');
    var match = regex.firstMatch(property.trim());
    if (match == null) {
      return OpfProperty(property, OpfVocabulary.defaultMetadata);
    }

    var prefix = match.group(1);
    var name = match.group(2);
    var vocabulary = (vocabularies + OpfVocabulary.all)
            .firstWhere((v) => v.prefix == prefix, orElse: () => null) ??
        OpfVocabulary.defaultMetadata;

    return OpfProperty(name, vocabulary);
  }

  /// Property name without any prefix (eg. spread).
  final String name;

  /// Vocabulary identifying the property (eg. [OpfVocabulary.rendition]).
  final OpfVocabulary vocabulary;
}

/// Package vocabularies used for `property`, `properties`, `scheme` and `rel`.
/// http://www.idpf.org/epub/301/spec/epub-publications.html#sec-metadata-assoc
class OpfVocabulary {
  static const all = [
    defaultMetadata,
    defaultLinkRel,
    a11y,
    dcterms,
    epubsc,
    marc,
    media,
    onix,
    rendition,
    schema,
    xsd,
    dc,
    calibre
  ];

  /// Fallback vocabulary for metadata's properties.
  static const defaultMetadata =
      OpfVocabulary(null, 'http://idpf.org/epub/vocab/package/#');

  /// Fallback vocabulary for links' rels.
  static const defaultLinkRel =
      OpfVocabulary(null, 'http://idpf.org/epub/vocab/package/link/#');

  /// Reserved prefixes (https://idpf.github.io/epub-prefixes/packages/).
  static const a11y =
      OpfVocabulary('a11y', 'http://www.idpf.org/epub/vocab/package/a11y/#');
  static const dcterms = OpfVocabulary('dcterms', 'http://purl.org/dc/terms/');
  static const epubsc =
      OpfVocabulary('epubsc', 'http://idpf.org/epub/vocab/sc/#');
  static const marc = OpfVocabulary('marc', 'http://id.loc.gov/vocabulary/');
  static const media =
      OpfVocabulary('media', 'http://www.idpf.org/epub/vocab/overlays/#');
  static const onix = OpfVocabulary(
      'onix', 'http://www.editeur.org/ONIX/book/codelists/current.html#');
  static const rendition =
      OpfVocabulary('rendition', 'http://www.idpf.org/vocab/rendition/#');
  static const schema = OpfVocabulary('schema', 'http://schema.org/');
  static const xsd = OpfVocabulary('xsd', 'http://www.w3.org/2001/XMLSchema#');

  // Additional prefixes used in the parser.
  static const dc = OpfVocabulary('dc', 'http://purl.org/dc/elements/1.1/');
  static const calibre = OpfVocabulary('calibre', 'https://calibre-ebook.com');

  const OpfVocabulary(this.prefix, this.uri) : assert(uri != null);

  final String prefix;
  final String uri;

  /// Parses the custom vocabulary prefixes declared in the given
  /// whitespace-separated list (found in opf:package[@prefix]).
  /// "Reserved prefixes should not be overridden in the prefix attribute, but
  /// Reading Systems must use such local overrides when encountered."
  /// (http://www.idpf.org/epub/301/spec/epub-publications.html#sec-metadata-reserved-vocabs)
  static List<OpfVocabulary> fromPrefixes(String prefixes) =>
      RegExp(r'(\S+?):\s*(\S+)')
          .allMatches(prefixes)
          .map((match) => OpfVocabulary(match.group(1), match.group(2)))
          .toList();
}
