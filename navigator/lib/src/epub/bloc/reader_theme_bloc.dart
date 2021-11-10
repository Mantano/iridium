// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:model/css/reader_theme.dart';

class ReaderThemeBloc extends Bloc<ReaderThemeEvent, ReaderThemeState> {
  final ReaderTheme defaultTheme;

  ReaderThemeBloc(this.defaultTheme)
      : super(ReaderThemeState(defaultTheme ?? ReaderTheme.defaultTheme)) {
    on<ReaderThemeEvent>(
        (event, emit) => ReaderThemeState(event.readerTheme.clone()));
  }

  ReaderTheme get currentTheme => state.readerTheme;
}

@immutable
class ReaderThemeEvent extends Equatable {
  final ReaderTheme readerTheme;

  const ReaderThemeEvent([this.readerTheme]);

  @override
  List<Object> get props => [readerTheme];

  @override
  String toString() => 'ReaderThemeEvent { readerTheme: $readerTheme }';
}

@immutable
class ReaderThemeState extends Equatable {
  final ReaderTheme readerTheme;

  const ReaderThemeState([this.readerTheme]);

  @override
  List<Object> get props => [readerTheme];

  @override
  String toString() => 'ReaderThemeState { readerTheme: $readerTheme }';
}
