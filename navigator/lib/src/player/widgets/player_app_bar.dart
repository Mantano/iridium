// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:model/document/playable_document.dart';
import 'package:ui_commons/styles/default_sizes.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_framework/widgets/animations/animation_direction.dart';
import 'package:ui_framework/widgets/animations/collapsible_panel.dart';
import 'package:navigator/src/document/widgets/close_document_button.dart';
import 'package:navigator/src/player/widgets/player_panel_controller.dart';
import 'package:navigator/src/player/widgets/player_title.dart';

class PlayerAppBar extends StatefulWidget {
  final PlayableDocument playableDocument;

  final PlayerPanelController playerPanelController;

  const PlayerAppBar({
    Key key,
    this.playerPanelController,
    this.playableDocument,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlayerAppBarState();
}

class PlayerAppBarState extends State<PlayerAppBar> {
  static const double height = DefaultSizes.toolbarHeight;
  CollapsiblePanelController _collapsiblePanelController;
  StreamSubscription<bool> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _collapsiblePanelController = CollapsiblePanelController();
    widget.playerPanelController.controlsVisibleStream.listen((visible) {
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
        child: Row(
          children: [
            CloseDocumentButton(
              background: DefaultColors.blackTransp5,
              color: Colors.white,
              onPressed: () => _onClose(),
            ),
            const Spacer(),
            PlayerTitle(widget.playerPanelController,
                widget.playableDocument.title.toUpperCase()),
//            const Spacer(),
//            PlayerBookmarkButton(
//              playableDocument: widget.video,
//              videoControlPanelController: widget.videoControlPanelController,
//              videoPlayerController: widget.videoPlayerController,
//            ),
          ],
        ),
      );

  void _onClose() {
    dispose();
    Navigator.pop(context);
  }
}
