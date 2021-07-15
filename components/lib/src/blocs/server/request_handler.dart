// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:typed_data';

import 'package:dartx/dartx.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:r2_commons_dart/extensions/data.dart';
import 'package:r2_shared_dart/fetcher.dart';
import 'package:r2_shared_dart/mediatype.dart';
import 'package:universal_io/io.dart';

abstract class RequestHandler {
  static const Duration _expirationDelay =
      Duration(seconds: 30); //Duration(days: 10);
  static const int _defaultRangeLength = 2 * 1024 * 1024; // 2Mb
  static const String _dateLocale = "en_US";
  static const String _cacheControlValue =
      "no-transform,public,max-age=3000,s-maxage=9000";

  Future<bool> handle(int requestId, HttpRequest request, String href);

  bool shouldAddCacheHeaders = false;

  /// Enable this method when debugging is over.
  void _addCacheHeaders(HttpResponse response) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss', _dateLocale);
    DateTime expiration = now.add(_expirationDelay);
    response.headers.set(HttpHeaders.cacheControlHeader, _cacheControlValue);
    response.headers
        .set(HttpHeaders.expiresHeader, formatter.format(expiration));
    response.headers.set(HttpHeaders.lastModifiedHeader, formatter.format(now));
  }

  int getParamAsInt(HttpRequest request, String name, {int defaultValue = 0}) {
    String valueStr = request.uri.queryParameters[name];
    return (valueStr != null) ? int.parse(valueStr) : defaultValue;
  }

  /// Sends a bytes buffer as the request response.
  Future<void> sendData(HttpRequest request,
      {@required List<int> data, MediaType mediaType}) async {
    assert(request != null);
    assert(data != null);
    HttpResponse response = request.response;

    if (shouldAddCacheHeaders) {
      _addCacheHeaders(response);
    }

    response
      ..headers.contentType = mediaType?.contentType
      ..add(data);
  }

  /// Sends a byte stream (supporting range access) as the request response.
  Future<void> sendResource(HttpRequest request,
      {@required Resource resource, MediaType mediaType}) async {
    assert(request != null);
    assert(resource != null);
    HttpResponse response = request.response;

    if (shouldAddCacheHeaders) {
      _addCacheHeaders(response);
    }

    response.headers
      ..contentType = mediaType?.contentType
      ..set(HttpHeaders.acceptRangesHeader, 'bytes');

    String range = request.headers.value(HttpHeaders.rangeHeader);
    if (range != null) {
      int length = (await resource.length()).getOrNull() ?? 0;
      int start = 0;
      int end = length - 1;

      try {
        List<String> parts = range.split('=');
        if (parts.length != 2 || 'bytes' != parts[0]) {
          throw "Requested range not satisfiable";
        }

        parts = parts[1].split("-");
        if (parts[0].isNotEmpty) {
          start = int.parse(parts[0]);
        }
        if (parts.length == 2 && parts[1].isNotEmpty) {
          end = int.parse(parts[1]);
        } else {
          end = min(length - 1, start + _defaultRangeLength);
        }
        response
          ..statusCode = HttpStatus.partialContent
          ..headers
              .set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$length');

        ByteData data =
            (await resource.read(range: IntRange(start, end))).getOrNull();
        if (data != null) {
          await response.addStream(data.asStream());
        }
      } on Exception catch (e, stacktrace) {
        Fimber.d("error", ex: e, stacktrace: stacktrace);
        request.response
          ..statusCode = HttpStatus.requestedRangeNotSatisfiable
          ..write("REQUESTED RANGE NOT SATISFIABLE");
        return;
      }
    } else {
      ByteData data = (await resource.read()).getOrNull();
      await response.addStream(data.asStream());
    }
  }
}

extension ContentTypeMediaType on MediaType {
  ContentType get contentType => ContentType.parse(toString());
}
