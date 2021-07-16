// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons_dart/extensions/strings.dart';
import 'package:mno_commons_dart/utils/jsonable.dart';
import 'package:mno_shared_dart/publication.dart';

import 'localized_string.dart';
import 'reading_progression.dart';

/// https://readium.org/webpub-manifest/schema/metadata.schema.json
///
/// @param readingProgression WARNING: This contains the reading progression as declared in the
///     publication, so it might be [AUTO]. To lay out the content, use [effectiveReadingProgression]
///     to get the calculated reading progression from the declared direction and the language.
/// @param otherMetadata Additional metadata for extensions, as a JSON dictionary.
class Metadata with EquatableMixin, JSONable {
  Metadata(
      {this.identifier,
      this.type,
      this.localizedTitle,
      this.localizedSubtitle,
      this.modified,
      this.published,
      this.languages = const [],
      this.localizedSortAs,
      this.subjects = const [],
      this.authors = const [],
      this.contributors = const [],
      this.translators = const [],
      this.editors = const [],
      this.artists = const [],
      this.illustrators = const [],
      this.letterers = const [],
      this.pencilers = const [],
      this.colorists = const [],
      this.inkers = const [],
      this.narrators = const [],
      this.publishers = const [],
      this.imprints = const [],
      this.description,
      this.duration,
      this.numberOfPages,
      this.belongsTo = const {},
      this.belongsToCollections = const [],
      this.belongsToSeries = const [],
      this.readingProgression = ReadingProgression.ltr,
      this.rendition,
      this.otherMetadata})
      : assert(languages != null),
        assert(subjects != null),
        assert(authors != null),
        assert(contributors != null),
        assert(publishers != null),
        assert(belongsToCollections != null),
        assert(belongsToSeries != null),
        assert(readingProgression != null) {
    if (belongsToCollections.isNotEmpty) {
      belongsTo["collections"] = belongsToCollections;
    }
    if (belongsToSeries.isNotEmpty) {
      belongsTo["series"] = belongsToSeries;
    }
  }

  /// An URI used as the unique identifier for this [Publication].
  final String identifier; // nullable
  final String type; // nullable

  final LocalizedString localizedTitle;
  final LocalizedString localizedSubtitle; // nullable
  final DateTime modified; // nullable
  final DateTime published; // nullable

  /// Languages used in the publication.
  final List<String> languages; // BCP 47 tag

  /// (Nullable) First language in the publication.
  String get language => (languages.isNotEmpty ? languages.first : null);

  /// Alternative title to be used for sorting the publication in the library.
  final LocalizedString localizedSortAs; // nullable

  /// Themes/subjects of the publication.
  final List<Subject> subjects;

  final List<Contributor> authors;
  final List<Contributor> publishers;
  final List<Contributor> contributors;
  final List<Contributor> translators;
  final List<Contributor> editors;
  final List<Contributor> artists;
  final List<Contributor> illustrators;
  final List<Contributor> letterers;
  final List<Contributor> pencilers;
  final List<Contributor> colorists;
  final List<Contributor> inkers;
  final List<Contributor> narrators;
  final List<Contributor> imprints;

  final String description; // nullable
  final double duration; // nullable

  /// Number of pages in the publication, if available.
  final int numberOfPages; // nullable

  final Map<String, List<Collection>> belongsTo;
  final List<Collection> belongsToCollections;
  final List<Collection> belongsToSeries;

  /// Direction of the [Publication] reading progression.
  final ReadingProgression readingProgression;

  /// Information about the contents rendition.
  final Presentation rendition; // nullable if not an EPUB [Publication]
  final Map<String, dynamic> otherMetadata;

  ReadingProgression get effectiveReadingProgression {
    if (readingProgression != ReadingProgression.auto) {
      return readingProgression;
    }

    // https://github.com/readium/readium-css/blob/develop/docs/CSS16-internationalization.md#missing-page-progression-direction
    if (languages.length != 1) {
      return ReadingProgression.ltr;
    }

    String language = languages.first.toLowerCase();

    if (language == "zh-hant" || language == "zh-tw") {
      return ReadingProgression.rtl;
    }

    // The region is ignored for ar, fa and he.
    language = language.split("-").first;
    if (["ar", "fa", "he"].contains(language)) {
      return ReadingProgression.rtl;
    }
    return ReadingProgression.ltr;
  }

  /// Syntactic sugar to access the [otherMetadata] values by subscripting [Metadata] directly.
  /// `metadata["layout"] == metadata.otherMetadata["layout"]`
  dynamic operator [](String key) => otherMetadata[key];

