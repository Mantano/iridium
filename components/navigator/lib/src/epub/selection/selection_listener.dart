import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/epub/extensions/decoration_change.dart';

abstract class SelectionListener {
  final ReaderContext readerContext;
  final BuildContext context;

  SelectionListener(this.readerContext, this.context);

  JsApi? get jsApi => readerContext.currentSpineItemContext?.jsApi;

  void displayPopup(Selection selection);

  void hidePopup();

  void showHighlightPopup(Selection selection, HighlightStyle style, Color tint,
      {String? highlightId});

  void updateHighlight(Selection selection, HighlightStyle style, Color color,
          String highlightId) =>
      readerContext.readerAnnotationRepository
          .get(highlightId)
          .then((highlight) {
        if (highlight != null) {
          highlight.style = style;
          highlight.tint = color.value;
          readerContext.readerAnnotationRepository.save(highlight);
          jsApi?.updateDecorations(
              {"highlights": highlight.toDecorations(isActive: false)});
        }
      });

  void createHighlight(
          Selection selection, HighlightStyle style, Color color) =>
      readerContext.readerAnnotationRepository
          .createHighlight(readerContext.paginationInfo, selection.locator,
              style, color.value)
          .then((highlight) {
        jsApi?.addDecorations(
            {"highlights": highlight.toDecorations(isActive: false)});
      });

  void deleteHighlight(String highlightId) =>
      readerContext.readerAnnotationRepository.delete([highlightId]);
}
