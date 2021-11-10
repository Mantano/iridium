// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:model/document/playable_document.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/theme/default_colors.dart';
import 'package:ui_commons/widgets/player/player_controller.dart';
import 'package:ui_framework/styles/common_sizes.dart';
import 'package:ui_framework/widgets/update_states.dart';
import 'package:navigator/src/player/widgets/player_bookmark_button.dart';
import 'package:navigator/src/player/widgets/player_panel_controller.dart';

class PlayerMainButton extends StatefulWidget {
  final PlayerPanelController playerControlPanelController;
  final PlayerController playerController;
  final PlayableDocument playableDocument;

  const PlayerMainButton({
    Key key,
    this.playerControlPanelController,
    this.playerController,
    this.playableDocument,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainVideoButtonState();
}

class _MainVideoButtonState extends UpdateState<PlayerMainButton> {
  @override
  PlayerPanelController get updateStateController =>
      widget.playerControlPanelController;

  @override
  Widget build(BuildContext context) => Visibility(
        visible: updateStateController.controlsVisible,
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: SvgAssets.bookmark.widget(
                        height: CommonSizes.large5Margin,
                      ),
                    ),
                    InkWell(
                      onTap: togglePlay,
                      //customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          CommonSizes.small2Margin,
                        ),
                        child: getAsset(updateStateController.isPlaying).widget(
                          height: CommonSizes.large5Margin,
                          color: DefaultColors.videoControlsLabelColor,
                        ),
                      ),
                    ),
                    PlayerBookmarkButton(
                      playableDocument: widget.playableDocument,
                      playerPanelController:
                          widget.playerControlPanelController,
                      playerController: widget.playerController,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  void play() {
    Fimber.d("************ play from player main button");
    try {
      if (widget.playerController.ended) {
        widget.playerController.seekTo(Duration.zero);
      }
      widget.playerController.play();
      Future.delayed(PlayerController.hideControlsDuration, () {
        //asynchronous delay
        if (this.mounted) {
          Fimber.d("_playerPanelState.mounted");
          //checks if widget is still active and not disposed
          setState(() {
            //tells the widget builder to rebuild again because ui has updated
            widget.playerControlPanelController.controlsVisible =
                false; //update the variable declare this under your class so its accessible for both your widget build and initState which is located under widget build{}
            Fimber.d(
                "controlsVisible ${widget.playerControlPanelController.controlsVisible}");
          });
        }
      });
    } on Exception catch (e) {
      widget.playerController.pause();
      Fimber.e('video play error', ex: e);
    }
  }

  void togglePlay() {
    if (widget.playerController.isPlaying) {
      widget.playerController.pause();
    } else {
      play();
    }
    updateStates();
  }

  void updateStates() {
    updateStateController.updateStates();
  }

  SvgAssets getAsset(bool isPlaying) =>
      isPlaying ? SvgAssets.playerPause : SvgAssets.playerPlay;
}
