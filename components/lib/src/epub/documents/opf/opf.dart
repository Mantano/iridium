// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:collection/collection.dart";
import 'package:fimber/fimber.dart';
import 'package:mno_shared_dart/container.dart';
import 'package:mno_shared_dart/publication.dart';
import 'package:mno_shared_dart/streams.dart';
import 'package:mno_shared_dart/xml.dart';
import 'package:path/path.dart' as p;

import '../encryption.dart';
import '../ocf.dart';
import 'display_options.dart';
import 'links.dart';
import 'meta.dart';

/// EPUB Open Packaging Format Document.
/// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md
class OpfDocument {
  /// Parses the first [OpfDocument] found in the given EPUB [Container].
  static Future<OpfDocument> parse(Container container) async {
    assert(container != null);

    var opfPath = (await OcfDocument.parse(container))?.opfPath;
    if (opfPath == null) {
      return null;
    }
    Map<String, Encryption> encryptionData =
        await EncryptionParser.parse(container);

    try {
      DisplayOptionsDocument displayOptions =
          await DisplayOptionsDocument.parse(container);
      DataStream stream = await container.streamAt(opfPath);
      return OpfDocument(await stream.readXml(), p.dirname(opfPath),
          displayOptions, encryptionData);
    } on Exception catch (e) {
      Fimber.d("Can't parse the OPF document at: $opfPath", ex: e);
      return null;
    }
  }

  OpfDocument(this._document, this.basePath, this._displayOptions,
      Map<String, Encryption> encryptionData)
      : assert(_document != null),
        assert(basePath != null) {
    _document.prefixes.addAll({
      'opf': 'http://www.idpf.org/2007/opf',
      'dc': 'http://purl.org/dc/elements/1.1/',
      'dcterms': 'http://purl.org/dc/terms/',
      'rendition': 'http://www.idpf.org/2013/rendition'
    });
    _package = _document.firstXPath('opf:package');
    assert(_package != null); // FIXME: exception
    _metadata = _package.firstXPath('opf:metadata');
    assert(_metadata != null); // FIXME: exception
    _metas = OpfMetaList(_package);
    links = OpfLinkList(_package, _metas, basePath, encryptionData);
  }

  /// OPF XML document.
  final XmlDocument _document;

  /// Path to the directory containing the OPF file, relative to its [Container].
  final String basePath;

  /// `opf:package` Element.
  XmlElement _package;

  /// `opf:metadata` Element.
  XmlElement _metadata;

  /// List of [OpfMeta] declared in the package.
  OpfMetaList _metas;

  /// Display options document to use as a fallback for metadata properties.
  final DisplayOptionsDocument _displayOptions;

  /// Links declared in the reading order and manifest.
  OpfLinkList links;

  /// (Nullable) Unique identifier of the package.
  /// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#identifier
  String get identifier {
    var id = _package['unique-identifier'];
    if (id == null) {
      return null;
    }
    return _metadata
        .xpath('dc:identifier')
        .firstWhere((e) => e['id'] == id, orElse: () => null)
        ?.text
        ?.trim();
  }

  /// Retrieves the EPUB version.
  /// The default version is "1.2", used when no version has been specified (see OPF_2.0.1_draft 1.3.2).
  String get version =>
      _document.firstXPath('opf:package')?.getAttribute('version') ?? '1.2';

  /// (Nullable) Languages declared in the metadata.
  List<String> get languages => _metas
      .get('language', vocabulary: OpfVocabulary.dc)
      .map((meta) => meta.content)
      .toList();

  /// (Nullable) Main title of the package.
  LocalizedString get title => _localizedStringFrom(_mainTitleElement);

  /// (Nullable) Subtitle of the package.
  LocalizedString get subtitle =>
      _localizedStringFrom(_titleElementWithType('subtitle'));

  /// (Nullable) String to be used to sort the package in a library.
  /// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#title
  LocalizedString get sortAs {
    String sortAs;
    var titleID = _mainTitleElement?.getAttribute('id');
    if (titleID != null) {
      sortAs = _metas.first('file-as', refining: titleID)?.content;
    }
    // Fallbacks on Calibre's metadata for EPUB 2.
    String sort = sortAs ??
        _metas.first('title_sort', vocabulary: OpfVocabulary.calibre)?.content;
    return LocalizedString.fromString(sort);
  }

  /// (Nullable) Finds the [XmlElement] for the main title of the package.
  XmlElement get _mainTitleElement =>
      _titleElementWithType('main') ??
      _metas.first('title', vocabulary: OpfVocabulary.dc)?.element;

