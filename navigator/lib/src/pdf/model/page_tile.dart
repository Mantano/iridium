// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:math';

import 'package:equatable/equatable.dart';

class PageTile with EquatableMixin {
  static const int highlightPageWidth = 10000;
  static const double highlightMergeGap =
      highlightPageWidth / 12; // 8.33% gap filling
  final int left, top, right, bottom;
  final int pageWidth, pageHeight;

  factory PageTile.size(int pageWidth, int pageHeight) =>
      PageTile._(pageWidth, pageHeight, 0, 0, pageWidth, pageHeight);

  factory PageTile.viewport(
          int pageWidth, int pageHeight, Rectangle<int> viewport) =>
      PageTile._(pageWidth, pageHeight, viewport.left, viewport.top,
          viewport.right, viewport.bottom);

  PageTile._(this.pageWidth, this.pageHeight, this.left, this.top, this.right,
      this.bottom);

  static int getBoxMergeGap(int pageWidth) =>
      (highlightMergeGap * pageWidth / highlightPageWidth).ceil();

  int get boxMergeGap => getBoxMergeGap(pageWidth);

  int get tileWidth => right - left;

  int get tileHeight => bottom - top;

  double get pageRatio => pageWidth / pageHeight;

  double get viewportRatio => tileWidth / tileHeight;

  bool hasViewport() =>
      (left != 0) ||
      (top != 0) ||
      (tileWidth != pageWidth) ||
      (tileHeight != pageHeight);

  @override
  String toString() =>
      "PageTile[$pageWidth x $pageHeight viewport($left, $top to $right, $bottom), tilesize($tileWidth x $tileHeight)]";

  Rectangle<int> get viewport =>
      Rectangle<int>(left, top, tileWidth, tileHeight);

  @override
  List<Object> get props => [
        left,
        top,
        right,
        bottom,
        pageWidth,
        pageHeight,
      ];

  PageTile createUpperHalfTile() {
    int topHalfViewportHeight = (viewport.height / 2).ceil();
    return PageTile._(right, top + topHalfViewportHeight, left, top, right,
        top + topHalfViewportHeight);
  }

  PageTile createLowerHalfTile() {
    int topHalfViewportHeight = (viewport.height / 2).ceil();
    int bottomHalfViewportHeight = viewport.height - topHalfViewportHeight;
    int vpTop = top + topHalfViewportHeight;
    return PageTile._(right, top + viewport.height, left, vpTop, right,
        vpTop + bottomHalfViewportHeight);
  }

  PageTile createReducedTile(int factor) => PageTile._(
      (pageWidth / factor).ceil(),
      (pageHeight / factor).ceil(),
      (left / factor).ceil(),
      (top / factor).ceil(),
      (left / factor + viewport.width / factor).ceil(),
      (top / factor + viewport.height / factor).ceil());

  PageTile createScaledTile(double scale) => PageTile._(
      (pageWidth * scale).ceil(),
      (pageHeight * scale).ceil(),
      (left * scale).ceil(),
      (top * scale).ceil(),
      (left * scale + viewport.width * scale).ceil(),
      (top * scale + viewport.height * scale).ceil());

  PageTile moveViewport(int newLeft, int newTop) => PageTile._(
      pageWidth,
      pageHeight,
      newLeft,
      newTop,
      newLeft + viewport.width,
      newTop + viewport.height);
}
