import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

abstract class SelectionListener {
  final ReaderContext readerContext;
  final BuildContext context;

  SelectionListener(this.readerContext, this.context);

  void displayPopup(Selection selection);

  void hidePopup();

  void showHighlightPopup(Selection selection, HighlightStyle style,
      {String? highlightId});
}