  /// (Nullable) Finds the first `<dc:title> elements matching the given `title-type`.
  /// http://www.idpf.org/epub/30/spec/epub30-publications.html#title-type
  XmlElement _titleElementWithType(String titleType) {
    // `<meta refines="#.." property="title-type" id="title-type">titleType</meta>`
    var elements = _metas
        .get('title-type')
        .map((meta) {
          if (meta.content != titleType || meta.refines == null) {
            return null;
          }
          return _metas
              .first('title', vocabulary: OpfVocabulary.dc, id: meta.refines)
              ?.element;
        })
        .where((e) => e != null)
        .toList();

    // Sort the elements by the `display-seq` refines, when available.
    elements.sort((title1, title2) {
      String order1 =
          _metas.first('display-seq', refining: title1['id'])?.content ?? '';
      String order2 =
          _metas.first('display-seq', refining: title2['id'])?.content ?? '';
      return compareAsciiUpperCase(order1, order2);
    });

    return elements.isNotEmpty ? elements.first : null;
  }

  /// Date of publication.
  /// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#publication-date
  DateTime get published {
    var published = _metadata
        .xpath('dc:date')
        .firstWhere((element) {
          var event = element.getAttribute('event', namespace: 'opf');
          return event == null || event == 'publication';
        }, orElse: () => null)
        ?.text
        ?.trim();
    try {
      return published != null ? DateTime.parse(published) : null;
    } on Exception {
      Fimber.d("Invalid date format: $published");
      return null;
    }
  }

  /// Date of last modification.
  /// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#modification-date
  DateTime get modified {
    String modified =
        _metas.first('modified', vocabulary: OpfVocabulary.dcterms)?.content;
    modified ??= _metadata
        .xpath('dc:date')
        .firstWhere(
            (e) => e.getAttribute('event', namespace: 'opf') == 'modification',
            orElse: () => null)
        ?.text
        ?.trim();
    try {
      return modified != null ? DateTime.parse(modified) : null;
    } on Exception {
      Fimber.d("Invalid date format: $published");
      return null;
    }
  }

  /// Short description of the publication.
  String get description =>
      _metas.first('description', vocabulary: OpfVocabulary.dc)?.content;

  /// Subjects of this publication, parsed from `<dc:subject>`.
  /// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#subjects
  List<Subject> get subjects {
    Subject createSubject(LocalizedString name, XmlElement element) {
      if (name == null) {
        return null;
      }
      return Subject(
          localizedName: name,
          scheme: element.getAttribute('authority', namespace: 'opf'),
          code: element.getAttribute('term', namespace: 'opf'));
    }

    var metas = _metas.get('subject', vocabulary: OpfVocabulary.dc);
    if (metas.length == 1) {
      var meta = metas.first;
      var names = meta.content.split(RegExp(r'[;,]'));
      if (names.length > 1) {
        // No translations if the subjects are a list separated by , or ;
        return names
            .map((n) => LocalizedString.fromString(n.trim()))
            .map((n) => createSubject(n, meta.element))
            .where((s) => s != null)
            .toList();
      }
    }

    return metas
        .map((meta) {
          var name = _localizedStringFrom(meta.element);
          return createSubject(name, meta.element);
        })
        .where((s) => s != null)
        .toList();
  }

  /// Collections of which the publication belongs to.
  /// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#collections-and-series
  List<Collection> get collections => _metas
      .get('belongs-to-collection')
      .map((meta) {
        // `collection-type` should not be "series"
        if (meta.id != null &&
            _metas.first('collection-type', refining: meta.id)?.content ==
                'series') {
          return null;
        }
        return _collectionFrom(meta);
      })
      .where((m) => m != null)
      .toList();

  /// Series of which the publication is part of.
  /// https://github.com/readium/architecture/blob/master/streamer/parser/metadata.md#collections-and-series
  List<Collection> get series {
    var epub3Series = _metas
        .get('belongs-to-collection')
        .where((meta) =>
            // `collection-type` should be "series".
            meta.id != null &&
            _metas.first('collection-type', refining: meta.id)?.content ==
                'series')
        .map(_collectionFrom)
        .toList();

    double epub2Position;
    var epub2PositionString = _metas
        .first('series_index', vocabulary: OpfVocabulary.calibre)
        ?.content;
    if (epub2PositionString != null) {
      epub2Position = double.parse(epub2PositionString);
    }

    var epub2Series = _metas
        .get('series', vocabulary: OpfVocabulary.calibre)
        .map((meta) => Collection(
            localizedName: LocalizedString.fromString(meta.content),
            position: epub2Position))
        .toList();

    return (epub3Series + epub2Series).where((s) => s != null).toList();
  }

