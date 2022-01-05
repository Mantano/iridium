// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show Color;

import 'package:equatable/equatable.dart';
import 'package:mno_commons/utils/jsonable.dart';
import 'package:mno_navigator/epub.dart';

class ReaderThemeConfig with EquatableMixin implements JSONable {
  final String name;
  Color? textColor;
  Color? backgroundColor;
  TextAlign? textAlign;
  LineHeight? lineHeight;
  TextMargin? textMargin;
  String? fontFamily;
  String? fontWeight;

  ReaderThemeConfig(
      this.name,
      this.textColor,
      this.backgroundColor,
      this.textAlign,
      this.lineHeight,
      this.textMargin,
      this.fontFamily,
      this.fontWeight);

  ReaderThemeConfig._none()
      : name = "None",
        textColor = null,
        backgroundColor = null,
        textAlign = null,
        lineHeight = null,
        textMargin = null,
        fontFamily = null,
        fontWeight = null;

  ReaderThemeConfig copy({
    String? name,
    Color? textColor,
    Color? backgroundColor,
    TextAlign? textAlign,
    LineHeight? lineHeight,
    TextMargin? textMargin,
    String? fontFamily,
    String? fontWeight,
  }) =>
      ReaderThemeConfig(
        name ?? this.name,
        textColor ?? this.textColor,
        backgroundColor ?? this.backgroundColor,
        textAlign ?? this.textAlign,
        lineHeight ?? this.lineHeight,
        textMargin ?? this.textMargin,
        fontFamily ?? this.fontFamily,
        fontWeight ?? this.fontWeight,
      );

  static final ReaderThemeConfig defaultTheme = ReaderThemeConfig._none();

  @override
  Map<String, dynamic> toJson() => {
        "name": name,
        if (textColor != null) "textColor": textColor!.value,
        if (backgroundColor != null) "backgroundColor": backgroundColor!.value,
        if (textAlign != null) "textAlign": textAlign!.id,
        if (lineHeight != null) "lineHeight": lineHeight!.id,
        if (textMargin != null) "textMargin": textMargin!.id,
        if (fontFamily != null) "fontFamily": fontFamily,
        if (fontWeight != null) "fontWeight": fontWeight,
      };

  factory ReaderThemeConfig.fromJson(Map<String, Object> data) =>
      ReaderThemeConfig(
        data["name"] as String,
        _asColor(data["textColor"]),
        _asColor(data["backgroundColor"]),
        _asTextAlign(data["textAlign"]),
        _asLineHeight(data["lineHeight"]),
        _asTextMargin(data["textMargin"]),
        data["fontFamily"] as String,
        data["fontWeight"] as String,
      );

  static Color? _asColor(dynamic color) =>
      (color != null) ? Color(color as int) : null;

  static TextAlign? _asTextAlign(dynamic textAlign) =>
      (textAlign != null) ? TextAlign.from(textAlign as int) : null;

  static LineHeight? _asLineHeight(dynamic lineHeight) =>
      (lineHeight != null) ? LineHeight.from(lineHeight as int) : null;

  static TextMargin? _asTextMargin(dynamic textMargin) =>
      (textMargin != null) ? TextMargin.from(textMargin as int) : null;

  @override
  String toString() => 'ReaderThemeConfig{name: $name, '
      'textColor: $textColor, '
      'backgroundColor: $backgroundColor, '
      'textAlign: $textAlign, '
      'lineHeight: $lineHeight, '
      'textMargin: $textMargin, '
      'fontFamily: $fontFamily, '
      'fontWeight: $fontWeight}';

  @override
  List<Object?> get props => [
        name,
        textColor,
        backgroundColor,
        textAlign,
        lineHeight,
        textMargin,
        fontFamily,
        fontWeight,
      ];
}
