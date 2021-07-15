// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ServerState extends Equatable {
  @override
  List<Object> get props => [];
}

class ServerStarted extends ServerState {
  final String address;

  ServerStarted(this.address);

  @override
  String toString() => 'ServerStarted {address: $address}';
}

class ServerClosed extends ServerState {
  @override
  String toString() => 'ServerClosed';
}

class ServerNotStarted extends ServerState {
  @override
  String toString() => 'ServerNotStarted';
}
