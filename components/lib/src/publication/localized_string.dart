// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fimber/fimber.dart';
import 'package:mno_commons_dart/utils/jsonable.dart';
import 'package:universal_io/io.dart';

/// A potentially localized (multilingual) string.
///
/// The translations are indexed by a BCP 47 language tag.
class LocalizedString with EquatableMixin, JSONable {
  LocalizedString._(this.translations) : assert(translations.isNotEmpty);

  factory LocalizedString(Map<String, String> strings) {
    if (strings == null || strings.isEmpty) {
      return null;
    }
    return LocalizedString._(strings);
  }

  factory LocalizedString.fromString(String string) {
    if (string == null || string.isEmpty) {
      return null;
    }
    return LocalizedString._({'en': string});
  }

  /// Parses a [LocalizedString] from its RWPM JSON representation.
  /// If the localized string can't be parsed, a warning will be logged with [warnings].
  ///
  /// "anyOf": [
  ///   {
  ///     "type": "string"
  ///   },
  ///   {
  ///     "description": "The language in a language map must be a valid BCP 47 tag.",
  ///     "type": "object",
  ///     "patternProperties": {
  ///       "^((?<grandfathered>(en-GB-oed|i-ami|i-bnn|i-default|i-enochian|i-hak|i-klingon|i-lux|i-mingo|i-navajo|i-pwn|i-tao|i-tay|i-tsu|sgn-BE-FR|sgn-BE-NL|sgn-CH-DE)|(art-lojban|cel-gaulish|no-bok|no-nyn|zh-guoyu|zh-hakka|zh-min|zh-min-nan|zh-xiang))|((?<language>([A-Za-z]{2,3}(-(?<extlang>[A-Za-z]{3}(-[A-Za-z]{3}){0,2}))?)|[A-Za-z]{4}|[A-Za-z]{5,8})(-(?<script>[A-Za-z]{4}))?(-(?<region>[A-Za-z]{2}|[0-9]{3}))?(-(?<variant>[A-Za-z0-9]{5,8}|[0-9][A-Za-z0-9]{3}))*(-(?<extension>[0-9A-WY-Za-wy-z](-[A-Za-z0-9]{2,8})+))*(-(?<privateUse>x(-[A-Za-z0-9]{1,8})+))?)|(?<privateUse2>x(-[A-Za-z0-9]{1,8})+))$": {
  ///         "type": "string"
  ///       }
  ///     },
  ///     "additionalProperties": false,
  ///     "minProperties": 1
  ///   }
  /// ]
  factory LocalizedString.fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    if (json is String) {
      return LocalizedString.fromString(json);
    }
    if (json is Map) {
      return LocalizedString._fromJSONObject(json);
    }
    Fimber.i("invalid localized string object");
    return null;
  }

  factory LocalizedString._fromJSONObject(Map<String, dynamic> json) {
    Map<String, String> translations = {};
    for (String key in json.keys) {
      String string = json.optNullableString(key);
      if (string == null) {
        Fimber.i("invalid localized string object $json");
      } else {
        translations[key] = string;
      }
    }

    return LocalizedString(translations);
  }

  final Map<String, String> translations;

  /// Returns the localized string matching the most the user's locale.
  String get string => stringForLanguageCode(null);

  /// Returns the localized string matching the given language code, or fallback on the user's locale.
  String stringForLanguageCode(String languageCode) {
    languageCode = languageCode ??
        window.locale.languageCode ??
        Platform.localeName ??
        'en';
    return translations[languageCode]
        // First string with the language having the locale for prefix.
        ??
        translations.entries
            .firstWhere((e) => e.key?.startsWith(languageCode) == true,
                orElse: () => null)
            ?.value ??
        // First string with the locale having the language for prefix.
        translations.entries
            .firstWhere((e) => e.key != null && languageCode.startsWith(e.key),
                orElse: () => null)
            ?.value ??
        translations['en'] ??
        translations.values.first;
  }

  /// Serializes a [LocalizedString] to its RWPM JSON representation.
  @override
  Map<String, String> toJson() => translations;

  @override
  List get props => [translations];

  @override
  String toString() => 'LocalizedString($translations)';
}
