// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/bookari_localizations.dart';
import 'package:mno_shared/mediatype.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/annotation/annotation_kind_and_document_and_position_predicate.dart';
import 'package:model/document/cloud_file.dart';
import 'package:model/model.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/theme_bloc.dart';
import 'package:ui_commons/widgets/player/player_controller.dart';
import 'package:ui_commons/widgets/sliding_up_panel/notify_sliding_popup.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:utils/extensions/duration_format.dart';
import 'package:navigator/src/player/widgets/player_panel_controller.dart';

class PlayerBookmarkButton extends StatelessWidget {
  final FileDocument playableDocument;
  final PlayerController playerController;
  final PlayerPanelController playerPanelController;

  const PlayerBookmarkButton({
    Key key,
    this.playerPanelController,
    this.playableDocument,
    this.playerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: (_bookmarkVisible) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: InkWell(
          onTap: () => _onBookmarkPressed(context),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: SvgAssets.bookmark.widget(
              height: CommonSizes.small1IconSize,
            ),
          ),
        ),
      );

  bool get _bookmarkVisible =>
      !playerPanelController.isPlaying && playerPanelController.controlsVisible;

  Future<bool> isDuplicate(AnnotationsBloc annotationsBloc) async {
    Duration position = playerController.position;
    Future<int> count = annotationsBloc.documentRepository.countAllWhere(
        predicate: AnnotationKindAndDocumentAndPositionPredicate(
            position.inSeconds, playableDocument.id, AnnotationKind.bookmark));
    return await count > 0 ? true : false;
  }

  void _onBookmarkPressed(BuildContext context) async {
    AnnotationsBloc annotationsBloc = BlocProvider.of<AnnotationsBloc>(context);
    bool duplicate = await isDuplicate(annotationsBloc);
    if (!duplicate) {
      Duration position = playerController.position;
      Duration duration = playerController.duration;
      double progression = position.inMilliseconds / duration.inMilliseconds;
      CloudFile coverFile;
      MediaType.ofFilePath(playableDocument.fileName).then((mediaType) {
        Locations location = Locations(
            progression: progression,
            totalProgression: progression,
            fragments: ["t=${position.inSeconds}"]);
        Locator locator = Locator(
            href: playableDocument.fileName,
            type: mediaType.fileExtension,
            title: position.print(),
            locations: location);
        Annotation annotation = Annotation.bookmark(
            "", playableDocument.id, locator.json, 0, coverFile);

        annotationsBloc.documentRepository.add(annotation);
        return true;
      });
    } else {
      _displayDuplicateMessage(context);
    }
  }

  void _displayDuplicateMessage(BuildContext context) {
    ThemeBloc themeBloc = BlocProvider.of<ThemeBloc>(context);
    String text = BookariLocalizations.of(context).duplicatedBookmark;
    NotifySlidingPopup.showSlidingPopup(
      context,
      themeBloc.currentTheme,
      text,
      text,
    );
  }
}
