// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:model/model.dart';
import 'package:navigator/src/book/ui/drawer/book_search_panel.dart';
import 'package:navigator/src/book/ui/drawer/nav_panel.dart';
import 'package:navigator/src/book/ui/drawer/notes_panel.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/document/ui/drawer/bookmark_list_tile.dart';
import 'package:navigator/src/document/ui/drawer/bookmarks_panel.dart';
import 'package:navigator/src/document/ui/drawer/reader_drawer.dart';
import 'package:navigator/src/epub/model/commands.dart';

class BookReaderDrawer extends ReaderDrawer<Book> {
  final ReaderContext readerContext;

  const BookReaderDrawer({
    Key key,
    @required Book book,
    @required this.readerContext,
  }) : super(
          key: key,
          document: book,
        );

  @override
  State<StatefulWidget> createState() => BookReaderDrawerState();
}

class BookReaderDrawerState extends ReaderDrawerState<Book, BookReaderDrawer> {
  ReaderContext get readerContext => widget.readerContext;

  @override
  void initState() {
    super.initState();
    readerPanels.addAll([
      NavPanel(readerContext),
      BookmarksPanel(
        readerContext.annotationsBloc,
        document,
        BookmarkListType.book,
        openAnnotation,
      ),
      NotesPanel(readerContext.annotationsBloc, document),
      const BookSearchPanel(),
    ]);
  }

  void openAnnotation(Annotation annotation) => ReaderContext.of(context)
      .execute(GoToLocationCommand(annotation.location));
}
