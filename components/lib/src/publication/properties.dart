// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:mno_commons_dart/utils/jsonable.dart';

import 'encryption.dart';
import 'presentation.dart';

/// Set of properties associated with a [Link].
///
/// See https://readium.org/webpub-manifest/schema/properties.schema.json
///     https://readium.org/webpub-manifest/schema/extensions/epub/properties.schema.json
class Properties with EquatableMixin, JSONable {
  Properties(
      {this.page,
      this.contains = const [],
      this.orientation,
      this.layout,
      this.overflow,
      this.spread,
      Encryption encryption,
      Map<String, dynamic> otherProperties})
      : assert(contains != null) {
    this.otherProperties = otherProperties ?? {};
    if (encryption != null) {
      this.otherProperties["encrypted"] = encryption.toJson();
    }
  }

  /// (Nullable) Indicates how the linked resource should be displayed in a
  /// reading environment that displays synthetic spreads.
  final PresentationPage page;

  /// Identifies content contained in the linked resource, that cannot be
  /// strictly identified using a media type.
  final List<String> contains;

  /// (Nullable) Suggested orientation for the device when displaying the linked
  /// resource.
  final PresentationOrientation orientation;

  /// (Nullable) Hints how the layout of the resource should be presented.
  final EpubLayout layout;

  /// (Nullable) Suggested method for handling overflow while displaying the
  /// linked resource.
  final PresentationOverflow overflow;

  /// (Nullable) Indicates the condition to be met for the linked resource to be
  /// rendered within a synthetic spread.
  final PresentationSpread spread;

  Map<String, dynamic> otherProperties;

  @override
  List<Object> get props => [
        orientation,
        page,
        contains,
        layout,
        overflow,
        spread,
        encryption,
        otherProperties,
      ];

  /// (Nullable) Indicates that a resource is encrypted/obfuscated and provides
  /// relevant information for decryption.
  Encryption get encryption {
    if (otherProperties.containsKey("encrypted")) {
      return Encryption.fromJSON(
          otherProperties["encrypted"] as Map<String, dynamic>);
    }
    return null;
  }

  /// Serializes a [Properties] to its RWPM JSON representation.
  @override
  Map<String, dynamic> toJson() => {
        "orientation": orientation?.value,
        "page": page?.value,
        "contains": contains,
        "layout": layout?.value,
        "overflow": overflow?.value,
        "spread": spread?.value,
        "encryption": encryption?.toJson(),
        "otherProperties": otherProperties,
      };

  Properties add(Map<String, dynamic> properties) {
    Map<String, dynamic> props = Map.of(otherProperties)..addAll(properties);
    return Properties(otherProperties: props);
  }

  Properties copy(
          {PresentationPage page,
          List<String> contains,
          PresentationOrientation orientation,
          EpubLayout layout,
          PresentationOverflow overflow,
          PresentationSpread spread,
          Encryption encryption,
          Map<String, dynamic> otherProperties}) =>
      Properties(
        page: page ?? this.page,
        contains: contains ?? this.contains,
        orientation: orientation ?? this.orientation,
        layout: layout ?? this.layout,
        overflow: overflow ?? this.overflow,
        spread: spread ?? this.spread,
        encryption: encryption ?? this.encryption,
        otherProperties: otherProperties ?? this.otherProperties,
      );

  @override
  String toString() => 'Properties(${toJson()})';

  /// Creates a [Properties] from its RWPM JSON representation.
  static Properties fromJSON(Map<String, dynamic> json) => Properties(
        page: PresentationPage.from(json.optString("page")),
        contains: json.optStringsFromArrayOrSingle("contains"),
        orientation:
            PresentationOrientation.from(json.optString("orientation")),
        layout: EpubLayout.from(json.optString("layout")),
        overflow: PresentationOverflow.from(json.optString("overflow")),
        spread: PresentationSpread.from(json.optString("spread")),
        encryption: Encryption.fromJSON(json.optJSONObject('encrypted')),
        otherProperties: json.optJSONObject('otherProperties'),
      );
}
