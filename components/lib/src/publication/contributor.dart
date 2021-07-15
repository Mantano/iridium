// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:meta/meta.dart';
import 'package:r2_commons_dart/utils/jsonable.dart';

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
class Contributor with EquatableMixin, JSONable {
  Contributor({
    @required this.localizedName,
    this.identifier,
    this.localizedSortAs,
    this.roles = const {},
    this.position,
    this.links = const [],
  })  : assert(localizedName != null),
        assert(roles != null);

  static Contributor simple(String name) => (name != null && name.isNotEmpty)
      ? Contributor(localizedName: LocalizedString.fromString(name))
      : null;

  /// The name of the contributor.
  final LocalizedString localizedName;

  /// (Nullable) An unambiguous reference to this contributor.
  final String identifier;

  /// (Nullable) The string used to sort the name of the contributor.
  final LocalizedString localizedSortAs;

  /// The role of the contributor in the publication making.
  final Set<String> roles;

  /// (Nullable) The position of the publication in this collection/series, when the contributor represents a collection.
  final double position;
  final List<Link> links;

  /// Returns the default translation string for the [localizedName].
  String get name => localizedName.string;

  /// Returns the default translation string for the [localizedSortAs].
  String get sortAs => localizedSortAs?.string;

  @override
  List<Object> get props =>
      [localizedName, identifier, localizedSortAs, roles, position, links];

  @override
  String toString() => '$runtimeType($props)';

  /// Serializes a [Contributor] to its RWPM JSON representation.
  @override
  Map<String, dynamic> toJson() => {}
    ..putJSONableIfNotEmpty("name", localizedName)
    ..put("identifier", identifier)
    ..putJSONableIfNotEmpty("sortAs", localizedSortAs)
    ..putIterableIfNotEmpty("role", roles)
    ..put("position", position)
    ..putIterableIfNotEmpty("links", links);

  /// Parses a [Contributor] from its RWPM JSON representation.
  ///
  /// A contributor can be parsed from a single string, or a full-fledged object.
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  /// If the contributor can't be parsed, a warning will be logged with [warnings].
  factory Contributor.fromJson(dynamic json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    if (json == null) {
      return null;
    }

    LocalizedString localizedName;
    if (json is String) {
      localizedName = LocalizedString.fromJson(json);
    } else if (json is Map<String, dynamic>) {
      localizedName = LocalizedString.fromJson(json.opt("name"));
    }
    if (localizedName == null) {
      Fimber.i("[name] is required");
      return null;
    }

    Map<String, dynamic> jsonObject =
        (json is Map<String, dynamic>) ? json : {};
    return Contributor(
        localizedName: localizedName,
        identifier: jsonObject.optNullableString("identifier"),
        localizedSortAs: LocalizedString.fromJson(jsonObject.remove("sortAs")),
        roles: jsonObject.optStringsFromArrayOrSingle("role").toSet(),
        position: jsonObject.optNullableDouble("position"),
        links: Link.fromJSONArray(jsonObject.optJSONArray("links"),
            normalizeHref: normalizeHref));
  }

  /// Creates a list of [Contributor] from its RWPM JSON representation.
  ///
  /// The [links]' href and their children's will be normalized recursively using the
  /// provided [normalizeHref] closure.
  /// If a contributor can't be parsed, a warning will be logged with [warnings].
  static List<Contributor> fromJSONArray(dynamic json,
      {LinkHrefNormalizer normalizeHref = linkHrefNormalizerIdentity}) {
    if (json is String || json is Map<String, dynamic>) {
      return [json]
          .map((it) => Contributor.fromJson(it, normalizeHref: normalizeHref))
          .where((e) => e != null)
          .toList();
    } else if (json is List) {
      return json
          .map((it) => Contributor.fromJson(it, normalizeHref: normalizeHref))
          .toList();
    }
    return [];
  }
}
