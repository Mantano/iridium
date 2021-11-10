// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:core';

import 'package:flutter/material.dart';
import 'package:ui_commons/widgets/player/player_controller.dart';
import 'package:video_player/video_player.dart';

class VideoController extends PlayerController {
  final VideoPlayerController videoPlayerController;

  VideoController(this.videoPlayerController);

  VideoPlayerValue get value => videoPlayerController.value;

  @override
  void seekTo(Duration duration) {
    videoPlayerController.seekTo(duration);
  }

  @override
  void play() {
    videoPlayerController.play();
  }

  @override
  void pause() {
    videoPlayerController.pause();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    videoPlayerController.addListener(listener);
  }

  @override
  void removeListener(Function listener) {
    videoPlayerController.removeListener(listener);
  }

  @override
  bool get isPlaying => value.isPlaying;

  @override
  bool get ended =>
      value != null && value.duration - value.position == Duration.zero;

  @override
  Duration get position => value.position;

  @override
  Duration get duration => value.duration;

  @override
  double get aspectRatio => value.aspectRatio;
}
