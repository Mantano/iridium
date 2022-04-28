import 'dart:math';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/extensions/decoration_change.dart';
import 'package:mno_navigator/src/epub/selection/selection_popup.dart';

class HighlightPopup extends SelectionPopup {
  static const List<Color> highlightTints = [
    Color.fromARGB(255, 247, 124, 124),
    Color.fromARGB(255, 173, 247, 123),
    Color.fromARGB(255, 124, 198, 247),
    Color.fromARGB(255, 249, 239, 125),
    Color.fromARGB(255, 182, 153, 255),
  ];
  final SimpleSelectionListener selectionListener;

  HighlightPopup(this.selectionListener);

  ReaderContext get readerContext => selectionListener.readerContext;

  @override
  double get optionsWidth => 300.0;

  @override
  double get optionsHeight => 48.0;

  JsApi? get jsApi => readerContext.currentSpineItemContext?.jsApi;

  void showHighlightPopup(
    BuildContext context,
    Selection selection,
    HighlightStyle style,
    String? highlightId,
  ) {
    Rectangle<double>? rect = selection.rectOnScreen;
    OverlayEntry entry = OverlayEntry(
        builder: (context) => Stack(
              children: [
                GestureDetector(
                  onTap: _close,
                ),
                if (rect != null)
                  Positioned.fromRect(
                    rect: getPopupRect(context, rect),
                    child: Material(
                      type: MaterialType.canvas,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      elevation: 8.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ...highlightTints
                              .map((color) => buildColorOption(color, () {
                                    Fimber.d("color: $color");
                                    if (highlightId != null) {
                                      updateHighlight(
                                          selection, style, color, highlightId);
                                    } else {
                                      createHighlight(selection, style, color);
                                    }
                                    _close();
                                  }))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
              ],
            ));
    this.entry = entry;
    Overlay.of(context)?.insert(entry);
  }

  Widget buildColorOption(Color color, VoidCallback action) => IconButton(
        onPressed: action,
        icon: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      );

  void _close() {
    jsApi?.clearSelection();
    selectionListener.hidePopup();
  }

  void updateHighlight(Selection selection, HighlightStyle style, Color color,
      String highlightId) {
    readerContext.readerAnnotationRepository.get(highlightId).then((highlight) {
      if (highlight != null) {
        highlight.style = style;
        highlight.tint = color.value;
        readerContext.readerAnnotationRepository.save(highlight);
        jsApi?.updateDecorations(
            {"highlights": highlight.toDecorations(isActive: false)});
      }
    });
  }

  void createHighlight(Selection selection, HighlightStyle style, Color color) {
    readerContext.readerAnnotationRepository
        .createHighlight(selection.locator, style, color.value)
        .then((highlight) {
      jsApi?.addDecorations(
          {"highlights": highlight.toDecorations(isActive: false)});
    });
  }
}
