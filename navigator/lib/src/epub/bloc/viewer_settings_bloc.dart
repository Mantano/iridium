// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:navigator/src/epub/model/epub_reader_state.dart';
import 'package:navigator/src/epub/settings/viewer_settings.dart';

class ViewerSettingsBloc
    extends Bloc<ViewerSettingsEvent, ViewerSettingsState> {
  ViewerSettingsBloc(EpubReaderState _readerState)
      : super(ViewerSettingsState(
            ViewerSettings.defaultSettings(fontSize: _readerState.fontSize))) {
    on<IncrFontSizeEvent>((event, emit) =>
        emit(ViewerSettingsState(state.viewerSettings.incrFontSize())));
    on<DecrFontSizeEvent>((event, emit) =>
        emit(ViewerSettingsState(state.viewerSettings.decrFontSize())));
  }

  ViewerSettings get viewerSettings => state.viewerSettings;
}

@immutable
abstract class ViewerSettingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class IncrFontSizeEvent extends ViewerSettingsEvent {
  @override
  String toString() => 'IncrFontSizeEvent {}';
}

class DecrFontSizeEvent extends ViewerSettingsEvent {
  @override
  String toString() => 'DecrFontSizeEvent {}';
}

@immutable
class ViewerSettingsState extends Equatable {
  final ViewerSettings viewerSettings;

  const ViewerSettingsState([this.viewerSettings]);

  @override
  List<Object> get props => [viewerSettings];

  @override
  String toString() =>
      'ViewerSettingsState { viewerSettings: $viewerSettings }';
}
