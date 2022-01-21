// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dartx/dartx.dart';

const String fontSizeRef = "fontSize";
const String fontFamilyRef = "fontFamily";
const String fontOverrideRef = "fontOverride";
const String appearanceRef = "appearance";
const String scrollRef = "scroll";
const String publisherDefaultRef = "advancedSettings";
const String textAlignmentRef = "textAlign";
const String columnCountRef = "colCount";
const String wordSpacingRef = "wordSpacing";
const String letterSpacingRef = "letterSpacing";
const String pageMarginsRef = "pageMargins";
const String lineHeightRef = "lineHeight";

const String fontSizeName = "--USER__$fontSizeRef";
const String fontFamilyName = "--USER__$fontFamilyRef";
const String fontOverrideName = "--USER__$fontOverrideRef";
const String appearanceName = "--USER__$appearanceRef";
const String scrollName = "--USER__$scrollRef";
const String publisherDefaultName = "--USER__$publisherDefaultRef";
const String textAlignmentName = "--USER__$textAlignmentRef";
const String columnCountName = "--USER__$columnCountRef";
const String wordSpacingName = "--USER__$wordSpacingRef";
const String letterSpacingName = "--USER__$letterSpacingRef";
const String pageMarginsName = "--USER__$pageMarginsRef";
const String lineHeightName = "--USER__$lineHeightRef";

// List of strings that can identify the name of a CSS custom property
// Also used for storing UserSettings in UserDefaults
class ReadiumCSSName {
  static const ReadiumCSSName fontSize =
      ReadiumCSSName._("fontSize", "--USER__fontSize");
  static const ReadiumCSSName fontFamily =
      ReadiumCSSName._("fontFamily", "--USER__fontFamily");
  static const ReadiumCSSName fontOverride =
      ReadiumCSSName._("fontOverride", "--USER__fontOverride");
  static const ReadiumCSSName appearance =
      ReadiumCSSName._("appearance", "--USER__appearance");
  static const ReadiumCSSName scroll =
      ReadiumCSSName._("scroll", "--USER__scroll");
  static const ReadiumCSSName publisherDefault =
      ReadiumCSSName._("publisherDefault", "--USER__advancedSettings");
  static const ReadiumCSSName textAlignment =
      ReadiumCSSName._("textAlignment", "--USER__textAlign");
  static const ReadiumCSSName columnCount =
      ReadiumCSSName._("columnCount", "--USER__colCount");
  static const ReadiumCSSName wordSpacing =
      ReadiumCSSName._("wordSpacing", "--USER__wordSpacing");
  static const ReadiumCSSName letterSpacing =
      ReadiumCSSName._("letterSpacing", "--USER__letterSpacing");
  static const ReadiumCSSName pageMargins =
      ReadiumCSSName._("pageMargins", "--USER__pageMargins");
  static const ReadiumCSSName lineHeight =
      ReadiumCSSName._("lineHeight", "--USER__lineHeight");
  static const ReadiumCSSName paraIndent =
      ReadiumCSSName._("paraIndent", "--USER__paraIndent");
  static const ReadiumCSSName hyphens =
      ReadiumCSSName._("hyphens", "--USER__bodyHyphens");
  static const ReadiumCSSName ligatures =
      ReadiumCSSName._("ligatures", "--USER__ligatures");
  static const List<ReadiumCSSName> _values = [
    fontSize,
    fontFamily,
    fontOverride,
    appearance,
    scroll,
    publisherDefault,
    textAlignment,
    columnCount,
    wordSpacing,
    letterSpacing,
    pageMargins,
    lineHeight,
    paraIndent,
    hyphens,
    ligatures,
  ];

  final String name;
  final String ref;

  const ReadiumCSSName._(this.name, this.ref);

  static ReadiumCSSName? from(String name) =>
      _values.firstOrNullWhere((element) => element.name == name);
}