  /// Creates a `Collection` from an `OpfMeta`, or `null`.
  Collection _collectionFrom(OpfMeta meta) {
    assert(meta != null);
    LocalizedString name = _localizedStringFrom(meta.element);
    if (name == null) {
      return null;
    }

    String identifier;
    LocalizedString sortAs;
    double position;
    if (meta.id != null) {
      identifier = _metas
          .first('identifier',
              vocabulary: OpfVocabulary.dcterms, refining: meta.id)
          ?.content;
      sortAs = LocalizedString.fromString(
          _metas.first('file-as', refining: meta.id)?.content);
      var positionString =
          _metas.first('group-position', refining: meta.id)?.content;
      if (positionString != null) {
        position = double.parse(positionString);
      }
    }

    return Collection(
        localizedName: name,
        identifier: identifier,
        localizedSortAs: sortAs,
        position: position);
  }

  /// Contributors (authors, publishers, etc.) declared in the package.
  List<Contributor> get authors {
    _parseContributors();
    return _authors;
  }

  List<Contributor> _authors;
  List<Contributor> get contributors {
    _parseContributors();
    return _contributors;
  }

  List<Contributor> _contributors;
  List<Contributor> get publishers {
    _parseContributors();
    return _publishers;
  }

  List<Contributor> _publishers;

  /// Parses all the [Contributor] from the <dc:creator>, <dc:contributor>
  /// or <dc:publisher> elements, or <meta> elements with property == "dcterms:
  /// creator", "dcterms:publisher", "dcterms:contributor".
  /// Then, add them to the correct list ([authors], [contributors] or
  /// [publishers]) depending on their roles or tag name.
  void _parseContributors() {
    if (_authors != null) {
      return; // Already parsed.
    }
    _authors = [];
    _contributors = [];
    _publishers = [];

    var metas = (

        /// EPUB 3.0 contributors, e.g. `<meta property="dcterms:publisher/creator/contributor"`.
        _metas.get('creator', vocabulary: OpfVocabulary.dcterms) +
            _metas.get('publisher', vocabulary: OpfVocabulary.dcterms) +
            _metas.get('contributor', vocabulary: OpfVocabulary.dcterms) +

            /// EPUB 2.0 & 3.1+ contributors, eg. `<dc:publisher "property"=".." >value`.
            _metas.get('creator', vocabulary: OpfVocabulary.dc) +
            _metas.get('publisher', vocabulary: OpfVocabulary.dc) +
            _metas.get('contributor', vocabulary: OpfVocabulary.dc));

    // Adds the [Contributor] to the proper property according to its [roles].
    for (var meta in metas) {
      var element = meta.element;
      var contributor = _contributorFrom(element);
      if (contributor == null) {
        continue;
      }

      if (contributor.roles.isNotEmpty) {
        for (var role in contributor.roles) {
          switch (role) {
            case 'aut':
              _authors.add(contributor);
              break;
            case 'pbl':
              _publishers.add(contributor);
              break;
            default:
              _contributors.add(contributor);
              break;
          }
        }

        // No role, so do the branching using the [element.name].
        // The remaining ones go to to the contributors.
      } else {
        if (element.name == 'creator' ||
            element['property'] == 'dcterms:creator') {
          _authors.add(contributor);
        } else if (element.name == 'publisher' ||
            element['property'] == 'dcterms:publisher') {
          _publishers.add(contributor);
        } else {
          _contributors.add(contributor);
        }
      }
    }
  }

  /// Creates a [Contributor] instance from a <dc:creator>, <dc:contributor>
  /// or <dc:publisher> [element], or <meta> element with property == "dcterms:
  /// creator", "dcterms:publisher", "dcterms:contributor".
  Contributor _contributorFrom(XmlElement element) {
    assert(element != null);

    var name = _localizedStringFrom(element);
    if (name == null) {
      return null;
    }

    var role = element.getAttribute('role', namespace: 'opf');
    Set<String> roles = {if (role != null) role};
    // Looks up for possible meta refines for contributor's role.
    if (element['id'] != null) {
      roles.addAll(_metas
          .get('role', refining: element['id'])
          .map((meta) => meta.content));
    }

    return Contributor(
        localizedName: name,
        localizedSortAs: LocalizedString.fromString(
            element.getAttribute('file-as', namespace: 'opf')),
        roles: roles);
  }

