// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model/annotation/annotation_playable.dart';
import 'package:model/document/playable_document.dart';
import 'package:model/model.dart';
import 'package:ui_commons/styles/default_sizes.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_commons/widgets/document_info/actions/action_name.dart';
import 'package:ui_commons/widgets/document_info/document_expandable_fab.dart';
import 'package:ui_commons/widgets/document_info/document_rating_bar.dart';
import 'package:ui_commons/widgets/gallery/attachments_gallery.dart';
import 'package:ui_commons/widgets/gallery/bookmarks_gallery.dart';
import 'package:ui_framework/styles/common_radius.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:navigator/src/player/widgets/companion_panel/player_companion_title.dart';
import 'package:navigator/src/player/widgets/player_panel_controller.dart';

class PlayerCompanionPanel extends StatefulWidget {
  final PlayableDocument playableDocument;
  final PlayerPanelController playerControlPanelController;

  const PlayerCompanionPanel(
      {Key key, this.playableDocument, this.playerControlPanelController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PlayerCompanionPanelState();
}

class PlayerCompanionPanelState extends State<PlayerCompanionPanel> {
  static const double _listHeight = 210.0;

  FileDocumentsBloc get fileDocumentsBloc =>
      BlocProvider.of<FileDocumentsBloc>(context);

  PlayerPanelController get playerControlPanelController =>
      widget.playerControlPanelController;

  Color get dominantColor =>
      widget.playableDocument?.coverPaletteColors?.dominantColor;

  ThemeBloc get themeBloc => BlocProvider.of<ThemeBloc>(context);

  @override
  Widget build(BuildContext context) => Scaffold(
      floatingActionButton: _buildBottomFAB(),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: FractionalOffset.topRight,
              end: FractionalOffset.bottomLeft,
              colors: [
                widget.playableDocument?.coverPaletteColors?.dominantColor,
                widget.playableDocument.coverPaletteColors.getPrimaryColor(true)
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(CommonRadius.panelOneSideRadius)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: ListView(
              children: <Widget>[
                DocumentRatingBar(
                  fileDocumentsBloc: fileDocumentsBloc,
                  document: widget.playableDocument,
                  circleSize: DefaultSizes.smallRatingRound,
                  emptyColor: DefaultColors.ratingPlainEmptyColorPlayer,
                  padding: const EdgeInsets.fromLTRB(CommonSizes.large2Margin,
                      40, CommonSizes.large2Margin, 0),
                ),
                PlayerCompanionTitle(
                    playableDocument: widget.playableDocument,
                    padding: const EdgeInsets.fromLTRB(CommonSizes.large2Margin,
                        10, CommonSizes.large2Margin, 0)),
                BookmarksGallery(
                  height: _listHeight,
                  document: widget.playableDocument,
                  onAnnotationTap: _onAnnotationTap,
                ),
                AttachmentsGallery(
                  height: _listHeight,
                  document: widget.playableDocument,
                ),
              ],
            ),
          ),
        ),
      ));

  Widget _buildBottomFAB() => DocumentExpandableFab(
        key: widget.key,
        document: widget.playableDocument,
        actionsToHide: const [ActionName.open],
      );

  void _onAnnotationTap(Annotation annotation) {
    playerControlPanelController
        .seekTo(Duration(seconds: annotation.positionInSec));
  }
}
