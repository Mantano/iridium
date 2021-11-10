// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:model/css/reader_theme.dart';
import 'package:model/css/reader_theme_repository.dart';

class ReaderThemeListBloc
    extends Bloc<ReaderThemeListEvent, ReaderThemeListState> {
  final ReaderThemeRepository readerThemeRepository;

  ReaderThemeListBloc({this.readerThemeRepository})
      : super(const ReaderThemeListState([])) {
    on<ReaderThemeLoadEvent>(_onReaderThemeLoadEvent);
    on<ReaderThemeSaveEvent>(_onReaderThemeSaveEvent);
    on<ReaderThemeDeleteEvent>(_onReaderThemeDeleteEvent);
  }

  Future<void> _onReaderThemeLoadEvent(ReaderThemeLoadEvent event,
          Emitter<ReaderThemeListState> emit) async =>
      _loadReaderThemes(emit);

  Future<void> _loadReaderThemes(Emitter<ReaderThemeListState> emit) async {
    // List<ReaderTheme> themes = await readerThemeRepository.all().first;
    // if (themes.isEmpty) {
    //   Iterable<Future> futures =
    //       ReaderTheme.defaultThemes.map(readerThemeRepository.save);
    //   await Future.wait(futures);
    //   themes = await readerThemeRepository.all().first;
    // }
    List<ReaderTheme> themes = [];
    emit(ReaderThemeListState(themes));
  }

  Future<void> _onReaderThemeSaveEvent(
      ReaderThemeSaveEvent event, Emitter<ReaderThemeListState> emit) async {
    await readerThemeRepository.save(event.readerTheme);
    _loadReaderThemes(emit);
  }

  Future<void> _onReaderThemeDeleteEvent(
      ReaderThemeDeleteEvent event, Emitter<ReaderThemeListState> emit) async {
    await readerThemeRepository.delete([event.readerTheme.id]);
    _loadReaderThemes(emit);
  }
}

@immutable
abstract class ReaderThemeListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

@immutable
class ReaderThemeLoadEvent extends ReaderThemeListEvent {
  @override
  String toString() => 'ReaderThemeLoadEvent {}';
}

@immutable
class ReaderThemeSaveEvent extends ReaderThemeListEvent {
  final ReaderTheme readerTheme;

  ReaderThemeSaveEvent(this.readerTheme);

  @override
  List<Object> get props => [readerTheme];

  @override
  String toString() => 'ReaderThemeSaveEvent { readerTheme: $readerTheme }';
}

@immutable
class ReaderThemeDeleteEvent extends ReaderThemeListEvent {
  final ReaderTheme readerTheme;

  ReaderThemeDeleteEvent(this.readerTheme);

  @override
  List<Object> get props => [readerTheme];

  @override
  String toString() => 'ReaderThemeDeleteEvent { readerTheme: $readerTheme }';
}

@immutable
class ReaderThemeListState extends Equatable {
  final List<ReaderTheme> readerThemes;

  const ReaderThemeListState([this.readerThemes]);

  @override
  List<Object> get props => [readerThemes];

  @override
  String toString() => 'ReaderThemeListState { readerThemes: $readerThemes }';
}
