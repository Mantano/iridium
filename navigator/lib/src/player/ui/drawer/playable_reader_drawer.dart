// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/document/playable_document.dart';
import 'package:model/model.dart';
import 'package:ui_commons/widgets/player/player_controller.dart';
import 'package:navigator/src/document/ui/drawer/attachements_panel.dart';
import 'package:navigator/src/document/ui/drawer/bookmark_list_tile.dart';
import 'package:navigator/src/document/ui/drawer/bookmarks_panel.dart';
import 'package:navigator/src/document/ui/drawer/reader_drawer.dart';

class PlayableReaderDrawer extends ReaderDrawer<PlayableDocument> {
  final PlayerController controller;

  const PlayableReaderDrawer({
    Key key,
    @required PlayableDocument playableDocument,
    @required this.controller,
  }) : super(
          key: key,
          document: playableDocument,
        );

  @override
  State<StatefulWidget> createState() => PlayableReaderDrawerState();
}

class PlayableReaderDrawerState
    extends ReaderDrawerState<PlayableDocument, PlayableReaderDrawer> {
  PlayerController get controller => widget.controller;

  AnnotationsBloc get annotationsBloc =>
      BlocProvider.of<AnnotationsBloc>(context);

  @override
  void initState() {
    super.initState();
    readerPanels.add(AttachmentsPanel(document));
    readerPanels.add(BookmarksPanel(
        annotationsBloc, document, BookmarkListType.video, openAnnotation));
  }

  void openAnnotation(Annotation annotation) {
    Locator locator = Locator.fromJsonString(annotation.location);
    controller.seekTo(Duration(seconds: locator.locations.timestamp));
  }
}
