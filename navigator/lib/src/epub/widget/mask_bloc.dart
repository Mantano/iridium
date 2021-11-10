// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class MaskBloc extends Bloc<MaskEvent, MaskState> {
  VoidCallback _visibilityChangeCallback;

  MaskBloc() : super(const MaskState()) {
    on<UpdateVisibility>(
        (event, emit) => MaskState(visibility: event.visibility));
  }

  void onVisibilityChange(VoidCallback fn) => _visibilityChangeCallback = fn;

  @override
  void onTransition(Transition<MaskEvent, MaskState> transition) {
    super.onTransition(transition);
    if (transition.event is UpdateVisibility &&
        _visibilityChangeCallback != null) {
      _visibilityChangeCallback();
    }
  }
}

@immutable
abstract class MaskEvent extends Equatable {}

class UpdateVisibility extends MaskEvent {
  final bool visibility;

  UpdateVisibility({this.visibility = false});

  @override
  List<Object> get props => [visibility];

  @override
  String toString() => 'UpdateVisibility { visibility: $visibility }';
}

@immutable
class MaskState extends Equatable {
  final bool visibility;

  const MaskState({this.visibility = true});

  @override
  List<Object> get props => [visibility];

  @override
  String toString() => 'MaskVisibility { visibility: $visibility }';
}
