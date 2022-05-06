import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/selection/highlight_popup.dart';
import 'package:mno_navigator/src/epub/selection/new_selection_popup.dart';

class SimpleSelectionListener extends SelectionListener {
  NewSelectionPopup? _newSelectionPopup;
  HighlightPopup? _highlightPopup;

  SimpleSelectionListener(ReaderContext readerContext, BuildContext context)
      : super(readerContext, context);

  @override
  void displayPopup(Selection selection) {
    _newSelectionPopup = NewSelectionPopup(this);
    _newSelectionPopup!.displaySelectionPopup(context, selection);
  }

  @override
  void hidePopup() {
    _hideSelectionPopup();
    _hideHighlightPopup();
  }

  void _hideSelectionPopup() {
    _newSelectionPopup?.hidePopup();
    _newSelectionPopup = null;
  }

  void _hideHighlightPopup() {
    _highlightPopup?.hidePopup();
    _highlightPopup = null;
  }

  @override
  void showHighlightPopup(Selection selection, HighlightStyle style, Color tint,
      {String? highlightId}) {
    _hideSelectionPopup();
    _highlightPopup = HighlightPopup(this);
    _highlightPopup!
        .showHighlightPopup(context, selection, style, tint, highlightId);
  }
}
