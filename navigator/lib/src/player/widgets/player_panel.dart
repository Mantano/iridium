// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';
import 'package:model/document/playable_document.dart';
import 'package:model/model.dart';
import 'package:ui_commons/assets/svg_assets.dart';
import 'package:ui_commons/widgets/player/player_controller.dart';
import 'package:ui_framework/widgets/update_states.dart';
import 'package:video_player/video_player.dart';
import 'package:navigator/src/player/controller/video_controller.dart';
import 'package:navigator/src/player/widgets/duration_title.dart';
import 'package:navigator/src/player/widgets/player_app_bar.dart';
import 'package:navigator/src/player/widgets/player_button.dart';
import 'package:navigator/src/player/widgets/player_colors.dart';
import 'package:navigator/src/player/widgets/player_main_button.dart';
import 'package:navigator/src/player/widgets/player_panel_controller.dart';

class PlayerPanel extends StatefulWidget {
  final PlayerController _playerController;
  final PlayerPanelController _playerPanelController;
  final PlayableDocument _playableDocument;

  const PlayerPanel(this._playerController, this._playerPanelController,
      this._playableDocument,
      {Key key})
      : assert(_playerController != null),
        assert(_playerPanelController != null),
        assert(_playableDocument != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => PlayerPanelState();
}

class PlayerPanelState extends UpdateState<PlayerPanel> {
  PlayerController get _playerController => widget._playerController;

  PlayerPanelController get _playerPanelController =>
      widget._playerPanelController;

  PlayableDocument get _playableDocument => widget._playableDocument;

  @override
  UpdateStateController get updateStateController => _playerPanelController;

  @override
  void initState() {
    super.initState();
    _playerPanelController.registerControlPaneState(this);
  }

  @override
  void deactivate() {
    super.deactivate();
    _playerPanelController.deregisterControlPaneState();
  }

  void _onTapFullScreen() {
    _playerPanelController.toggleFullScreen();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          PlayerAppBar(
              playableDocument: _playableDocument,
              playerPanelController: _playerPanelController),
          Expanded(
            flex: 1,
            child: Center(
              child: PlayerMainButton(
                playerControlPanelController: _playerPanelController,
                playerController: _playerController,
                playableDocument: _playableDocument,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_playerPanelController.controlsVisible,
            child: AnimatedOpacity(
              opacity: _playerPanelController.controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Material(
                elevation: 20,
                child: Container(
                  decoration: const BoxDecoration(
                    color: fullscreenBackground,
                  ),
                  height: 46.0,
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          DurationTitle(
                            updateStateController: _playerPanelController,
                            duration: _playerController.position,
                          ),
                          const SizedBox(width: 6.0),
                          Expanded(
                            child: buildPlayableProgressIndicator(),
                          ),
                          const SizedBox(width: 6.0),
                          DurationTitle(
                            updateStateController: _playerPanelController,
                            duration: _playerController.duration -
                                _playerController.position,
                          ),
                          PlayerButton(
                            svgAsset: SvgAssets.playOnBg,
                            onPressed: _onTapFullScreen,
                          ),
                          PlayerButton(
                            svgAsset: _playerPanelController.fullScreen
                                ? SvgAssets.playerStandardScreen
                                : SvgAssets.playerFullScreen,
                            onPressed: _onTapFullScreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Color get _buttonsBgColor =>
      _playableDocument.coverPaletteColors.dominantColor ??
      fullscreenBackground;

  Widget buildPlayableProgressIndicator() {
    if (_playableDocument.mimetypeCategory == MimetypeCategory.video) {
      return buildVideoProgressIndicator();
    } else if (_playableDocument.mimetypeCategory == MimetypeCategory.audio) {
      //return buildAudioProgressIndicator();
      return const SizedBox.shrink();
    } else {
      return const SizedBox.shrink();
    }
  }

  VideoProgressIndicator buildVideoProgressIndicator() {
    VideoController videoController = _playerController as VideoController;
    return VideoProgressIndicator(
      videoController.videoPlayerController,
      padding: const EdgeInsets.symmetric(vertical: 11.5),
      allowScrubbing: true,
      colors: const VideoProgressColors(
        backgroundColor: playerProgressBackground,
        playedColor: playerProgressPlayed,
      ),
    );
  }

// Widget buildAudioProgressIndicator() {
//   AudioController audioController = _playerController as AudioController;
//   return ProgressBar(
//     progress: audioController.position,
//     buffered: audioController.position,
//     total: audioController.duration,
//     onSeek: (duration) {
//       audioController.seekTo(duration);
//     },
//     onDragUpdate: (details) {
//       debugPrint('${details.timeStamp}, ${details.localPosition}');
//     },
//     barHeight: 40,
//     // baseBarColor: _baseBarColor,
//     // progressBarColor: _progressBarColor,
//     // bufferedBarColor: _bufferedBarColor,
//     // thumbColor: _thumbColor,
//     // thumbGlowColor: _thumbGlowColor,
//     // barCapShape: _barCapShape,
//     // thumbRadius: _thumbRadius,
//     // thumbCanPaintOutsideBar: _thumbCanPaintOutsideBar,
//     // timeLabelLocation: _labelLocation,
//     // timeLabelType: _labelType,
//     // timeLabelTextStyle: _labelStyle,
//     // timeLabelPadding: _labelPadding,
//   );
// }
}
