// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class CurrentSpineItemBloc
    extends Bloc<CurrentSpineItemEvent, CurrentSpineItemState> {
  CurrentSpineItemBloc() : super(const CurrentSpineItemState(0)) {
    on<CurrentSpineItemEvent>(_onCurrentSpineItemEvent);
  }

  void _onCurrentSpineItemEvent(
      CurrentSpineItemEvent event, Emitter<CurrentSpineItemState> emit) {
    emit(CurrentSpineItemState(event.spineItemIdx));
  }
}

@immutable
class CurrentSpineItemEvent extends Equatable {
  final int spineItemIdx;

  const CurrentSpineItemEvent(this.spineItemIdx);

  @override
  List<Object> get props => [spineItemIdx];

  @override
  String toString() => 'CurrentSpineItemEvent {spineItemIdx: $spineItemIdx}';
}

@immutable
class CurrentSpineItemState extends Equatable {
  final int spineItemIdx;

  const CurrentSpineItemState(this.spineItemIdx);

  @override
  List<Object> get props => [spineItemIdx];

  @override
  String toString() => 'CurrentSpineItemState {spineItemIdx: $spineItemIdx}';
}
