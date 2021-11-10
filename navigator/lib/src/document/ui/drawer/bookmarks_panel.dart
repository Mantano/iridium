// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:model/model.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_framework/widgets/multi_select.dart';
import 'package:navigator/src/document/ui/drawer/annotations_panel.dart';
import 'package:navigator/src/document/ui/drawer/bookmark_list_tile.dart';
import 'package:navigator/src/document/ui/drawer/reader_panel.dart';

class BookmarksPanel extends AnnotationsPanel {
  final BookmarkListType type;
  final OnOpenAnnotation onOpenAnnotation;

  const BookmarksPanel(AnnotationsBloc annotationsBloc, Document document,
      this.type, this.onOpenAnnotation,
      {Key key})
      : super(annotationsBloc, AnnotationKind.bookmark, document, key: key);

  @override
  State<StatefulWidget> createState() => BookmarksPanelState();

  @override
  Widget buildIcon() => SvgAssets.bookmarkLine.widget();
}

class BookmarksPanelState extends ReaderPanelState<BookmarksPanel> {
  CustomMultiSelectController _multiSelectController;

  @override
  void initState() {
    super.initState();
    widget.annotationsBloc.add(LoadDocuments());
    _multiSelectController = CustomMultiSelectController();
    _multiSelectController.init();
  }

  @override
  Widget buildPanel(BuildContext context) => StreamBuilder(
        initialData: const <Annotation>[],
        stream: widget.annotationsStream(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Annotation>> snapshot) =>
                ClipRect(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                vertical: ReaderPanelState.paddingValue),
            itemExtent: 48.0,
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) => SizedBox(
              height: 48.0,
              child: BookmarkListTile.create(
                annotation: snapshot.data[index],
                multiSelectController: _multiSelectController,
                type: widget.type,
                onOpenAnnotation: widget.onOpenAnnotation,
              ),
            ),
          ),
        ),
      );
}