  /// Direction of the reading progression declared in the `opf:readingOrder` or
  /// `opf:spine`.
  ReadingProgression get readingProgression {
    var direction = _package
        .firstXPath('opf:readingOrder|opf:spine')
        ?.getAttribute('page-progression-direction');
    switch (direction) {
      case 'rtl':
        return ReadingProgression.rtl;
      case 'ltr':
        return ReadingProgression.ltr;
      default:
        return ReadingProgression.auto;
    }
  }

  /// EPUB rendition properties.
  Presentation get rendition => Presentation(
      layout: _renditionLayout,
      orientation: _renditionOrientation,
      overflow: _renditionOverflow,
      spread: _renditionSpread);

  // Convenience to get a rendition property's value, or an empty string.
  String _renditionProperty(String name) =>
      _metas.first(name, vocabulary: OpfVocabulary.rendition)?.content ?? '';

  /// Creates a [RenditionLayout] from an EPUB rendition:layout property.
  EpubLayout get _renditionLayout {
    switch (_renditionProperty('layout')) {
      case 'reflowable':
        return EpubLayout.reflowable;
      case 'pre-paginated':
        return EpubLayout.fixed;
      default:
        return (_displayOptions?.get('fixed-layout') == 'true')
            ? EpubLayout.fixed
            : EpubLayout.reflowable;
    }
  }

  /// Creates a [RenditionOrientation] from an EPUB rendition:orientation property.
  PresentationOrientation get _renditionOrientation {
    switch (_renditionProperty('orientation')) {
      case 'landscape':
        return PresentationOrientation.landscape;
      case 'portrait':
        return PresentationOrientation.portrait;
      case 'auto':
        return PresentationOrientation.auto;
      default:
        switch (_displayOptions?.get('orientation-lock')) {
          case 'none':
            return PresentationOrientation.auto;
          case 'landscape-only':
            return PresentationOrientation.landscape;
          case 'portrait-only':
            return PresentationOrientation.portrait;
          default:
            return PresentationOrientation.auto;
        }
    }
  }

  /// Creates a [RenditionOverflow] from an EPUB rendition:flow property.
  PresentationOverflow get _renditionOverflow {
    switch (_renditionProperty('flow')) {
      case 'auto':
        return PresentationOverflow.auto;
      case 'paginated':
        return PresentationOverflow.paginated;
      case 'scrolled-continuous':
      case 'scrolled-doc':
        return PresentationOverflow.scrolled;
      default:
        return PresentationOverflow.auto;
    }
  }

  /// Creates a [RenditionSpread] from an EPUB rendition:spread property.
  PresentationSpread get _renditionSpread {
    switch (_renditionProperty('spread')) {
      case 'none':
        return PresentationSpread.none;
      case 'auto':
        return PresentationSpread.auto;
      case 'landscape':
        return PresentationSpread.landscape;
      // `portrait` is deprecated and should fallback to `both`.
      // See. https://readium.org/architecture/streamer/parser/metadata#epub-3x-11
      case 'both':
      case 'portrait':
        return PresentationSpread.both;
      default:
        return PresentationSpread.auto;
    }
  }

  /// Determines the BCP-47 language tag for the given [XmlElement], using:
  ///   1. its `xml:lang` attribute
  ///   2. `opf:package[xml:lang]`
  ///   3. the primary language for the publication
  String _languageOf(XmlElement element) =>
      element['xml:lang'] ??
      _package['xml:lang'] ??
      (languages.isEmpty ? null : languages.first);

  /// Returns the [LocalizedString] representation of an [XmlElement].
  ///
  /// Used for opf:title and opf:contributor.
  /// The translations are defined in the [OpfMeta] with the property
  /// `alternate-script` refining the [XmlElement].
  LocalizedString _localizedStringFrom(XmlElement element) {
    if (element == null) {
      return null;
    }

    // Default string.
    var elementID = element['id'];
    var defaultString = element.text.trim();
    var defaultLanguage = _languageOf(element);
    if (defaultLanguage == null ||
        defaultLanguage.isEmpty ||
        elementID == null) {
      return LocalizedString.fromString(defaultString);
    }

    // Finds translations.
    var strings = {defaultLanguage: defaultString};
    for (var meta in _metas.get('alternate-script', refining: elementID)) {
      var language = meta.element['xml:lang'];
      if (meta.content.isNotEmpty && language != null) {
        strings[language] = meta.content;
      }
    }

    return LocalizedString(strings);
  }
}