  @override
  List<Object> get props => [
        identifier,
        type,
        localizedTitle,
        localizedSubtitle,
        modified,
        published,
        languages,
        localizedSortAs,
        subjects,
        authors,
        translators,
        editors,
        artists,
        illustrators,
        letterers,
        pencilers,
        colorists,
        inkers,
        narrators,
        contributors,
        publishers,
        imprints,
        readingProgression,
        description,
        duration,
        numberOfPages,
        belongsTo,
        rendition,
        otherMetadata
      ];

  Presentation get presentation => Presentation.fromJson(this["presentation"]);

  /// Serializes a [Metadata] to its RWPM JSON representation.
  @override
  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "@type": type,
        if (localizedTitle != null) "title": localizedTitle.toJson(),
        if (localizedSubtitle != null) "subtitle": localizedSubtitle.toJson(),
        "modified": modified?.toIso8601String(),
        "published": published?.toIso8601String(),
        if (languages != null) "language": languages,
        if (localizedSortAs != null) "sortAs": localizedSortAs.toJson(),
        if (subjects != null) "subject": subjects.toJson(),
        if (authors != null) "author": authors.toJson(),
        if (translators != null) "translator": translators.toJson(),
        if (editors != null) "editor": editors.toJson(),
        if (artists != null) "artist": artists.toJson(),
        if (illustrators != null) "illustrator": illustrators.toJson(),
        if (letterers != null) "letterer": letterers.toJson(),
        if (pencilers != null) "penciler": pencilers.toJson(),
        if (colorists != null) "colorist": colorists.toJson(),
        if (inkers != null) "inker": inkers.toJson(),
        if (narrators != null) "narrator": narrators.toJson(),
        if (contributors != null) "contributor": contributors.toJson(),
        if (publishers != null) "publisher": publishers.toJson(),
        if (imprints != null) "imprint": imprints.toJson(),
        "readingProgression": readingProgression.value,
        "description": description,
        "duration": duration,
        "numberOfPages": numberOfPages,
        if (imprints != null) "belongsTo": belongsTo,
      };

  /// Parses a [Metadata] from its RWPM JSON representation.
  ///
  /// If the metadata can't be parsed, a warning will be logged with [warnings].
  factory Metadata.fromJson(dynamic json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    if (json == null) {
      return null;
    }
    LocalizedString localizedTitle =
        LocalizedString.fromJson(json.remove("title"));
    if (localizedTitle == null) {
      Fimber.i("[title] is required $json");
      return null;
    }
    String identifier = json.remove("identifier") as String;
    String type = json.remove("@type") as String;
    LocalizedString localizedSubtitle =
        LocalizedString.fromJson(json.remove("subtitle"));
    DateTime modified = (json.remove("modified") as String)?.iso8601ToDate();
    DateTime published = (json.remove("published") as String)?.iso8601ToDate();

    List<String> languages =
        json.optStringsFromArrayOrSingle("language", remove: true);
    LocalizedString localizedSortAs =
        LocalizedString.fromJson(json.remove("sortAs"));
    List<Subject> subjects = Subject.fromJSONArray(json.remove("subject"),
        normalizeHref: normalizeHref);
    List<Contributor> authors = Contributor.fromJSONArray(json.remove("author"),
        normalizeHref: normalizeHref);
    List<Contributor> translators = Contributor.fromJSONArray(
        json.remove("translator"),
        normalizeHref: normalizeHref);
    List<Contributor> editors = Contributor.fromJSONArray(json.remove("editor"),
        normalizeHref: normalizeHref);
    List<Contributor> artists = Contributor.fromJSONArray(json.remove("artist"),
        normalizeHref: normalizeHref);
    List<Contributor> illustrators = Contributor.fromJSONArray(
        json.remove("illustrator"),
        normalizeHref: normalizeHref);
    List<Contributor> letterers = Contributor.fromJSONArray(
        json.remove("letterer"),
        normalizeHref: normalizeHref);
    List<Contributor> pencilers = Contributor.fromJSONArray(
        json.remove("penciler"),
        normalizeHref: normalizeHref);
    List<Contributor> colorists = Contributor.fromJSONArray(
        json.remove("colorist"),
        normalizeHref: normalizeHref);
    List<Contributor> inkers = Contributor.fromJSONArray(json.remove("inker"),
        normalizeHref: normalizeHref);
    List<Contributor> narrators = Contributor.fromJSONArray(
        json.remove("narrator"),
        normalizeHref: normalizeHref);
    List<Contributor> contributors = Contributor.fromJSONArray(
        json.remove("contributor"),
        normalizeHref: normalizeHref);
    List<Contributor> publishers = Contributor.fromJSONArray(
        json.remove("publisher"),
        normalizeHref: normalizeHref);
    List<Contributor> imprints = Contributor.fromJSONArray(
        json.remove("imprint"),
        normalizeHref: normalizeHref);
    ReadingProgression readingProgression = ReadingProgression.fromValue(
        json.remove("readingProgression") as String);
    String description = json.remove("description") as String;
    double duration = json.optPositiveDouble("duration", remove: true);
    int numberOfPages = json.optPositiveInt("numberOfPages", remove: true);

    Map<String, dynamic> belongsToJson =
        (json.remove("belongsTo") as Map<String, dynamic> ??
            json.remove("belongs_to") as Map<String, dynamic> ??
            {});
    Map<String, List<Collection>> belongsTo = {};
    for (String key in belongsToJson.keys) {
      if (!belongsToJson.isNull(key)) {
        dynamic value = belongsToJson[key];
        belongsTo[key] =
            Collection.fromJSONArray(value, normalizeHref: normalizeHref);
      }
    }

    return Metadata(
      identifier: identifier,
      type: type,
      localizedTitle: localizedTitle,
      localizedSubtitle: localizedSubtitle,
      localizedSortAs: localizedSortAs,
      modified: modified,
      published: published,
      languages: languages,
      subjects: subjects,
      authors: authors,
      translators: translators,
      editors: editors,
      artists: artists,
      illustrators: illustrators,
      letterers: letterers,
      pencilers: pencilers,
      colorists: colorists,
      inkers: inkers,
      narrators: narrators,
      contributors: contributors,
      publishers: publishers,
      imprints: imprints,
      readingProgression: readingProgression,
      description: description,
      duration: duration,
      numberOfPages: numberOfPages,
      belongsTo: belongsTo,
      otherMetadata: json.toMap(),
    );
  }

  Metadata copy({
    String identifier,
    String type,
    LocalizedString localizedTitle,
    LocalizedString localizedSubtitle,
    DateTime modified,
    DateTime published,
    List<String> languages,
    LocalizedString localizedSortAs,
    List<Subject> subjects,
    List<Contributor> authors,
    List<Contributor> publishers,
    List<Contributor> contributors,
    List<Contributor> translators,
    List<Contributor> editors,
    List<Contributor> artists,
    List<Contributor> illustrators,
    List<Contributor> letterers,
    List<Contributor> pencilers,
    List<Contributor> colorists,
    List<Contributor> inkers,
    List<Contributor> narrators,
    List<Contributor> imprints,
    String description,
    double duration,
    int numberOfPages,
    Map<String, List<Collection>> belongsTo,
    ReadingProgression readingProgression,
    Presentation rendition,
    Map<String, dynamic> otherMetadata,
  }) =>
      Metadata(
        identifier: identifier ?? this.identifier,
        type: type ?? this.type,
        localizedTitle: localizedTitle ?? this.localizedTitle,
        localizedSubtitle: localizedSubtitle ?? this.localizedSubtitle,
        modified: modified ?? this.modified,
        published: published ?? this.published,
        languages: languages ?? this.languages,
        localizedSortAs: localizedSortAs ?? this.localizedSortAs,
        subjects: subjects ?? this.subjects,
        authors: authors ?? this.authors,
        publishers: publishers ?? this.publishers,
        contributors: contributors ?? this.contributors,
        translators: translators ?? this.translators,
        editors: editors ?? this.editors,
        artists: artists ?? this.artists,
        illustrators: illustrators ?? this.illustrators,
        letterers: letterers ?? this.letterers,
        pencilers: pencilers ?? this.pencilers,
        colorists: colorists ?? this.colorists,
        inkers: inkers ?? this.inkers,
        narrators: narrators ?? this.narrators,
        imprints: imprints ?? this.imprints,
        description: description ?? this.description,
        duration: duration ?? this.duration,
        numberOfPages: numberOfPages ?? this.numberOfPages,
        belongsTo: belongsTo ?? this.belongsTo,
        readingProgression: readingProgression ?? this.readingProgression,
        rendition: rendition ?? this.rendition,
        otherMetadata: otherMetadata ?? this.otherMetadata,
      );

  @override
  String toString() => 'Metadata($props)';
}
