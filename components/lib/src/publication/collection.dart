// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../../publication.dart';

/// Contributor Object for the Readium Web Publication Manifest.
/// https://readium.org/webpub-manifest/schema/contributor-object.schema.json
///
/// @param localizedName The name of the contributor.
/// @param identifier An unambiguous reference to this contributor.
/// @param sortAs The string used to sort the name of the contributor.
/// @param roles The roles of the contributor in the publication making.
/// @param position The position of the publication in this collection/series,
///     when the contributor represents a collection.
/// @param links Used to retrieve similar publications for the given contributor.
class Collection extends Contributor {
  Collection({
    @required LocalizedString localizedName,
    String identifier,
    LocalizedString localizedSortAs,
    Set<String> roles = const {},
    double position,
    List<Link> links = const [],
  }) : super(
          localizedName: localizedName,
          identifier: identifier,
          localizedSortAs: localizedSortAs,
          roles: roles,
          position: position,
          links: links,
        );

  /// Parses a [Contributor] from its RWPM JSON representation.
  ///
  /// A contributor can be parsed from a single string, or a full-fledged object.
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  /// If the contributor can't be parsed, a warning will be logged with [warnings].
  factory Collection.fromJson(dynamic json,
          {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) =>
      Contributor.fromJson(json, normalizeHref: normalizeHref)?.toCollection();

  /// Creates a list of [Collection] from its RWPM JSON representation.
  ///
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  /// If a contributor can't be parsed, a warning will be logged with [warnings].
  static List<Collection> fromJSONArray(dynamic json,
          {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) =>
      Contributor.fromJSONArray(json, normalizeHref: normalizeHref)
          .map((contributor) => contributor.toCollection())
          .toList();
}

extension ContributorExtension on Contributor {
  Collection toCollection() => Collection(
      localizedName: localizedName,
      identifier: identifier,
      localizedSortAs: localizedSortAs,
      roles: roles,
      position: position,
      links: links);
}
