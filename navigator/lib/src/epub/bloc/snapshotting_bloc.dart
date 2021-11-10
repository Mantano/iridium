// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mno_commons/utils/file_utils.dart';
import 'package:mno_shared/publication.dart';
import 'package:model/book/book.dart';
import 'package:model/css/reader_theme.dart';
import 'package:universal_io/io.dart';
import 'package:utils/io/folder_settings.dart';
import 'package:navigator/src/book/ui/reader_context.dart';
import 'package:navigator/src/epub/bloc/snapshotting_info.dart';
import 'package:navigator/src/epub/bloc/thumbnails/snapshotting_thumbnails_generator.dart';
import 'package:navigator/src/epub/settings/viewer_settings.dart';
import 'package:navigator/src/epub/ui/epub_thumbnails_page_mapping.dart';

class SnapshottingBloc extends Bloc<SnapshottingEvent, SnapshottingState> {
  final ReaderContext readerContext;
  int requestId = 0;
  EpubThumbnailsPageMapping _epubThumbnailsPageMapping;

  SnapshottingBloc(
    this.readerContext,
  ) : super(InitialThumbnailsState()) {
    on<InitSnapshotEvent>(_onInitSnapshotEvent);
    on<SnapshottingStopEvent>(_onSnapshottingStopEvent);
    on<SnapshottingEndedEvent>(_onSnapshottingEndedEvent);
  }

  set epubThumbnailsPageMapping(EpubThumbnailsPageMapping value) =>
      _epubThumbnailsPageMapping = value;

  Book get book => readerContext.book;

  String get cachePath => FolderSettings.instance.cachePath;

  String get thumbnailsPath => '$cachePath/${book.id}';

  String get configPath => '$thumbnailsPath/thumbnails.json';

  Future<void> _onInitSnapshotEvent(
      InitSnapshotEvent event, Emitter<SnapshottingState> emit) async {
    await FileUtils.ensureFolderExists(thumbnailsPath);
    File configFile = File(configPath);
    if (await configFile.exists()) {
      String data = await configFile.readAsString();
      Map<String, Object> json = const JsonCodec().decode(data);
      SnapshottingInfo snapshottingInfo = SnapshottingInfo.fromJson(json);
      bool matching = snapshottingInfo.matchConditions(
          event.width.ceil(),
          event.height.ceil(),
          event.viewerSettings.fontSize,
          event.readerTheme);
      if (matching) {
        _epubThumbnailsPageMapping.displayThumbnailsController.add(true);
        emit(ThumbnailsState(snapshottingInfo));
        return;
      }
    }
    await FileUtils.emptyDirectory(thumbnailsPath, recursive: true);
    _epubThumbnailsPageMapping.displayThumbnailsController.add(false);
    requestId++;
    _generateThumbnails(event);
    emit(EmptyThumbnailsState(requestId));
  }

  Future<void> _onSnapshottingStopEvent(
      SnapshottingStopEvent event, Emitter<SnapshottingState> emit) async {
    await FileUtils.ensureFolderExists(thumbnailsPath);
    requestId++;
    emit(EmptyThumbnailsState(requestId));
  }

  Future<void> _onSnapshottingEndedEvent(
      SnapshottingEndedEvent event, Emitter<SnapshottingState> emit) async {
    await FileUtils.ensureFolderExists(thumbnailsPath);
    File configFile = File(configPath);
    String json = const JsonCodec().encode(event.snapshottingInfo.toJson());
    await configFile.writeAsString(json);
    _epubThumbnailsPageMapping.displayThumbnailsController.add(true);
    emit(ThumbnailsState(event.snapshottingInfo));
  }

  void _generateThumbnails(InitSnapshotEvent event) {
    ThumbnailsGeneratorConfig config = ThumbnailsGeneratorConfig(
        snapshottingBloc: this,
        readerContext: readerContext,
        address: event.address,
        requestId: requestId,
        width: event.width,
        height: event.height,
        readerTheme: event.readerTheme,
        viewerSettings: event.viewerSettings);
    SnapshottingThumbnailsGenerator generator =
        SnapshottingThumbnailsGenerator(config);
    generator.generateThumbnails();
  }
}

@immutable
abstract class SnapshottingEvent extends Equatable {}

class InitSnapshotEvent extends SnapshottingEvent {
  final Publication publication;
  final String address;
  final int width;
  final int height;
  final ReaderTheme readerTheme;
  final ViewerSettings viewerSettings;

  InitSnapshotEvent(
      [this.publication,
      this.address,
      this.width,
      this.height,
      this.readerTheme,
      this.viewerSettings]);

  @override
  List<Object> get props =>
      [publication, address, width, height, readerTheme, viewerSettings];

  @override
  String toString() => 'InitSnapshotEvent{'
      'publication: $publication, '
      'address: $address, '
      'width: $width, '
      'height: $height, '
      'readerTheme: $readerTheme, '
      'viewerSettings: $viewerSettings}';
}

class SnapshottingStopEvent extends SnapshottingEvent {
  @override
  List<Object> get props => [];
}

class SnapshottingEndedEvent extends SnapshottingEvent {
  final SnapshottingInfo snapshottingInfo;

  SnapshottingEndedEvent(this.snapshottingInfo);

  @override
  List<Object> get props => [snapshottingInfo];

  @override
  String toString() =>
      'SnapshottingEndedEvent{snapshottingInfo: $snapshottingInfo}';
}

@immutable
abstract class SnapshottingState extends Equatable {}

class InitialThumbnailsState extends SnapshottingState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'InitialThumbnailsState {}';
}

class EmptyThumbnailsState extends SnapshottingState {
  final int requestId;

  EmptyThumbnailsState([this.requestId]);

  @override
  List<Object> get props => [requestId];

  @override
  String toString() => 'EmptyThumbnailsState{requestId: $requestId}';
}

class ThumbnailsState extends SnapshottingState {
  final SnapshottingInfo snapshottingInfo;

  ThumbnailsState([this.snapshottingInfo]);

  @override
  List<Object> get props => [snapshottingInfo];

  @override
  String toString() => 'ThumbnailsState{snapshottingInfo: $snapshottingInfo}';
}
