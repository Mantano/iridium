// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:model/blocs/documents/document_attachments_bloc.dart';
import 'package:model/blocs/documents/load_attachment_bloc.dart';
import 'package:model/document/document.dart';
import 'package:model/document/playable_document.dart';
import 'package:model/model.dart';
import 'package:ui_commons/blocs/fab_bloc.dart';
import 'package:ui_commons/document_opener/document_opener.dart';
import 'package:ui_commons/widgets/player/player_controller.dart';
import 'package:ui_framework/widgets/split_orientation_layout.dart';
import 'package:universal_io/io.dart';
import 'package:video_player/video_player.dart';
import 'package:navigator/src/document/ui/document_screen.dart';
import 'package:navigator/src/player/controller/audio_controller.dart';
import 'package:navigator/src/player/controller/video_controller.dart';
import 'package:navigator/src/player/listeners/player_key_action_listener.dart';
import 'package:navigator/src/player/ui/drawer/playable_reader_drawer.dart';
import 'package:navigator/src/player/widgets/companion_panel/player_companion_panel.dart';
import 'package:navigator/src/player/widgets/player_panel.dart';
import 'package:navigator/src/player/widgets/player_panel_controller.dart';

class PlayerScreen extends StatefulWidget {
  final PlayableDocument playableDocument;
  final bool simplifiedMode;
  final OnCloseDocument onCloseDocument;

  const PlayerScreen({
    Key key,
    @required this.playableDocument,
    this.simplifiedMode,
    this.onCloseDocument,
  })  : assert(playableDocument != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => PlayerScreenState();
}

class PlayerScreenState extends DocumentState<PlayerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  LoadAttachmentBloc _attachmentsBloc;
  FileDocumentsBloc _fileDocumentsBloc;
  PlayerController _controller;
  PlayerPanelController _playerPanelController;
  double _scale;

  StreamSubscription<AttachmentState> _attachmentsSubscription;

  @override
  Document get document => playableDocument;

  @override
  OnCloseDocument get onCloseDocument => widget.onCloseDocument;

  PlayableDocument get playableDocument => widget.playableDocument;

  bool get simplifiedMode => widget.simplifiedMode;

  @override
  void initState() {
    super.initState();
    _scale = 1.0;
    _attachmentsBloc = LoadAttachmentBloc();
    _fileDocumentsBloc = BlocProvider.of<FileDocumentsBloc>(context);
    _attachmentsSubscription = _attachmentsBloc.stream.listen((event) {
      if (_scaffoldKey.currentState != null &&
          _scaffoldKey.currentState.isEndDrawerOpen) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _attachmentsBloc?.close();
    _attachmentsSubscription?.cancel();
    if (_controller != null) {
      playableDocument.lastPosition =
          _controller.position.inMilliseconds.toDouble();
      _fileDocumentsBloc.documentRepository.save(playableDocument);
    }
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<PlayerController> loadVideoController() async {
    File file = File(playableDocument.absoluteFilepath);
    if (isVideo) {
      VideoPlayerController videoPlayerController =
          VideoPlayerController.file(file);
      await videoPlayerController.initialize();
      _controller = VideoController(videoPlayerController);
      _playerPanelController = PlayerPanelController(_controller, this);
    } else if (isAudio) {
      // Inform the operating system of our app's audio attributes etc.
      // We pick a reasonable default for an app that plays speech.
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      final _player = AudioPlayer();
      // Listen to errors during playback.
      _player.playbackEventStream.listen((event) {},
          onError: (Object e, StackTrace stackTrace) {
        Fimber.d('A stream error occurred', ex: e);
      });
      // Try to load audio from a source and catch any errors.
      try {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(file.path)));
        _controller = AudioController(_player);
        _playerPanelController = PlayerPanelController(_controller, this);
      } catch (e) {
        Fimber.d("Error loading audio source", ex: e);
      }
    }

    if (_controller != null && playableDocument.lastPosition != null) {
      _controller.seekTo(
          Duration(milliseconds: playableDocument.lastPosition.toInt()));
    }
    return _controller;
  }

  @override
  void deactivate() {
    super.deactivate();
    _playerPanelController?.deregisterListener();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (BuildContext context) => DocumentAttachmentsBloc(
                  _fileDocumentsBloc.fileDocumentRepository, document)),
          BlocProvider(create: (BuildContext context) => _attachmentsBloc),
          BlocProvider(create: (BuildContext context) => FabBloc()),
        ],
        child: FutureBuilder(
          future: loadVideoController(),
          builder:
              (BuildContext context, AsyncSnapshot<PlayerController> snapshot) {
            if (snapshot.hasData) {
              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                endDrawer: _buildReaderDrawer(),
                body: SafeArea(
                  top: !simplifiedMode,
                  child: buildVideoKeyActionListener(snapshot, context),
                ),
              );
            } else {
              return buildWaitingScreen(context);
            }
          },
        ),
      );

  Widget buildVideoKeyActionListener(
      AsyncSnapshot<PlayerController> snapshot, BuildContext context) {
    if (isVideo) {
      return VideoKeyActionListener(
        controller: (snapshot.data as VideoController).videoPlayerController,
        child: _buildVideoUi(context),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildVideoUi(BuildContext context) => SplitOrientationLayout(
        primaryWidget: Hero(
          tag: playableDocument.id,
          child: Container(
            constraints: BoxConstraints.loose(MediaQuery.of(context).size),
            child: AspectRatio(
              aspectRatio: _controller.aspectRatio,
              child: GestureDetector(
                onTap: _onTap,
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                child: Stack(
                  children: <Widget>[
                    buildPlayer(),
                    PlayerPanel(
                        _controller, _playerPanelController, playableDocument),
                  ],
                ),
              ),
            ),
          ),
        ),
        secondaryWidget: _buildCompanionPanel(context),
      );

  Widget buildPlayer() {
    if (isVideo) {
      return VideoPlayer(getVideoPlayerController());
    } else if (isAudio) {
      return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  VideoPlayerController getVideoPlayerController() {
    if (isVideo) {
      VideoController videoController = _controller as VideoController;
      return videoController.videoPlayerController;
    }
    return null;
  }

  Widget _buildReaderDrawer() {
    if (isVideo) {
      return PlayableReaderDrawer(
          playableDocument: playableDocument, controller: _controller);
    } else if (isAudio) {
      return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  bool get isVideo =>
      playableDocument.mimetypeCategory == MimetypeCategory.video;

  bool get isAudio =>
      playableDocument.mimetypeCategory == MimetypeCategory.audio;

  Widget _buildCompanionPanel(BuildContext context) {
    if (_playerPanelController?.fullScreen == false) {
      return PlayerCompanionPanel(
        playableDocument: playableDocument,
        playerControlPanelController: _playerPanelController,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _linkedDocumentArea(AttachmentState state) {
    if (state is LoadAttachmentState) {
      return ClipRect(
        key: ValueKey(state.document.id),
        child: FutureBuilder(
          future: DocumentOpener.findDocumentOpenerAndBuildScreen(
              state.document,
              simplifiedMode: true,
              onCloseDocument: (BuildContext context) =>
                  _attachmentsBloc.add(NoAttachmentEvent())),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) =>
              snapshot.hasData ? snapshot.data : const SizedBox.shrink(),
        ),
      );
    }
    return null;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) => _scale = details.scale;

  void _onScaleEnd(ScaleEndDetails details) {
    if (_scale > 1.5) {
      _playerPanelController?.fullScreen = true;
    } else if (_scale < 0.7) {
      _playerPanelController?.fullScreen = false;
    }
  }

  void _onTap() => _playerPanelController?.toggleControlsVisibility();
}
