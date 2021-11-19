// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:dfunc/dfunc.dart';
import 'package:mno_navigator/epub.dart';

class ReadiumThemeValues {
  final ReaderThemeConfig readerTheme;
  final ViewerSettings viewerSettings;

  ReadiumThemeValues(this.readerTheme, this.viewerSettings);

  String replaceValues(String css) => css
      .replaceFirst("{{pageGutter}}", textMargin)
      .replaceFirst("{{verticalMargin}}", verticalMargin)
      .replaceFirst("{{backgroundColor}}", backgroundColor)
      .replaceFirst("{{textColor}}", textColor)
      .replaceFirst("{{textAlign}}", textAlign)
      .replaceFirst("{{lineHeight}}", lineHeight);

  Map<String, String> get cssVarsAndValues => {
        "--RS__pageGutter": textMargin,
        "--RS__verticalMargin": verticalMargin,
        "--RS__backgroundColor": backgroundColor,
        "--RS__textColor": textColor,
        "--USER__textAlign": textAlign,
        "--USER__lineHeight": lineHeight,
        "--USER__fontSize": fontSize,
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

  String get textAlign => readerTheme.textAlign?.let((it) => it.name) ?? "";

  String get lineHeight =>
      readerTheme.lineHeight?.let((it) => "${it.value}") ?? "";

  String get fontSize => '${viewerSettings.fontSize}%';

  static String _formatColor(int color) =>
      "#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}";
}
