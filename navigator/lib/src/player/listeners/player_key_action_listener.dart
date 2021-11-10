// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:navigator/src/document/listeners/key_mapping.dart';
import 'package:navigator/src/document/listeners/reader_action.dart';
import 'package:navigator/src/player/listeners/keyboard_player_key_mapping.dart';
import 'package:navigator/src/player/listeners/vidami_player_key_mapping.dart';

class VideoPlayerContext {
  static const List<double> possibleSpeeds = [1.0, 0.75, 0.5, 0.35, 0.2];
  static const Duration jumpDuration = Duration(seconds: 5);
  final VideoPlayerController controller;
  final LoopContext loopContext;
  int speedIndex;

  VideoPlayerContext(this.controller)
      : this.speedIndex = 0,
        this.loopContext = LoopContext(controller);

  void onAction(ReaderAction action) {
    VideoPlayerValue videoPlayerValue = controller.value;
    switch (action) {
      case ReaderAction.speed:
        speedIndex = (speedIndex + 1) % (possibleSpeeds.length);
        controller.setPlaybackSpeed(possibleSpeeds[speedIndex]);
        break;
      case ReaderAction.loop:
        loopContext.onLoop();
        break;
      case ReaderAction.back:
        Duration position = videoPlayerValue.position - jumpDuration;
        controller.seekTo(position);
        break;
      case ReaderAction.play:
        if (videoPlayerValue.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
        break;
      case ReaderAction.forward:
        Duration position = videoPlayerValue.position + jumpDuration;
        controller.seekTo(position);
        break;
      default:
    }
  }
}

class LoopContext {
  final VideoPlayerController controller;
  Duration start;
  Duration end;
  VoidCallback listener;

  LoopContext(this.controller);

  void onLoop() {
    if (start == null) {
      start = controller.value.position;
    } else if (end == null) {
      end = controller.value.position;
      listener = _onPositionChanged;
      controller.addListener(listener);
    } else {
      start = null;
      end = null;
      listener = null;
    }
  }

  void _onPositionChanged() {
    VideoPlayerValue value = controller.value;
    if (value.isPlaying && value.position > end) {
      controller.seekTo(start);
    }
  }
}

class VideoKeyActionListener extends StatelessWidget {
  final VideoPlayerController controller;
  final Widget child;
  final List<KeyMapping> _videoKeyMappings = const [
    VidamiPlayerKeyMapping(),
    KeyboardPlayerKeyMapping()
  ];
  final VideoPlayerContext _videoPlayerContext;

  VideoKeyActionListener({
    Key key,
    this.controller,
    this.child,
  })  : _videoPlayerContext = VideoPlayerContext(controller),
        super(key: key);

  @override
  Widget build(BuildContext context) => RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: _onKey,
        child: child,
      );

  void _onKey(RawKeyEvent keyEvent) {
    Fimber.d('keyEvent: ${keyEvent.character}');
    String character = keyEvent.character;
    if (character != null) {
      ReaderAction readerAction = _matchKey(character);
      Fimber.d('readerAction: $readerAction');
      _videoPlayerContext.onAction(readerAction);
    }
  }

  ReaderAction _matchKey(String character) {
    for (KeyMapping keyMapping in _videoKeyMappings) {
      ReaderAction readerAction = keyMapping.matchKey(character);
      if (readerAction != ReaderAction.none) {
        return readerAction;
      }
    }
    return ReaderAction.none;
  }
}
