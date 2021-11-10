// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:ui';

import 'package:model/css/reader_theme.dart';
import 'package:model/css/text_margin.dart';
import 'package:navigator/src/epub/settings/viewer_settings.dart';

class ReadiumThemeValues {
  final ReaderTheme readerTheme;
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

  String get textMargin => (readerTheme.textMargin != null)
      ? "${readerTheme.textMargin.value}px"
      : "${TextMargin.margin_20.value}px";

  String get backgroundColor => _colorAsString(readerTheme.backgroundColor);

  String get textColor => _colorAsString(readerTheme.textColor);

  String _colorAsString(Color color) =>
      (color != null) ? formatColor(color.value) : "inherit";

  String get textAlign =>
      (readerTheme.textAlign != null) ? readerTheme.textAlign.name : "";

  String get lineHeight =>
      (readerTheme.lineHeight != null) ? "${readerTheme.lineHeight.value}" : "";

  String get fontSize => '${viewerSettings.fontSize}%';

  static String formatColor(int color) {
    if (color == null) {
      return null;
    }
    return "#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}";
  }
}
