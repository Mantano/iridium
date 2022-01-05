// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:dfunc/dfunc.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_shared/publication.dart';

class ReadiumThemeValues {
  final ReaderThemeConfig readerTheme;
  final ViewerSettings viewerSettings;
  bool advanced = false;
  bool scroll = false;

  ReadiumThemeValues(this.readerTheme, this.viewerSettings);

  String replaceValues(String css) => css
      .replaceFirst("{{pageGutter}}", textMargin)
      .replaceFirst("{{verticalMargin}}", verticalMargin)
      .replaceFirst("{{backgroundColor}}", backgroundColor)
      .replaceFirst("{{textColor}}", textColor)
      .replaceFirst("{{textAlign}}", textAlign)
      .replaceFirst("{{lineHeight}}", lineHeight)
      .replaceFirst(
          "{{scroll}}", scroll ? "readium-scroll-off" : "readium-scroll-on")
      .replaceFirst("{{advancedSettings}}",
          advanced ? "readium-advanced-off" : "readium-advanced-on")
      .replaceFirst("{{fontOverride}}",
          (fontFamily != "inherit") ? "readium-font-on" : "readium-font-off")
      .replaceFirst("{{fontFamily}}", fontFamily)
      .replaceFirst("{{fontWeight}}", fontWeight);

  // c.f. ReadiumCSS-after.css
  Map<String, String> get cssVarsAndValues => {
        "--RS__pageGutter": textMargin,
        "--RS__verticalMargin": verticalMargin,
        "--RS__backgroundColor": backgroundColor,
        "--RS__textColor": textColor,
        ReadiumCSSName.textAlignment.name: textAlign,
        ReadiumCSSName.lineHeight.name: lineHeight,
        ReadiumCSSName.fontSize.name: fontSize,
        ReadiumCSSName.publisherDefault.name:
            advanced ? "readium-advanced-off" : "readium-advanced-on",
        ReadiumCSSName.scroll.name:
            scroll ? "readium-scroll-on" : "readium-scroll-off",
        ReadiumCSSName.fontOverride.name:
            (fontFamily != "inherit") ? "readium-font-on" : "readium-font-off",
        ReadiumCSSName.fontFamily.name: fontFamily,
        // TODO Never used, should remove...
        "--USER__fontWeight": fontWeight,
      };

  String get verticalMargin => "${verticalMarginInt}px";

  int get verticalMarginInt =>
      (!viewerSettings.scrollViewDoc) ? TextMargin.margin_20.value.toInt() : 0;

  String get textMargin =>
      readerTheme.textMargin?.let((it) => "${it.value}px") ??
      "${TextMargin.margin_20.value}px";

  String get backgroundColor => _colorAsString(readerTheme.backgroundColor);

  String get textColor => _colorAsString(readerTheme.textColor);

  String _colorAsString(Color? color) =>
      (color != null) ? _formatColor(color.value) : "inherit";

  String _fontFamilyAsString() => formatFontFamily(readerTheme.fontFamily);

  String _fontWeightAsString() => formatFontWeight(readerTheme.fontWeight);

  String get fontFamily => _fontFamilyAsString();

  String get fontWeight => _fontWeightAsString();

  String get textAlign => readerTheme.textAlign?.let((it) => it.name) ?? "";

  String get lineHeight =>
      readerTheme.lineHeight?.let((it) => "${it.value}") ?? "";

  String get fontSize => '${viewerSettings.fontSize}%';

  static String _formatColor(int color) =>
      "#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}";

  static String formatFontFamily(String? fontFamily) => fontFamily ?? "inherit";

  static String formatFontWeight(String? fontWeight) => fontWeight ?? "inherit";
}
