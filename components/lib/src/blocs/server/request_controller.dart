// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fimber/fimber.dart';
import 'package:universal_io/io.dart';

import 'request_handler.dart';

class RequestController {
  final List<RequestHandler> _handlers;

  RequestController(this._handlers) : assert(_handlers != null);

  void onRequest(int requestId, HttpRequest request) async {
    HttpResponse response = request.response;
    String href = Uri.decodeFull(request.uri.toString());
    if (href.startsWith("/")) {
      href = href.substring(1);
    }

    try {
      for (RequestHandler handler in _handlers) {
        if (await handler.handle(requestId, request, href)) {
          return;
        }
      }

      response
        ..statusCode = HttpStatus.notFound
        ..write("NOT FOUND");
    } on Exception catch (e, stacktrace) {
      response.statusCode = HttpStatus.internalServerError;
      Fimber.d("Request error", ex: e, stacktrace: stacktrace);
    } finally {
      await response.close();
    }
  }
}
