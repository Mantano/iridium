// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'request_handler.dart';

@immutable
abstract class ServerEvent extends Equatable {}

class StartServer extends ServerEvent {
  final List<RequestHandler> handlers;

  StartServer(this.handlers);

  @override
  List<Object> get props => [handlers];

  @override
  String toString() => 'StartServer';
}

class ShutdownServer extends ServerEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'ShutdownServer';
}
