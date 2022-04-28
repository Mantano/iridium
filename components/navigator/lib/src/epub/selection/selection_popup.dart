import 'dart:math';

import 'package:flutter/widgets.dart';

abstract class SelectionPopup {
  OverlayEntry? entry;

  double get optionsWidth;

  double get optionsHeight;

  Rect getPopupRect(BuildContext context, Rectangle<double> rect) {
    Size size = MediaQuery.of(context).size;
    double left = min((rect.left + rect.right - optionsWidth) / 2,
        size.width - optionsWidth - 16.0);
    double top = rect.bottom + 8.0;
    double width = optionsWidth;
    double height = optionsHeight;
    return Rect.fromLTWH(left, top, width, height);
  }

  void hidePopup() {
    entry?.remove();
    entry = null;
  }
}
