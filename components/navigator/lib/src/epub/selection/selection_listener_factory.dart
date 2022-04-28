import 'package:flutter/widgets.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/src/publication/reader_context.dart';

abstract class SelectionListenerFactory {
  SelectionListener create(ReaderContext readerContext, BuildContext context);
}

class SimpleSelectionListenerFactory extends SelectionListenerFactory {
  @override
  SelectionListener create(ReaderContext readerContext, BuildContext context) =>
      SimpleSelectionListener(readerContext, context);
}
