import 'dart:math';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/selection/selection_popup.dart';

class NewSelectionPopup extends SelectionPopup {
  final SimpleSelectionListener selectionListener;

  NewSelectionPopup(this.selectionListener);

  @override
  double get optionsWidth => 300.0;

  @override
  double get optionsHeight => 48.0;

  void displayPopup(BuildContext context, Selection selection) {
    Rectangle<double>? rect = selection.rectOnScreen;
    OverlayEntry entry = OverlayEntry(
        builder: (context) => Stack(
              children: [
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
                          buildOption("Highlight", () {
                            selectionListener.showHighlightPopup(
                                selection, HighlightStyle.highlight);
                          }),
                          buildOption("Underline", () {
                            selectionListener.showHighlightPopup(
                                selection, HighlightStyle.underline);
                          }),
                          buildOption("Note", () {
                            Fimber.d("Note");
                          }),
                        ],
                      ),
                    ),
                  ),
              ],
            ));
    this.entry = entry;
    Overlay.of(context)?.insert(entry);
  }

  Widget buildOption(String text, VoidCallback action) => TextButton(
        onPressed: action,
        child: Text(text),
      );
}
