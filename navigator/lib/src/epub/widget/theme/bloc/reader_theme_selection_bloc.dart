// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:model/css/reader_theme.dart';

class ReaderThemeSelectionBloc
    extends Bloc<ReaderThemeSelectionEvent, ReaderThemeSelectionState> {
  ReaderThemeSelectionBloc(ReaderTheme defaultTheme)
      : super(ReaderThemeSelectedState(defaultTheme)) {
    on<ReaderThemeSelectedEvent>(
        (event, emit) => ReaderThemeSelectedState(event.readerTheme.clone()));
    on<ReaderThemeEditionEvent>((event, emit) => ReaderThemeEditionState(
        event.readerTheme.clone(), event.readerThemeToEdit.clone()));
  }

  ReaderTheme get currentTheme => state.readerTheme;
}

@immutable
abstract class ReaderThemeSelectionEvent extends Equatable {}

@immutable
class ReaderThemeSelectedEvent extends ReaderThemeSelectionEvent {
  final ReaderTheme readerTheme;

  ReaderThemeSelectedEvent([this.readerTheme]);

  @override
  List<Object> get props => [readerTheme];

  @override
  String toString() => 'ReaderThemeSelectedEvent { readerTheme: $readerTheme }';
}

@immutable
class ReaderThemeEditionEvent extends ReaderThemeSelectionEvent {
  final ReaderTheme readerTheme;
  final ReaderTheme readerThemeToEdit;

  ReaderThemeEditionEvent([this.readerTheme, this.readerThemeToEdit]);

  @override
  List<Object> get props => [readerTheme, readerThemeToEdit];

  @override
  String toString() =>
      'ReaderThemeEditionEvent { readerTheme: $readerTheme, readerThemeToEdit: $readerThemeToEdit }';
}

@immutable
abstract class ReaderThemeSelectionState extends Equatable {
  ReaderTheme get readerTheme;
}

@immutable
class ReaderThemeSelectedState extends ReaderThemeSelectionState {
  @override
  final ReaderTheme readerTheme;

  ReaderThemeSelectedState([this.readerTheme]);

  @override
  List<Object> get props => [readerTheme];

  @override
  String toString() =>
      'ReaderThemeSelectionState { readerTheme: $readerTheme }';
}

@immutable
class ReaderThemeEditionState extends ReaderThemeSelectionState {
  @override
  final ReaderTheme readerTheme;
  final ReaderTheme readerThemeToEdit;

  ReaderThemeEditionState([this.readerTheme, this.readerThemeToEdit]);

  @override
  List<Object> get props => [readerTheme, readerThemeToEdit];

  @override
  String toString() =>
      'ReaderThemeSelectionState { readerTheme: $readerTheme, readerThemeToEdit: $readerThemeToEdit }';
}
