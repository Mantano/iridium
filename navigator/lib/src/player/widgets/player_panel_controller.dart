// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_commons/widgets/player/player_controller.dart';
import 'package:ui_framework/widgets/update_states.dart';
import 'package:navigator/src/player/ui/player_screen.dart';
import 'package:navigator/src/player/widgets/player_colors.dart';
import 'package:navigator/src/player/widgets/player_panel.dart';

class PlayerPanelController extends UpdateStateController {
  final PlayerController _controller;
  final PlayerScreenState _playerScreenState;
  StreamController<bool> _controlsVisibilityController;
  VoidCallback _listener;
  bool _controlsVisible = false;
  bool _titleVisible = true;
  bool isPlaying = false;
  bool _fullScreen = false;
  PlayerPanelState _playerPanelState;

  PlayerPanelController(this._controller, this._playerScreenState) {
    _controlsVisibilityController = StreamController.broadcast();
    _titleVisible = _fullScreen;
    _listener = () {
      isPlaying = _controller.isPlaying;
      _titleVisible = fullScreen && !_controller.isPlaying;
      updateStates();
    };
    _controller.addListener(_listener);
  }

  Stream<bool> get controlsVisibleStream =>
      _controlsVisibilityController.stream;

  Color get fullScreenBackgroundColor =>
      fullScreen ? fullscreenBackground : fullscreenTransparentBackground;

  void deregisterListener() {
    _controller.removeListener(_listener);
    _controlsVisibilityController.close();
  }

  bool get controlsVisible => _controlsVisible;

  set controlsVisible(bool controlsVisible) {
    if (_controlsVisible != controlsVisible) {
      _controlsVisibilityController.add(controlsVisible);
      _playerPanelState?.updateState();
    }
    _controlsVisible = controlsVisible;
  }

  void toggleControlsVisibility() {
    controlsVisible = !controlsVisible;
  }

  bool get fullScreen => _fullScreen;

  set fullScreen(bool fullScreen) {
    if (_fullScreen != fullScreen) {
      if (fullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
      _playerScreenState.updateState();
    }
    _fullScreen = fullScreen;
  }

  void toggleFullScreen() {
    fullScreen = !fullScreen;
  }

  bool get titleVisible => _titleVisible;

  set titleVisible(bool titleVisible) {
    if (_titleVisible != titleVisible) {
      _playerPanelState?.updateState();
    }
    _titleVisible = titleVisible;
  }

  void registerControlPaneState(PlayerPanelState _playerPaneState) =>
      this._playerPanelState = _playerPaneState;

  void deregisterControlPaneState() {
    _playerPanelState = null;
  }

  void play() {
    Fimber.d("**player panel controller*****************play");
    try {
      if (_controller.ended) {
        _controller.seekTo(Duration.zero);
      }
      _controller.play();

      Future.delayed(PlayerController.hideControlsDuration, () {
        //asynchronous delay
        if (_playerPanelState.mounted) {
          Fimber.d("_playerPanelState.mounted");
          //checks if widget is still active and not disposed
          _playerPanelState.updateState(() {
            //tells the widget builder to rebuild again because ui has updated
            _controlsVisible =
                false; //update the variable declare this under your class so its accessible for both your widget build and initState which is located under widget build{}
            Fimber.d("_controlsVisible $_controlsVisible");
          });
        } else {
          Fimber.d("WARNING _playerPanelState.mounted");
        }
      });
    } on Exception catch (e) {
      _controller.pause();
      Fimber.d('video play error', ex: e);
    }
  }

  void togglePlay() {
    if (isPlaying) {
      _controller.pause();
    } else {
      play();
    }
  }

  void seekTo(Duration duration) => _controller.seekTo(duration);
}
