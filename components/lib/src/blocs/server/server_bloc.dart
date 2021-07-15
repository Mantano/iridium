// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fimber/fimber.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

import 'request_controller.dart';
import 'server.dart';

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  static int serverPort = 4040;
  HttpServer _server;
  RequestController _requestController;
  BehaviorSubject<String> _addressSubject;

  ServerBloc() : super(ServerNotStarted()) {
    _addressSubject = BehaviorSubject<String>.seeded(null);
  }

  String get address => _addressSubject.value;

  Stream<String> get addressStream => _addressSubject.stream;

  @override
  Stream<ServerState> mapEventToState(ServerEvent event) async* {
    if (event is StartServer) {
      yield* _mapStartServerToState(event);
    } else if (event is ShutdownServer) {
      yield* _mapShutdownServerToState();
    }
  }

  Stream<ServerState> _mapStartServerToState(StartServer event) async* {
    try {
      _server = await _initServer();
      _requestController = RequestController(event.handlers);
      Fimber.d("serverPort: ${_server.port}, ${_server.address.host}");
      _addressSubject.add("http://${_server.address.address}:${_server.port}");
      unawaited(runServer(_server));
      yield ServerStarted(address);
    } on Exception catch (e, stacktrace) {
      Fimber.d("ERROR", ex: e, stacktrace: stacktrace);
      _server = null;
      yield ServerNotStarted();
    }
  }

  Future<HttpServer> _initServer() async {
    HttpServer server;
    while (server == null) {
      try {
        server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          serverPort,
        );
      } on Exception catch (e, stacktrace) {
        Fimber.d("ERROR", ex: e, stacktrace: stacktrace);
      }
      serverPort++;
    }
    return server;
  }

  Stream<ServerState> _mapShutdownServerToState() async* {
    if (state is ServerStarted) {
      await _server.close(force: true);
      _server = null;
      _addressSubject.add(null);
      yield ServerClosed();
    }
  }

  Future<void> runServer(HttpServer server) async {
    int requestId = 0;
    await for (HttpRequest request in server) {
      int currentRequestId = requestId++;
      _requestController.onRequest(currentRequestId, request);
    }
  }
}
