// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:core';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ui_commons/widgets/player/player_controller.dart';

class AudioController extends PlayerController {
  final AudioPlayer audioPlayer;

  AudioController(this.audioPlayer);

  @override
  void seekTo(Duration duration) {
    audioPlayer.seek(duration);
  }

  @override
  void play() {
    audioPlayer.play();
  }

  @override
  void pause() {
    audioPlayer.pause();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
  }

  @override
  void addListener(VoidCallback listener) {
    //audioPlayer.playerStateStream.addListener(listener);
  }

  @override
  void removeListener(Function listener) {
    //videoPlayerController.removeListener(listener);
  }

  @override
  bool get isPlaying => audioPlayer.playing;

  @override
  bool get ended =>
      audioPlayer.duration - audioPlayer.position == Duration.zero;

  @override
  Duration get position => audioPlayer.position;

  @override
  Duration get duration => audioPlayer.duration;

  @override
  double get aspectRatio => 1.2;
}
