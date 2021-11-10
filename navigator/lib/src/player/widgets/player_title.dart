// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:ui_commons/styles/default_font_sizes.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_framework/widgets/update_states.dart';
import 'package:navigator/src/player/widgets/player_colors.dart';
import 'package:navigator/src/player/widgets/player_panel_controller.dart';

class PlayerTitle extends StatefulWidget {
  final PlayerPanelController _playableControlPanelController;
  final String _title;

  const PlayerTitle(this._playableControlPanelController, this._title,
      {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerTitleState();
}

class _PlayerTitleState extends UpdateState<PlayerTitle> {
  @override
  UpdateStateController get updateStateController =>
      widget._playableControlPanelController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity:
            widget._playableControlPanelController.titleVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: const BoxDecoration(
            color: playerButtonBackgroundDark,
          ),
          child: Text(
            widget._title,
            maxLines: 1,
            style: Theme.of(context).textTheme.button.copyWith(
                  color: DefaultColors.videoControlsLabelColor,
                  fontSize: DefaultFontSizes.videoPlayerVideoTitle,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.0,
                ),
          ),
        ),
      );
}
