// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mno_server/mno_server.dart';
import 'package:ui_commons/styles/default_sizes.dart';
import 'package:ui_framework/widgets/animations/animation_direction.dart';
import 'package:ui_framework/widgets/animations/collapsible_panel.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/document/widgets/close_document_button.dart';

class ReaderAppBar extends StatefulWidget {
  final ReaderContext readerContext;
  final ServerBloc serverBloc;

  const ReaderAppBar({
    Key key,
    this.readerContext,
    this.serverBloc,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReaderAppBarState();
}

class ReaderAppBarState extends State<ReaderAppBar> {
  static const double height = DefaultSizes.toolbarHeight;
  CollapsiblePanelController _collapsiblePanelController;
  StreamSubscription<bool> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _collapsiblePanelController = CollapsiblePanelController();
    _streamSubscription = widget.readerContext.toolbarStream.listen((visible) {
      _collapsiblePanelController.update(visible: visible);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
    _collapsiblePanelController?.dispose();
  }

  @override
  Widget build(BuildContext context) => CollapsiblePanel(
        controller: _collapsiblePanelController,
        direction: AnimationDirection.up,
        height: height * 2,
        child: CloseDocumentButton(
          background: Colors.white.withOpacity(0.9),
          color: Colors.grey.shade700,
          onPressed: () => widget.serverBloc.add(ShutdownServer()),
        ),
      );
}
